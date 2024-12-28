/*Hyphema (Eye bleeding)
 * Slightly reduces stealth
 * Tremendously reduces resistance
 * Tremendously reduces stage speed
 * Greatly reduces transmissibility
 * Critical level
 * Bonus: Causes blindness.
*/
/datum/symptom/visionloss
	name = "Hyphema"
	desc = "Sufferers exhibit dangerously low levels of frames per second in the eyes, leading to damage and eventually blindness."
	illness = "Diluted Pupils"
	stealth = -1
	resistance = -4
	stage_speed = -4
	transmittable = -3
	level = 5
	severity = 5
	base_message_chance = 50
	symptom_delay_min = 25
	symptom_delay_max = 80
	required_organ = ORGAN_SLOT_EYES
	threshold_descs = list(
		"Resistance 12" = "Weakens extraocular muscles, eventually leading to complete detachment of the eyes.",
		"Stealth 4" = "The symptom remains hidden until active.",
	)
	/// At max stage: If FALSE, cause blindness. If TRUE, cause their eyes to fall out.
	var/remove_eyes = FALSE

/datum/symptom/visionloss/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStealth() >= 4)
		suppress_warning = TRUE
	if(A.totalResistance() >= 12) //goodbye eyes
		remove_eyes = TRUE

/datum/symptom/visionloss/Activate(datum/disease/advance/source_disease)
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/infected_mob = source_disease.affected_mob
	var/obj/item/organ/eyes/eyes = infected_mob.get_organ_slot(ORGAN_SLOT_EYES)

	switch(source_disease.stage)
		if(1, 2)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(infected_mob, span_warning("Your eyes itch."))

		if(3, 4)
			to_chat(infected_mob, span_boldwarning("Your eyes burn!"))
			infected_mob.set_eye_blur_if_lower(20 SECONDS)
			eyes.apply_organ_damage(1)

		else
			infected_mob.set_eye_blur_if_lower(40 SECONDS)
			eyes.apply_organ_damage(5)

			// Applies nearsighted at minimum
			if(!infected_mob.is_nearsighted_from(EYE_DAMAGE) && eyes.damage <= eyes.low_threshold)
				eyes.set_organ_damage(eyes.low_threshold)

			if(prob(eyes.damage - eyes.low_threshold + 1))
				if(remove_eyes)
					infected_mob.visible_message(
						span_warning("[infected_mob]'s eyes fall out of their sockets!"),
						span_userdanger("Your eyes fall out of their sockets!"),
					)
					eyes.Remove(infected_mob)
					eyes.forceMove(get_turf(infected_mob))

				else if(!infected_mob.is_blind_from(EYE_DAMAGE))
					to_chat(infected_mob, span_userdanger("You go blind!"))
					eyes.apply_organ_damage(eyes.maxHealth)

			else
				to_chat(infected_mob, span_userdanger("Your eyes burn horrifically!"))
