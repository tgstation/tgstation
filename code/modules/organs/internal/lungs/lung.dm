
///////////////////////
// LUNG ORGAN
///////////////////////

/datum/organ/internal/lungs
	name = "lungs"
	parent_organ = "chest"
	removed_type = /obj/item/organ/lungs

	// /vg/ now delegates breathing to the appropriate organ.

	// DEFAULTS FOR HUMAN LUNGS:
	var/list/datum/lung_gas/gasses = list(
		new /datum/lung_gas/metabolizable("oxygen",            min_pp=16, max_pp=140),
		new /datum/lung_gas/waste("carbon_dioxide",            max_pp=10),
		new /datum/lung_gas/toxic("toxins",                    max_pp=0.5, max_pp_mask=5, reagent_id="plasma", reagent_mult=0.1),
		new /datum/lung_gas/sleep_agent("/datum/gas/sleeping_agent", trace_gas=1, min_giggle_pp=0.15, min_para_pp=1, min_sleep_pp=5),
	)

	var/inhale_volume = BREATH_VOLUME
	var/exhale_moles = 0

/datum/organ/internal/lungs/proc/gasp()
	owner.emote("gasp")

/datum/organ/internal/lungs/proc/handle_breath(var/datum/gas_mixture/breath, var/mob/living/carbon/human/H)

	// NOW WITH MODULAR GAS HANDLING RATHER THAN A CLUSTERFUCK OF IF-TREES FOR EVERY SNOWFLAKE RACE
	//testing("Ticking lungs...")

	// First, we consume air.
	for(var/datum/lung_gas/G in gasses)
		G.set_context(src,breath,H)
		G.handle_inhale()

	// Next, we exhale. At the moment, only /datum/lung_gas/waste uses this.
	for(var/datum/lung_gas/G in gasses)
		G.set_context(src,breath,H)
		G.handle_exhale()

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
		new /datum/lung_gas/toxic("oxygen",                    max_pp=0.5, max_pp_mask=0, reagent_id="oxygen", reagent_mult=0.1),
		new /datum/lung_gas/sleep_agent("/datum/gas/sleeping_agent", trace_gas=1, min_giggle_pp=0.15, min_para_pp=1, min_sleep_pp=5),
	)


/datum/organ/internal/lungs/plasmaman
	name = "\improper Plasmaman lungs"
	removed_type = /obj/item/organ/lungs/plasmaman

	gasses = list(
		new /datum/lung_gas/metabolizable("toxins", min_pp=16, max_pp=140),
		new /datum/lung_gas/waste("oxygen",         max_pp=0),
		new /datum/lung_gas/sleep_agent("/datum/gas/sleeping_agent", trace_gas=1, min_giggle_pp=0.15, min_para_pp=1, min_sleep_pp=5),
	)
