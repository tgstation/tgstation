/datum/preference/choiced/body_type
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	priority = PREFERENCE_PRIORITY_BODY_TYPE
	savefile_key = "body_type"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/body_type/init_possible_values()
	return list(MALE, FEMALE)

/datum/preference/choiced/body_type/apply_to_human(mob/living/carbon/human/target, value)
	target.body_type = value

/datum/preference/choiced/body_type/create_default_value()
	return MALE
