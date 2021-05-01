/// Gender preference
/datum/preference/gender
	savefile_key = "gender"

/datum/preference/gender/apply(mob/living/carbon/human/target, value)
	target.gender = value

/datum/preference/gender/get_choices()
	return list(MALE, FEMALE, PLURAL)
