/datum/preference/choiced/body_type/apply_to_human(mob/living/carbon/human/target, value)
	target.physique = target.gender

/datum/preference/choiced/body_type/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return FALSE
