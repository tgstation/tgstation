/**
 * This is the preference for the player's SpaceMessenger ringtone.
 * Currently only applies to humans spawned in with a job, as it's hooked
 * into `/datum/job/proc/after_spawn()`.
 */
/datum/preference/text/pda_ringtone
	savefile_key = "pda_ringtone"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	maximum_value_length = MESSENGER_RINGTONE_MAX_LENGTH


/datum/preference/text/pda_ringtone/create_default_value()
	return MESSENGER_RINGTONE_DEFAULT

// Returning false here because this pref is handled a little differently, due to its dependency on the existence of a PDA.
/datum/preference/text/pda_ringtone/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return FALSE

/**
 * PDA theme
 */
/datum/preference/choiced/pda_theme
	savefile_key = "pda_theme"
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER

/datum/preference/choiced/pda_theme/init_possible_values()
	var/list/values = list()
	for(var/name in GLOB.default_pda_themes)
		values[name] = GLOB.default_pda_themes[name]
	return values

/datum/preference/choiced/pda_theme/create_default_value()
	return PDA_THEME_NTOS_NAME

// Returning false here because this pref is handled a little differently, due to its dependency on the existence of a PDA.
/datum/preference/choiced/pda_theme/apply_to_human(mob/living/carbon/human/target, value, datum/preferences/preferences)
	return FALSE
