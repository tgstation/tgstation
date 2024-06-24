/// If a player has any of these enabled, they are forced to use a minimum of OPT_IN_ANTAG_ENABLED_LEVEL antag optin. Dynamic - checked on the fly, not cached.
GLOBAL_LIST_INIT(optin_forcing_midround_antag_categories, list(
	ROLE_CHANGELING_MIDROUND,
	ROLE_MALF_MIDROUND,
	ROLE_OBSESSED,
	ROLE_SLEEPER_AGENT,
))

/// If a player has any of these enabled ON SPAWN, they are forced to use a minimum of OPT_IN_ANTAG_ENABLED_LEVEL antag optin for the rest of the round.
GLOBAL_LIST_INIT(optin_forcing_on_spawn_antag_categories, list(
	ROLE_BROTHER,
	ROLE_CHANGELING,
	ROLE_CULTIST,
	ROLE_HERETIC,
	ROLE_MALF,
	ROLE_OPERATIVE,
	ROLE_TRAITOR,
	ROLE_WIZARD,
	ROLE_CLOWN_OPERATIVE,
	ROLE_NUCLEAR_OPERATIVE,
	ROLE_HERETIC_SMUGGLER,
	ROLE_PROVOCATEUR,
	ROLE_SYNDICATE_INFILTRATOR,
))

/datum/mind
	/// The optin level set by preferences.
	var/ideal_opt_in_level = OPT_IN_DEFAULT_LEVEL
	/// Set on the FIRST mob login. Set by on-spawn antags (e.g. if you have traitor on and spawn, this will be set to OPT_IN_ANTAG_ENABLED_LEVEL and cannot change)
	var/on_spawn_antag_opt_in_level = OPT_IN_NOT_TARGET
	/// Set to TRUE on a successful transfer_mind() call. If TRUE, transfer_mind() will not refresh opt in.
	var/opt_in_initialized

/mob/living/Login()
	. = ..()
	if(CONFIG_GET(flag/disable_antag_opt_in_preferences)) //lets not annoy our fellow players with useless info if we don't use this system at all
		return
	if (isnull(mind))
		return
	if (isnull(client?.prefs))
		return
	if (!mind.opt_in_initialized)
		mind.update_opt_in(client.prefs)
		mind.send_antag_optin_reminder()
		mind.opt_in_initialized = TRUE

/// Refreshes our ideal/on spawn antag opt in level by accessing preferences.
/datum/mind/proc/update_opt_in(datum/preferences/preference_instance = GLOB.preferences_datums[LOWER_TEXT(key)])
	if (isnull(preference_instance))
		return

	ideal_opt_in_level = preference_instance.read_preference(/datum/preference/choiced/antag_opt_in_status)

	for (var/antag_category in GLOB.optin_forcing_on_spawn_antag_categories)
		if (antag_category in preference_instance.be_special)
			on_spawn_antag_opt_in_level = OPT_IN_ANTAG_ENABLED_LEVEL
			break

/// Sends a bold message to our holder, telling them if their optin setting has been set to a minimum due to their antag preferences.
/datum/mind/proc/send_antag_optin_reminder()
	var/datum/preferences/preference_instance = GLOB.preferences_datums[LOWER_TEXT(key)]
	var/client/our_client = preference_instance?.parent // that moment when /mind doesnt have a ref to client :)
	if (our_client)
		var/antag_level = get_antag_opt_in_level()
		if (antag_level <= OPT_IN_NOT_TARGET)
			return
		var/stringified_level = GLOB.antag_opt_in_strings["[antag_level]"]
		to_chat(our_client, span_boldnotice("Due to your antag preferences, your antag-optin status has been set to a minimum of [stringified_level]."))

/// Gets the actual opt-in level used for determining targets.
/datum/mind/proc/get_effective_opt_in_level()
	var/step_1 = max(ideal_opt_in_level, get_job_opt_in_level())
	var/step_2 = max(step_1, get_antag_opt_in_level())
	return step_2

/// Returns the opt in level of our job.
/datum/mind/proc/get_job_opt_in_level()
	return assigned_role?.minimum_opt_in_level || OPT_IN_NOT_TARGET

/// If we have any antags enabled in GLOB.optin_forcing_midround_antag_categories, returns OPT_IN_ANTAG_ENABLED_LEVEL. OPT_IN_NOT_TARGET otherwise.
/datum/mind/proc/get_antag_opt_in_level()
	if (on_spawn_antag_opt_in_level > OPT_IN_NOT_TARGET)
		return on_spawn_antag_opt_in_level

	var/datum/preferences/preference_instance = GLOB.preferences_datums[LOWER_TEXT(key)]
	if (!isnull(preference_instance))
		for (var/antag_category in GLOB.optin_forcing_midround_antag_categories)
			if (antag_category in preference_instance.be_special)
				return OPT_IN_ANTAG_ENABLED_LEVEL
	return OPT_IN_NOT_TARGET
