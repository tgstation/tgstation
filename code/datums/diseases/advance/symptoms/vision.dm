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
	desc = "The virus causes inflammation of the retina, leading to eye damage and eventually blindness."
	stealth = -1
	resistance = -4
	stage_speed = -4
	transmittable = -3
	level = 5
	severity = 5
	base_message_chance = 50
	symptom_delay_min = 25
	symptom_delay_max = 80
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
	var/mob/living/carbon/ill_mob = source_disease.affected_mob
	var/obj/item/organ/internal/eyes/eyes = source_disease.getorganslot(ORGAN_SLOT_EYES)
	if(!eyes)
		return // can't do much

	switch(source_disease.stage)
		if(1, 2)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(ill_mob, span_warning("Your eyes itch."))

		if(3, 4)
			to_chat(ill_mob, span_boldwarning("Your eyes burn!"))
			ill_mob.set_eye_blur_if_lower(20 SECONDS)
			eyes.applyOrganDamage(1)

		else
			ill_mob.set_eye_blur_if_lower(40 SECONDS)
			eyes.applyOrganDamage(5)

			if(eyes.damage >= 10)
				ill_mob.become_nearsighted(EYE_DAMAGE)

			if(prob(eyes.damage - 10 + 1))
				if(remove_eyes)
					ill_mob.visible_message(span_warning("[ill_mob]'s eyes fall out of their sockets!"), span_userdanger("Your eyes fall out of their sockets!"))
					eyes.Remove(ill_mob)
					eyes.forceMove(get_turf(ill_mob))

				else if(!is_blind(ill_mob))
					to_chat(ill_mob, span_userdanger("You go blind!"))
					eyes.applyOrganDamage(eyes.maxHealth)

			else
				to_chat(M, span_userdanger("Your eyes burn horrifically!"))
