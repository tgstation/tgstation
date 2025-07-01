/// Antagonists that don't have a dynamic ruleset, but do have a preference
GLOBAL_LIST_INIT(non_ruleset_antagonists, list(
	ROLE_GLITCH = /datum/antagonist/bitrunning_glitch,
	ROLE_FUGITIVE = /datum/antagonist/fugitive,
	ROLE_LONE_OPERATIVE = /datum/antagonist/nukeop/lone,
	ROLE_SENTIENCE = /datum/antagonist/sentient_creature,
))

/datum/preference_middleware/antags
	action_delegations = list(
		"set_antags" = PROC_REF(set_antags),
	)

/datum/preference_middleware/antags/get_ui_static_data(mob/user)
	if (preferences.current_window != PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return list()

	var/list/data = list()

	var/list/selected_antags = list()

	for (var/antag in preferences.be_special)
		selected_antags += serialize_antag_name(antag)

	data["selected_antags"] = selected_antags

	var/list/antag_bans = get_antag_bans()
	if (antag_bans.len)
		data["antag_bans"] = antag_bans

	var/list/antag_days_left = get_antag_days_left()
	if (antag_days_left?.len)
		data["antag_days_left"] = antag_days_left

	return data

/datum/preference_middleware/antags/get_ui_assets()
	return list(
		get_asset_datum(/datum/asset/spritesheet/antagonists),
	)

/datum/preference_middleware/antags/proc/set_antags(list/params, mob/user)
	SHOULD_NOT_SLEEP(TRUE)

	var/sent_antags = params["antags"]
	var/toggled = params["toggled"]

	var/antags = list()

	var/serialized_antags = get_serialized_antags()

	for (var/sent_antag in sent_antags)
		var/special_role = serialized_antags[sent_antag]
		if (!special_role)
			continue

		antags += special_role

	if (toggled)
		preferences.be_special |= antags
	else
		preferences.be_special -= antags

	// This is predicted on the client
	return FALSE

/datum/preference_middleware/antags/proc/get_antag_bans()
	var/list/antag_bans = list()

	var/is_banned_from_all = is_banned_from(preferences.parent.ckey, ROLE_SYNDICATE)
	for (var/antag_flag in get_all_antag_flags())
		if (is_banned_from_all || is_banned_from(preferences.parent.ckey, antag_flag))
			antag_bans += serialize_antag_name(antag_flag)

	return antag_bans

/datum/preference_middleware/antags/proc/get_antag_days_left()
	if (!CONFIG_GET(flag/use_age_restriction_for_jobs))
		return

	var/list/antag_days_left = list()
	for (var/antag_flag in get_all_antag_flags())
		var/days_needed = preferences.parent?.get_days_to_play_antag(antag_flag) || 0
		if (days_needed > 0)
			antag_days_left[serialize_antag_name(antag_flag)] = days_needed

	return antag_days_left

/datum/preference_middleware/antags/proc/get_serialized_antags()
	var/list/serialized_antags

	if (isnull(serialized_antags))
		serialized_antags = list()

		for (var/special_role in get_all_antag_flags())
			serialized_antags[serialize_antag_name(special_role)] = special_role

	return serialized_antags

/**
 * Returns a list of all antag flags that are available to the player
 *
 * So this includes stuff like traitor, wizard, fugitive, but does not include wizard apprentice or hypnotized
 */
/proc/get_all_antag_flags() as /list
	var/static/list/antag_flags
	if(antag_flags)
		return antag_flags

	var/list/ruleset_antags = list()
	for(var/datum/dynamic_ruleset/ruleset as anything in subtypesof(/datum/dynamic_ruleset))
		var/antag_flag = initial(ruleset.pref_flag)
		var/jobban_flag = initial(ruleset.jobban_flag)

		if(antag_flag)
			ruleset_antags |= antag_flag
		if(jobban_flag)
			ruleset_antags |= jobban_flag

	antag_flags = ruleset_antags | GLOB.non_ruleset_antagonists
	return antag_flags

/**
 * Returns the number of days more the client's account must be to play the passed in antag
 */
/client/proc/get_days_to_play_antag(checked_antag_flag)
	var/static/list/antag_time_limits
	if(!antag_time_limits)
		antag_time_limits = list()
		for(var/datum/dynamic_ruleset/ruleset as anything in subtypesof(/datum/dynamic_ruleset))
			var/antag_flag = initial(ruleset.pref_flag)
			var/config_min_days = SSdynamic.dynamic_config[initial(ruleset.config_tag)]?[NAMEOF(ruleset, minimum_required_age)]
			var/min_days = isnull(config_min_days) ? initial(ruleset.minimum_required_age) : config_min_days

			antag_time_limits[antag_flag] = min_days

	return get_remaining_days(antag_time_limits[checked_antag_flag] || 0)

/// Sprites generated for the antagonists panel
/datum/asset/spritesheet/antagonists
	name = "antagonists"
	early = TRUE

	/// Mapping of spritesheet keys -> icons
	var/list/antag_icons = list()

/datum/asset/spritesheet/antagonists/create_spritesheets()
	var/list/antagonists = GLOB.non_ruleset_antagonists.Copy()

	for (var/datum/dynamic_ruleset/ruleset as anything in subtypesof(/datum/dynamic_ruleset))
		var/datum/antagonist/antagonist_type = initial(ruleset.preview_antag_datum)
		var/antag_flag = initial(ruleset.pref_flag)
		if (isnull(antagonist_type) || isnull(antag_flag))
			continue

		// antag_flag is guaranteed to be unique by unit tests.
		antagonists[initial(ruleset.pref_flag)] = antagonist_type

	var/list/generated_icons = list()

	for (var/antag_flag in antagonists)
		var/datum/antagonist/antagonist_type = antagonists[antag_flag]

		// antag_flag is guaranteed to be unique by unit tests.
		var/spritesheet_key = serialize_antag_name(antag_flag)

		if (!isnull(generated_icons[antagonist_type]))
			antag_icons[spritesheet_key] = generated_icons[antagonist_type]
			continue

		var/datum/antagonist/antagonist = new antagonist_type
		var/icon/preview_icon = antagonist.get_preview_icon()

		if (isnull(preview_icon))
			continue

		qdel(antagonist)

		// preview_icons are not scaled at this stage INTENTIONALLY.
		// If an icon is not prepared to be scaled to that size, it looks really ugly, and this
		// makes it harder to figure out what size it *actually* is.
		generated_icons[antagonist_type] = preview_icon
		antag_icons[spritesheet_key] = preview_icon

	for (var/spritesheet_key in antag_icons)
		Insert(spritesheet_key, antag_icons[spritesheet_key])

/// Serializes an antag name to be used for preferences UI
/proc/serialize_antag_name(antag_name)
	// These are sent through CSS, so they need to be safe to use as class names.
	return LOWER_TEXT(sanitize_css_class_name(antag_name))
