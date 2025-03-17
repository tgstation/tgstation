/datum/preference/choiced/loadout_override_preference
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	priority = PREFERENCE_PRIORITY_DEFAULT
	savefile_key = "loadout_override_preference"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/loadout_override_preference/init_possible_values()
	return list(LOADOUT_OVERRIDE_JOB, LOADOUT_OVERRIDE_BACKPACK, LOADOUT_OVERRIDE_CASE)

/datum/preference/choiced/loadout_override_preference/create_default_value()
	return LOADOUT_OVERRIDE_CASE

/datum/preference/choiced/loadout_override_preference/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return TRUE
