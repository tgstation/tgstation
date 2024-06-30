/datum/preference/text/custom_signature
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "signature"
	maximum_value_length = 20

/datum/preference/text/custom_signature/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return FALSE

/datum/preference/text/custom_date
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "date_format"
	maximum_value_length = 14

/datum/preference/text/custom_date/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return FALSE
