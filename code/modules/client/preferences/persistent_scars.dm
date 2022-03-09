/datum/preference/toggle/persistent_scars
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "persistent_scars"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/toggle/persistent_scars/apply_to_human(mob/living/carbon/human/target, value)
	target.persistent_scars = sanitize_integer(value)
