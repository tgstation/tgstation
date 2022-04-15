/datum/preference/color/heterochromatic
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "heterochromatic"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/color/heterochromatic/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Heterochromatic" in preferences.all_quirks

/datum/preference/color/heterochromatic/apply_to_human(mob/living/carbon/human/target, value)
	var/obj/item/organ/eyes/human_eyes = target.getorgan(/obj/item/organ/eyes)
	if(!human_eyes)
		return

	human_eyes.eye_color_right = value
	human_eyes.old_eye_color_right = value
	target.eye_color_right = value
	human_eyes.refresh()
