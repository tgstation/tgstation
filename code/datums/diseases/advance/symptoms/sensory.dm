/* Mind Restoration
 * Slight stealth reduction
 * Reduces resistance
 * Slight increase to stage speed
 * Greatly decreases transmissibility
 * Critical level
*/
/datum/symptom/mind_restoration
	name = "Mind Restoration"
	desc = "The virus strengthens the bonds between neurons, reducing the duration of any ailments of the mind."
	stealth = -1
	resistance = -2
	stage_speed = 1
	transmittable = -3
	level = 5
	symptom_delay_min = 5
	symptom_delay_max = 10
	var/purge_alcohol = FALSE
	var/trauma_heal_mild = FALSE
	var/trauma_heal_severe = FALSE
	threshold_descs = list(
		"Resistance 6" = "Heals minor brain traumas.",
		"Resistance 9" = "Heals severe brain traumas.",
		"Transmission 8" = "Purges alcohol in the bloodstream.",
	)

/datum/symptom/mind_restoration/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalResistance() >= 6) //heal brain damage
		trauma_heal_mild = TRUE
	if(A.totalResistance() >= 9) //heal severe traumas
		trauma_heal_severe = TRUE
	if(A.totalTransmittable() >= 8) //purge alcohol
		purge_alcohol = TRUE

/datum/symptom/mind_restoration/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/M = A.affected_mob


	if(A.stage >= 3)
		M.adjust_dizzy(-4 SECONDS)
		M.adjust_drowsiness(-4 SECONDS)
		// All slurring effects get reduced down a bit
		for(var/datum/status_effect/speech/slurring/slur in M.status_effects)
			slur.remove_duration(1 SECONDS)

		M.adjust_confusion(-2 SECONDS)
		if(purge_alcohol)
			M.reagents.remove_reagent(/datum/reagent/consumable/ethanol, 3, include_subtypes = TRUE)
			M.adjust_drunk_effect(-5)

	if(A.stage >= 4)
		M.adjust_drowsiness(-4 SECONDS)
		if(M.reagents.has_reagent(/datum/reagent/toxin/mindbreaker))
			M.reagents.remove_reagent(/datum/reagent/toxin/mindbreaker, 5)
		if(M.reagents.has_reagent(/datum/reagent/toxin/histamine))
			M.reagents.remove_reagent(/datum/reagent/toxin/histamine, 5)

		M.adjust_hallucinations(-20 SECONDS)

	if(A.stage >= 5)
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -3)
		if(trauma_heal_mild && iscarbon(M))
			var/mob/living/carbon/C = M
			if(prob(10))
				if(trauma_heal_severe)
					C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_SURGERY)
				else
					C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)



/datum/symptom/sensory_restoration
	name = "Sensory Restoration"
	desc = "The virus stimulates the production and replacement of sensory tissues, causing the host to regenerate eyes and ears when damaged."
	stealth = 0
	resistance = 1
	stage_speed = -2
	transmittable = 2
	level = 4
	base_message_chance = 7
	symptom_delay_min = 1
	symptom_delay_max = 1

/datum/symptom/sensory_restoration/Activate(datum/disease/advance/advanced_disease)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/infected_mob = advanced_disease.affected_mob
	switch(advanced_disease.stage)
		if(4, 5)
			if(advanced_disease.has_required_infectious_organ(infected_mob, ORGAN_SLOT_EARS))
				var/obj/item/organ/ears/ears = infected_mob.get_organ_slot(ORGAN_SLOT_EARS)
				ears.adjustEarDamage(-4, -4)

			if(!advanced_disease.has_required_infectious_organ(infected_mob, ORGAN_SLOT_EYES))
				return

			var/obj/item/organ/eyes/eyes = infected_mob.get_organ_slot(ORGAN_SLOT_EYES)
			infected_mob.adjust_temp_blindness(-4 SECONDS)
			infected_mob.adjust_eye_blur(-4 SECONDS)

			eyes.apply_organ_damage(-2)
			if(prob(20))
				if(infected_mob.is_blind_from(EYE_DAMAGE))
					to_chat(infected_mob, span_warning("Your vision slowly returns..."))
					infected_mob.adjust_eye_blur(20 SECONDS)

				else if(infected_mob.is_nearsighted_from(EYE_DAMAGE))
					to_chat(infected_mob, span_warning("The blackness in your peripheral vision begins to fade."))
					infected_mob.adjust_eye_blur(5 SECONDS)

		else
			if(prob(base_message_chance))
				to_chat(infected_mob, span_notice("[pick("Your eyes feel great.","You feel like your eyes can focus more clearly.", "You don't feel the need to blink.","Your ears feel great.","Your hearing feels more acute.")]"))
