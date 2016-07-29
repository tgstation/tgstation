/**
 * Lung Gas Handlers
 *
 * These standardize behavior of differing gas-comsumption processes and make it far easier to tweak thresholds without duplicating code.
 */
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
				if("[G.type]" != id)
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
			H.adjustOxyLoss(1) // Lets hurt em a little, let them know we mean business
			if(world.time - H.co2overloadtime > 600) // They've been in here 60s now, lets start to kill them for their own good!
				H.adjustOxyLoss(3)
		if(prob(20)) // Lets give them some chance to know somethings not right though I guess.
			H.audible_cough()
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
	var/reagent_id = PLASMA // What reagent to add
	var/reagent_mult = 10

/datum/lung_gas/toxic/New(var/gas_id, var/trace_gas=0, var/max_pp=0, var/max_pp_mask=0, var/reagent_id=PLASMA, var/reagent_mult=10)
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
				// H.reagents.add_reagent(PLASMA, Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))
				// no this is bad n3x pls no
				H.adjustToxLoss(Clamp(ratio, MIN_PLASMA_DAMAGE, MAX_PLASMA_DAMAGE))
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
