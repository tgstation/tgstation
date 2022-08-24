/// Which crime is the prisoner permabrigged for. For fluff!
/datum/preference/choiced/prisoner_crime
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "prisoner_crime"

/datum/preference/choiced/prisoner_crime/init_possible_values()
	return GLOB.prisoner_crimes

/datum/preference/choiced/prisoner_crime/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/prisoner_crime/create_default_value()
	return pick(GLOB.prisoner_crimes)

/datum/preference/choiced/prisoner_crime/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return TRUE
