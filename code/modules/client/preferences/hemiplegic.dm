/datum/preference/choiced/hemiplegic
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "hemiplegic"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/hemiplegic/init_possible_values()
	return list("Random") + GLOB.side_choice_hemiplegic

/datum/preference/choiced/hemiplegic/is_accessible(datum/preferences/preferences)
	. = ..()
	if (!.)
		return FALSE

	return "Hemiplegic" in preferences.all_quirks

/datum/preference/choiced/hemiplegic/apply_to_human(mob/living/carbon/human/target, value)
	return
