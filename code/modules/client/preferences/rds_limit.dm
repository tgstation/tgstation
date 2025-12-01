/datum/preference/toggle/rds_limit
	category = PREFERENCE_CATEGORY_MANUALLY_RENDERED
	savefile_key = "rds_limit"
	savefile_identifier = PREFERENCE_CHARACTER
	default_value = FALSE

/datum/preference/toggle/rds_limit/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/toggle/rds_limit/is_accessible(datum/preferences/preferences)
	return ..() && (/datum/quirk/insanity::name in preferences.all_quirks)
