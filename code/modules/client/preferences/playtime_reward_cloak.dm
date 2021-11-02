/// This can be set to TRUE from the prefs menu only once the user has
/// gained over 5K playtime hours.
/// If true, it allows the user to get a cool looking roundstart cloak.
/datum/preference/toggle/playtime_reward_cloak
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "playtime_reward_cloak"

/datum/preference/toggle/playtime_reward_cloak/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	return preferences.parent?.is_veteran()

/datum/preference/toggle/playtime_reward_cloak/apply_to_human(mob/living/carbon/human/target, value)
	return

/// Returns whether the client should receive the gamer cloak
/client/proc/is_veteran()
	return get_exp_living(pure_numeric = TRUE) >= PLAYTIME_VETERAN
