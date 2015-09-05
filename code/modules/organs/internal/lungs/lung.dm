
#define LUNG_ACTION_METABOLIZE 0 // Treat like oxygen
#define LUNG_ACTION_TOXIC      1 // Treat like plasma
#define LUNG_ACTION_WASTE      2 // Treat like carbon_dioxide
#define LUNG_ACTION_SLEEP      3 // Treat like sleeping agent

/datum/lung_gas
	var/datum/organ/internal/lungs/lungs = null
	var/id=""
	var/is_trace = 0
	var/datum/gas/gas = null
	var/datum/gas_mixture/breath = null

/datum/lung_gas/New(var/gas_id, var/trace_gas=0)
	src.id = gas_id
	src.is_trace = trace_gas

/datum/lung_gas/proc/get_pp()
	var/breath_pressure = (breath.total_moles()*R_IDEAL_GAS_EQUATION*breath.temperature)/lungs.inhale_volume
	if(!is_trace)
		return (breath.vars[id]/breath.total_moles())*breath_pressure
	else
		if(gas)
			return (gas.moles/breath.total_moles())*breath_pressure
		return 0

/datum/lung_gas/proc/get_moles()
	if(!is_trace)
		return breath.vars[id]
	else
		if(gas)
			return gas.moles
		return 0

/datum/lung_gas/proc/add_exhaled(var/moles)
	lungs.exhale_moles += moles

/datum/lung_gas/proc/set_moles(var/moles)
	if(!is_trace)
		breath.vars[id]=moles
	else
		if(gas)
			gas.moles = moles

/datum/lung_gas/proc/add_moles(var/moles)
	if(!is_trace)
		breath.vars[id]+=moles
	else
		if(gas)
			gas.moles += moles

/datum/lung_gas/proc/set_context(var/datum/organ/internal/lungs/L, var/datum/gas_mixture/breath, var/mob/living/carbon/human/H)
	src.lungs=L
	src.breath=breath
	if(is_trace)
		// Find the trace gas we need to mess with
		if(breath.trace_gases.len)	// If there's some other shit in the air lets deal with it here.
			for(var/datum/gas/G in breath.trace_gases)
				if(G.type != id)
					continue
				gas = G

/datum/lung_gas/proc/handle_inhale()
	return

/datum/lung_gas/proc/handle_exhale()
	return


////////////////////////
// METABOLIZABLE GAS
//
// Basically, makes the given gas act like oxygen.
////////////////////////

/datum/lung_gas/metabolizable
	var/min_pp=0
	var/max_pp=999

/datum/lung_gas/metabolizable/New(var/gas_id, var/trace_gas=0, var/min_pp=0, var/max_pp=999)
	..(gas_id,trace_gas)
	src.min_pp = min_pp
	src.max_pp = max_pp

/datum/lung_gas/metabolizable/handle_inhale()
	var/pp = get_pp() // Partial pressure of our oxygen or whatever.
	var/moles = get_moles()

	//testing("METAB: gasid=[id];pp=[pp];min_pp=[min_pp];moles=[moles]")
	if(pp < min_pp)  // Too little oxygen
		if(prob(20))
			//testing("  Receiving too little [id], gasping.")
			lungs.gasp()

	var/mob/living/carbon/human/H = lungs.owner
	var/used=0
	if(pp > 0)
		used=H.species.receiveGas(id, min(1,pp/min_pp), moles, H)
	else
		used=H.species.receiveGas(id, 0, moles, H)

	if(used)
		//testing("  Used [moles] moles.")
		add_moles(-used)
		add_exhaled(used)

////////////////////////
// WASTE GAS
//
// CO2.
////////////////////////

/datum/lung_gas/waste
	var/max_pp=0 // Maximum atmospheric partial pressure before you start getting paralyzed
	             // NOTE: If set to 0, will not give poisoning effects.

/datum/lung_gas/waste/New(var/gas_id, var/trace_gas=0, var/max_pp=0)
	..(gas_id,trace_gas)
	src.max_pp = max_pp

/datum/lung_gas/waste/handle_inhale()
	..()
	var/pp = get_pp()
	//testing("WASTE: gasid=[id];pp=[pp]")
	var/mob/living/carbon/human/H = lungs.owner
	//CO2 does not affect failed_last_breath. So if there was enough oxygen in the air but too much co2, this will hurt you, but only once per 4 ticks, instead of once per tick.
	if(max_pp && pp > max_pp)
		//testing("  [pp] > [max_pp]: Adding paralyze and oxyloss")
		if(!H.co2overloadtime) // If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
			H.co2overloadtime = world.time
		else if(world.time - H.co2overloadtime > 120)
			H.Paralyse(3)
			H.adjustOxyLoss(3) // Lets hurt em a little, let them know we mean business
			if(world.time - H.co2overloadtime > 300) // They've been in here 30s now, lets start to kill them for their own good!
				H.adjustOxyLoss(8)
		if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
			H.emote("cough")
	else
		H.co2overloadtime = 0

