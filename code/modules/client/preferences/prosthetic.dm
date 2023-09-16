/datum/preference/choiced/prosthetic
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "prosthetic"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/prosthetic/init_possible_values()
	var/random_slot = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/choice = list(
		"Random" = random_slot,
		"Left Arm" = BODY_ZONE_L_ARM,
		"Right Arm" = BODY_ZONE_R_ARM,
		"Left Leg" = BODY_ZONE_L_LEG,
		"Right Leg" = BODY_ZONE_R_LEG,
	return assoc_to_keys(choice))

/datum/preference/choiced/prosthetic/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Prosthetic Limb" in preferences.all_quirks

/datum/preference/choiced/prosthetic/apply_to_human(mob/living/carbon/human/target, value)
	return
