/datum/action/changeling/sting/blind/sting_action(mob/user, mob/living/carbon/target)
	var/obj/item/organ/internal/eyes/eyes = target.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		user.balloon_alert(user, "no eyes!")
		return FALSE

	log_combat(user, target, "stung", "blind sting")
	to_chat(target, span_danger("Your eyes burn horrifically!"))
	eyes.apply_organ_damage(eyes.maxHealth * 0.8, maximum = eyes.maxHealth * 0.8)
	target.set_temp_blindness_if_lower(40 SECONDS)
	target.set_eye_blur_if_lower(80 SECONDS)
	return TRUE
