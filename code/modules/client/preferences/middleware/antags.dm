// Antagonists that don't have a dynamic ruleset, but do have a preference
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

	for (var/datum/dynamic_ruleset/dynamic_ruleset as anything in subtypesof(/datum/dynamic_ruleset))
		var/antag_flag = initial(dynamic_ruleset.antag_flag)
		var/antag_flag_override = initial(dynamic_ruleset.antag_flag_override)

		if (isnull(antag_flag))
			continue

		if (is_banned_from(preferences.parent.ckey, list(antag_flag_override || antag_flag, ROLE_SYNDICATE)))
			antag_bans += serialize_antag_name(antag_flag)

	for(var/antag_key in GLOB.non_ruleset_antagonists)
		var/datum/antagonist/antag = GLOB.non_ruleset_antagonists[antag_key]
		var/antag_flag = initial(antag.job_rank)
		if(is_banned_from(preferences.parent.ckey, list(antag_flag, ROLE_SYNDICATE)))
			antag_bans += serialize_antag_name(antag_flag)

	return antag_bans

/datum/preference_middleware/antags/proc/get_antag_days_left()
	if (!CONFIG_GET(flag/use_age_restriction_for_jobs))
		return

	var/list/antag_days_left = list()

	for (var/datum/dynamic_ruleset/dynamic_ruleset as anything in subtypesof(/datum/dynamic_ruleset))
		var/antag_flag = initial(dynamic_ruleset.antag_flag)
		var/antag_flag_override = initial(dynamic_ruleset.antag_flag_override)

		if (isnull(antag_flag))
			continue

		var/days_needed = preferences.parent?.get_remaining_days(
			GLOB.special_roles[antag_flag_override || antag_flag]
		)

		if (days_needed > 0)
			antag_days_left[serialize_antag_name(antag_flag)] = days_needed

	for(var/antag_key in GLOB.non_ruleset_antagonists)
		var/datum/antagonist/antag = GLOB.non_ruleset_antagonists[antag_key]
		var/antag_flag = initial(antag.job_rank)
		
		var/days_needed = preferences.parent?.get_remaining_days(
			GLOB.special_roles[antag_flag]
		)

		if (days_needed > 0)
			antag_days_left[serialize_antag_name(antag_flag)] = days_needed

	return antag_days_left

/datum/preference_middleware/antags/proc/get_serialized_antags()
	var/list/serialized_antags

	if (isnull(serialized_antags))
		serialized_antags = list()

		for (var/special_role in GLOB.special_roles)
			serialized_antags[serialize_antag_name(special_role)] = special_role

	return serialized_antags

/// Sprites generated for the antagonists panel
/datum/asset/spritesheet/antagonists
	name = "antagonists"
	early = TRUE

	/// Mapping of spritesheet keys -> icons
	var/list/antag_icons = list()

/datum/asset/spritesheet/antagonists/create_spritesheets()
	var/list/antagonists = GLOB.non_ruleset_antagonists.Copy()

	for (var/datum/dynamic_ruleset/ruleset as anything in subtypesof(/datum/dynamic_ruleset))
		var/datum/antagonist/antagonist_type = initial(ruleset.antag_datum)
		if (isnull(antagonist_type))
			continue

		// antag_flag is guaranteed to be unique by unit tests.
		antagonists[initial(ruleset.antag_flag)] = antagonist_type

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
