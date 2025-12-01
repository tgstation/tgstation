/datum/preference/choiced/chipped
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "chipped"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/chipped/create_default_value()
	return "Random"

/datum/preference/choiced/chipped/init_possible_values()
	return list("Random") + assoc_to_keys(GLOB.quirk_chipped_choice)

/datum/preference/choiced/chipped/is_accessible(datum/preferences/preferences)
	. = ..()
	if (!.)
		return FALSE

	return /datum/quirk/chipped::name in preferences.all_quirks

/datum/preference/choiced/chipped/apply_to_human(mob/living/carbon/human/target, value)
	return
