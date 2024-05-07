/// Used to apply preferences at the very end of applying preferences, quirks, clothing, etc.
/datum/preferences/proc/after_prefs_transfer(mob/living/carbon/human/target)
	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (preference.savefile_identifier != PREFERENCE_CHARACTER)
			continue

		preference.after_apply_to_human(target, src, read_preference(preference.type))

/// See above. Called at the very end of player initialization.
/datum/preference/proc/after_apply_to_human(mob/living/carbon/human/target, datum/preferences/prefs, value)
	return