/datum/lung_gas/waste/handle_exhale()
	..()

	// Exhale CO2 and reset pressure counter.
	add_moles(lungs.exhale_moles)
	lungs.exhale_moles = 0



////////////////////////
// GAS TOXICITY
////////////////////////

/datum/lung_gas/toxic
	var/max_pp=0 // Maximum toxins partial pressure before you get effects. (0.5)
	var/max_pp_mask=0 // Same as above, but with a mask. (5 _MOLES_; Set to 0 to disable mask blocking.)
	var/reagent_id = "plasma" // What reagent to add
	var/reagent_mult = 10

/datum/lung_gas/toxic/New(var/gas_id, var/trace_gas=0, var/max_pp=0, var/max_pp_mask=0, var/reagent_id="plasma", var/reagent_mult=10)
	..(gas_id,trace_gas)
	src.max_pp = max_pp
	src.max_pp_mask = max_pp_mask
	src.reagent_id = reagent_id
	src.reagent_mult = reagent_mult

/datum/lung_gas/toxic/handle_inhale()
	..()
	var/pp = get_pp()
	var/mob/living/carbon/human/H=lungs.owner
	if(pp > max_pp) // Too much toxins
		//testing("TOXIC: gasid=[id];pp=[pp]")
		var/ratio = (pp/max_pp) * reagent_mult // WAS: (moles/max_moles) * 10
		//adjustToxLoss(Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))	//Limit amount of damage toxin exposure can do per second
		if(max_pp_mask)
			if(H.wear_mask)
				if(H.wear_mask.flags & BLOCK_GAS_SMOKE_EFFECT)
					if(pp > max_pp_mask)
						ratio = (pp/max_pp_mask) * reagent_mult
					else
						ratio = 0
		if(ratio)
			if(H.reagents)
				H.reagents.add_reagent("plasma", Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))
			H.toxins_alert = max(H.toxins_alert, 1)
	else
		H.toxins_alert = 0


////////////////////////
// SLEEPING GAS
////////////////////////

/datum/lung_gas/sleep_agent
	var/min_giggle_pp = 0.15 // Giggling starts at this partial pressure.
	var/min_para_pp = 1      // Paralysis
	var/min_sleep_pp = 5     // Sleep

/datum/lung_gas/sleep_agent/New(var/gas_id, var/trace_gas=0, var/min_giggle_pp=0, var/min_sleep_pp=0, var/min_para_pp=0)
	..(gas_id,trace_gas)
	src.min_para_pp=min_para_pp
	src.min_giggle_pp=min_giggle_pp
	src.min_para_pp=min_para_pp

/datum/lung_gas/sleep_agent/handle_inhale()
	var/pp = get_pp()
	var/mob/living/carbon/human/H=lungs.owner
	if(pp > min_para_pp) // Enough to make us paralysed for a bit
		H.Paralyse(3) // 3 gives them one second to wake up and run away a bit!
	if(pp > min_sleep_pp) // Enough to make us sleep as well
		H.sleeping = min(H.sleeping+2, 10)
	if(pp > min_giggle_pp)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
		if(prob(20))
			H.emote(pick("giggle", "laugh"))
	set_moles(0)

///////////////////////
// LUNG ORGAN
///////////////////////

/datum/organ/internal/lungs
	name = "lungs"
	parent_organ = "chest"
	removed_type = /obj/item/organ/lungs

	// VG now delegates breathing to the appropriate organ.

	// DEFAULTS FOR HUMAN LUNGS:
	var/list/datum/lung_gas/gasses = list(
		new /datum/lung_gas/metabolizable("oxygen",            min_pp=16, max_pp=140),
		new /datum/lung_gas/waste("carbon_dioxide",            max_pp=10),
		new /datum/lung_gas/toxic("toxins",                    max_pp=0.5, max_pp_mask=5, reagent_id="plasma", reagent_mult=10),
		new /datum/lung_gas/sleep_agent("/datum/gas/sleeping_agent", trace_gas=1, min_giggle_pp=0.15, min_para_pp=1, min_sleep_pp=5),
	)

	var/inhale_volume = BREATH_VOLUME
	var/exhale_moles = 0

/datum/organ/internal/lungs/proc/gasp()
	owner.emote("gasp")

