/datum/preference/choiced/body_type
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "body_type"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/body_type/init_possible_values()
	return list(MALE, FEMALE)

/datum/preference/choiced/body_type/apply_to_human(mob/living/carbon/human/target, value)
	if (target.gender != MALE && target.gender != FEMALE)
		target.body_type = value
	else
		target.body_type = target.gender

/datum/preference/choiced/body_type/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/gender = preferences.read_preference(/datum/preference/choiced/gender)
	return gender != MALE && gender != FEMALE
