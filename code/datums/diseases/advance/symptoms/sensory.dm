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
		M.adjust_timed_status_effect(-4 SECONDS, /datum/status_effect/dizziness)
		M.adjust_drowsyness(-2)
		M.adjust_timed_status_effect(-1 SECONDS, /datum/status_effect/speech/slurring/drunk)
		M.adjust_timed_status_effect(-2 SECONDS, /datum/status_effect/confusion)
		if(purge_alcohol)
			M.reagents.remove_all_type(/datum/reagent/consumable/ethanol, 3)
			M.adjust_drunk_effect(-5)

	if(A.stage >= 4)
		M.adjust_drowsyness(-2)
		if(M.reagents.has_reagent(/datum/reagent/toxin/mindbreaker))
			M.reagents.remove_reagent(/datum/reagent/toxin/mindbreaker, 5)
		if(M.reagents.has_reagent(/datum/reagent/toxin/histamine))
			M.reagents.remove_reagent(/datum/reagent/toxin/histamine, 5)
		M.hallucination = max(0, M.hallucination - 10)

	if(A.stage >= 5)
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, -3)
		if(trauma_heal_mild && iscarbon(M))
			var/mob/living/carbon/C = M
			if(prob(10))
				if(trauma_heal_severe)
					C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_LOBOTOMY)
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

/datum/symptom/sensory_restoration/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(4, 5)
			var/obj/item/organ/ears/ears = M.getorganslot(ORGAN_SLOT_EARS)
			if(ears)
				ears.adjustEarDamage(-4, -4)
			M.adjust_blindness(-2)
			M.adjust_blurriness(-2)
			var/obj/item/organ/eyes/eyes = M.getorganslot(ORGAN_SLOT_EYES)
			if(!eyes) // only dealing with eye stuff from here on out
				return
			eyes.applyOrganDamage(-2)
			if(HAS_TRAIT_FROM(M, TRAIT_BLIND, EYE_DAMAGE))
				if(prob(20))
					to_chat(M, span_warning("Your vision slowly returns..."))
					M.cure_blind(EYE_DAMAGE)
					M.cure_nearsighted(EYE_DAMAGE)
					M.blur_eyes(35)
			else if(HAS_TRAIT_FROM(M, TRAIT_NEARSIGHT, EYE_DAMAGE))
				to_chat(M, span_warning("The blackness in your peripheral vision fades."))
				M.cure_nearsighted(EYE_DAMAGE)
				M.blur_eyes(10)
		else
			if(prob(base_message_chance))
				to_chat(M, span_notice("[pick("Your eyes feel great.","You feel like your eyes can focus more clearly.", "You don't feel the need to blink.","Your ears feel great.","Your hearing feels more acute.")]"))
