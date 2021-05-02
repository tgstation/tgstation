/// Gender preference
/datum/preference/gender
	savefile_key = "gender"

/datum/preference/gender/init_possible_values()
	return list(MALE, FEMALE, PLURAL)

/datum/preference/gender/apply(mob/living/carbon/human/target, value)
	target.gender = value
