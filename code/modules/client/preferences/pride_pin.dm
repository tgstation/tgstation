/datum/preference/choiced/pride_pin
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_key = "pride_pin"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/pride_pin/init_possible_values()
	return assoc_to_keys(GLOB.pride_pin_reskins)

/datum/preference/choiced/pride_pin/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return "Pride Pin" in preferences.all_quirks

/datum/preference/choiced/pride_pin/apply_to_human(mob/living/carbon/human/target, value)
	return
