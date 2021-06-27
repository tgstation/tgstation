/// Gender preference
/datum/preference/choiced/gender
	savefile_key = "gender"

/datum/preference/choiced/gender/init_possible_values()
	return list(MALE, FEMALE, PLURAL)

/datum/preference/choiced/gender/apply(mob/living/carbon/human/target, value)
	target.gender = value