/datum/organ/internal/lungs/proc/handle_breath(var/datum/gas_mixture/breath, var/mob/living/carbon/human/H)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/datum/species/proc/handle_breath() called tick#: [world.time]")

	// NOW WITH MODULAR GAS HANDLING RATHER THAN A CLUSTERFUCK OF IF-TREES FOR EVERY SNOWFLAKE RACE
	//testing("Ticking lungs...")

	// First, we consume air.
	for(var/datum/lung_gas/G in gasses)
		G.set_context(src,breath,H)
		G.handle_inhale()

	// Next, we exhale. At the moment, only /datum/lung_gas/waste uses this.
	for(var/datum/lung_gas/G in gasses)
		G.set_context(src,breath,H)
		G.handle_inhale()

	if( (abs(310.15 - breath.temperature) > 50) && !(M_RESIST_HEAT in H.mutations)) // Hot air hurts :(
		if(H.status_flags & GODMODE)	return 1	//godmode
		if(breath.temperature < H.species.cold_level_1)
			if(prob(20))
				H << "<span class='warning'>You feel your face freezing and an icicle forming in your lungs!</span>"
		else if(breath.temperature > H.species.heat_level_1)
			if(prob(20))
				if(H.dna.mutantrace == "slime")
					H << "<span class='warning'>You feel supercharged by the extreme heat!</span>"
				else
					H << "<span class='warning'>You feel your face burning and a searing heat in your lungs!</span>"

		if(H.dna.mutantrace == "slime")
			if(breath.temperature < H.species.cold_level_1)
				H.adjustToxLoss(round(H.species.cold_level_1 - breath.temperature))
				H.fire_alert = max(H.fire_alert, 1)
		else
			switch(breath.temperature)
				if(-INFINITY to H.species.cold_level_3)
					H.apply_damage(COLD_GAS_DAMAGE_LEVEL_3, BURN, "head", used_weapon = "Excessive Cold")
					H.fire_alert = max(H.fire_alert, 1)

				if(H.species.cold_level_3 to H.species.cold_level_2)
					H.apply_damage(COLD_GAS_DAMAGE_LEVEL_2, BURN, "head", used_weapon = "Excessive Cold")
					H.fire_alert = max(H.fire_alert, 1)

				if(H.species.cold_level_2 to H.species.cold_level_1)
					H.apply_damage(COLD_GAS_DAMAGE_LEVEL_1, BURN, "head", used_weapon = "Excessive Cold")
					H.fire_alert = max(H.fire_alert, 1)

				if(H.species.heat_level_1 to H.species.heat_level_2)
					H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_1, BURN, "head", used_weapon = "Excessive Heat")
					H.fire_alert = max(H.fire_alert, 2)

				if(H.species.heat_level_2 to H.species.heat_level_3)
					H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_2, BURN, "head", used_weapon = "Excessive Heat")
					H.fire_alert = max(H.fire_alert, 2)

				if(H.species.heat_level_3 to INFINITY)
					H.apply_damage(HEAT_GAS_DAMAGE_LEVEL_3, BURN, "head", used_weapon = "Excessive Heat")
					H.fire_alert = max(H.fire_alert, 2)

/datum/organ/internal/lungs/process()
	..()
	if (germ_level > INFECTION_LEVEL_ONE)
		if(prob(5))
			owner.emote("cough")		//respitory tract infection

	if(is_bruised())
		if(prob(2))
			spawn owner.emote("me", 1, "coughs up blood!")
			owner.drip(10)
		if(prob(4))
			spawn owner.emote("me", 1, "gasps for air!")
			owner.losebreath += 5


/datum/organ/internal/lungs/vox
	name = "\improper Vox lungs"
	removed_type = /obj/item/organ/lungs/vox

	gasses = list(
		new /datum/lung_gas/metabolizable("nitrogen",          min_pp=16, max_pp=140),
		new /datum/lung_gas/waste("carbon_dioxide",            max_pp=10), // I guess? Ideally it'd be some sort of nitrogen compound.  Maybe N2O?
		new /datum/lung_gas/toxic("oxygen",                    max_pp=0.5, max_pp_mask=0, reagent_id="oxygen", reagent_mult=1000),
		new /datum/lung_gas/sleep_agent("/datum/gas/sleeping_agent", trace_gas=1, min_giggle_pp=0.15, min_para_pp=1, min_sleep_pp=5),
	)


/datum/organ/internal/lungs/plasmaman
	name = "weird pink lungs"
	removed_type = /obj/item/organ/lungs/plasmaman

	gasses = list(
		new /datum/lung_gas/metabolizable("plasma", min_pp=16, max_pp=140),
		new /datum/lung_gas/waste("oxygen",         max_pp=10), // ???
		new /datum/lung_gas/sleep_agent("/datum/gas/sleeping_agent", trace_gas=1, min_giggle_pp=0.15, min_para_pp=1, min_sleep_pp=5),
	)
