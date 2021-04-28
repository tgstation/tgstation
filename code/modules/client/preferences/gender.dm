/// Gender preference
/datum/preference/gender
	savefile_key = "gender"

/datum/preference/gender/apply(mob/living/carbon/human/target, value)
	target.gender = value

/datum/preference/gender/get_all_possible_values()
	return list(MALE, FEMALE, PLURAL)

/datum/preference/gender/deserialize(value)
	return sanitize_gender(value)
