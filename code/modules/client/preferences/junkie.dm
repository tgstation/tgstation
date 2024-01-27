/datum/preference/choiced/junkie
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "junkie"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/junkie/init_possible_values()
	return list("Random") + GLOB.junkie_drug

/datum/preference/choiced/junkie/is_accessible(datum/preferences/preferences)
	. = ..()
	if (!.)
		return FALSE

	return "Junkie" in preferences.all_quirks

/datum/preference/choiced/junkie/apply_to_human(mob/living/carbon/human/target, value)
	return
