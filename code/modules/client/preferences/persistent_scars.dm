/datum/preference/toggle/persistent_scars
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_key = "persistent_scars"
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/toggle/persistent_scars/apply_to_human(mob/living/carbon/human/target, value)
	// This proc doesn't do anything, due to the nature of persistent scars, we ALWAYS need to have a client to be able to use them properly. Or at the very least, a ckey.
	// So we don't need to store this anywhere else, we simply search the preference when we need it.
	return
