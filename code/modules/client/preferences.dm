GLOBAL_LIST_EMPTY(preferences_datums)

/datum/preferences
	var/client/parent
	/// The path to the general savefile for this datum
	var/path
	/// Whether or not we allow saving/loading. Used for guests, if they're enabled
	var/load_and_save = TRUE
	/// Ensures that we always load the last used save, QOL
	var/default_slot = 1
	/// The maximum number of slots we're allowed to contain
	var/max_save_slots = 3

	/// Bitflags for communications that are muted
	var/muted = NONE
	/// Last IP that this client has connected from
	var/last_ip
	/// Last CID that this client has connected from
	var/last_id

	/// Cached changelog size, to detect new changelogs since last join
	var/lastchangelog = ""

	/// List of ROLE_X that the client wants to be eligible for
	var/list/be_special = list() //Special role selection

	/// Custom keybindings. Map of keybind names to keyboard inputs.
	/// For example, by default would have "swap_hands" -> list("X")
	var/list/key_bindings = list()

	/// Cached list of keybindings, mapping keys to actions.
	/// For example, by default would have "X" -> list("swap_hands")
	var/list/key_bindings_by_key = list()

	var/toggles = TOGGLES_DEFAULT
	var/db_flags
	var/chat_toggles = TOGGLES_DEFAULT_CHAT
	var/ghost_form = "ghost"

	//character preferences
	var/slot_randomized //keeps track of round-to-round randomization of the character slot, prevents overwriting

	var/list/randomise = list()

	//Quirk list
	var/list/all_quirks = list()

	//Job preferences 2.0 - indexed by job title , no key or value implies never
	var/list/job_preferences = list()

	/// The current window, PREFERENCE_TAB_* in [`code/__DEFINES/preferences.dm`]
	var/current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES

	var/unlock_content = 0

	var/list/ignoring = list()

	var/list/exp = list()

	var/action_buttons_screen_locs = list()

	///Someone thought we were nice! We get a little heart in OOC until we join the server past the below time (we can keep it until the end of the round otherwise)
	var/hearted
	///If we have a hearted commendations, we honor it every time the player loads preferences until this time has been passed
	var/hearted_until
	///What outfit typepaths we've favorited in the SelectEquipment menu
	var/list/favorite_outfits = list()

	/// A preview of the current character
	var/atom/movable/screen/map_view/char_preview/character_preview_view

	/// A list of instantiated middleware
	var/list/datum/preference_middleware/middleware = list()

	/// The json savefile for this datum
	var/datum/json_savefile/savefile

	/// A map of error bitflags to values that caused the error
	var/last_import_error_map

	/// The savefile relating to character preferences, PREFERENCE_CHARACTER
	var/list/character_data

	/// A list of keys that have been updated since the last save.
	var/list/recently_updated_keys = list()

	/// A cache of preference entries to values.
	/// Used to avoid expensive READ_FILE every time a preference is retrieved.
	var/value_cache = list()

	/// If set to TRUE, will update character_profiles on the next ui_data tick.
	var/tainted_character_profiles = FALSE

/datum/preferences/Destroy(force, ...)
	QDEL_NULL(character_preview_view)
	QDEL_LIST(middleware)
	value_cache = null
	return ..()

/datum/preferences/New(client/parent)
	src.parent = parent

	for (var/middleware_type in subtypesof(/datum/preference_middleware))
		middleware += new middleware_type(src)

	if(IS_CLIENT_OR_MOCK(parent))
		load_and_save = !is_guest_key(parent.key)
		load_path(parent.ckey)
		if(load_and_save && !fexists(path))
			try_savefile_type_migration()
		unlock_content = !!parent.IsByondMember()
		if(unlock_content)
			max_save_slots = 8
	else
		CRASH("attempted to create a preferences datum without a client or mock!")
	load_savefile()

	// give them default keybinds and update their movement keys
	key_bindings = deep_copy_list(GLOB.default_hotkeys)
	key_bindings_by_key = get_key_bindings_by_key(key_bindings)
	randomise = get_default_randomization()

	var/loaded_preferences_successfully = load_preferences()
	if(loaded_preferences_successfully)
		if(load_character())
			return
	//we couldn't load character data so just randomize the character appearance + name
	randomise_appearance_prefs() //let's create a random character then - rather than a fat, bald and naked man.
	if(parent)
		apply_all_client_preferences()
		parent.set_macros()

	if(!loaded_preferences_successfully)
		save_preferences()
	save_character() //let's save this new random character so it doesn't keep generating new ones.

/datum/preferences/ui_interact(mob/user, datum/tgui/ui)
	// There used to be code here that readded the preview view if you "rejoined"
	// I'm making the assumption that ui close will be called whenever a user logs out, or loses a window
	// If this isn't the case, kill me and restore the code, thanks

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		character_preview_view = create_character_preview_view(user)

		ui = new(user, src, "PreferencesMenu")
		ui.set_autoupdate(FALSE)
		ui.open()

		// HACK: Without this the character starts out really tiny because of some BYOND bug.
		// You can fix it by changing a preference, so let's just forcably update the body to emulate this.
		// Lemon from the future: this issue appears to replicate if the byond map (what we're relaying here)
		// Is shown while the client's mouse is on the screen. As soon as their mouse enters the main map, it's properly scaled
		// I hate this place
		addtimer(CALLBACK(character_preview_view, TYPE_PROC_REF(/atom/movable/screen/map_view/char_preview, update_body)), 1 SECONDS)

/datum/preferences/ui_state(mob/user)
	return GLOB.always_state

// Without this, a hacker would be able to edit other people's preferences if
// they had the ref to Topic to.
/datum/preferences/ui_status(mob/user, datum/ui_state/state)
	return user.client == parent ? UI_INTERACTIVE : UI_CLOSE

/datum/preferences/ui_data(mob/user)
	var/list/data = list()

	if (tainted_character_profiles)
		data["character_profiles"] = create_character_profiles()
		tainted_character_profiles = FALSE

	data["character_preferences"] = compile_character_preferences(user)

	data["active_slot"] = default_slot

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		data += preference_middleware.get_ui_data(user)

	return data

/datum/preferences/ui_static_data(mob/user)
	var/list/data = list()

	data["character_profiles"] = create_character_profiles()

	data["character_preview_view"] = character_preview_view.assigned_map
	data["overflow_role"] = SSjob.GetJobType(SSjob.overflow_role).title
	data["window"] = current_window

	data["content_unlocked"] = unlock_content

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		data += preference_middleware.get_ui_static_data(user)

	return data

/datum/preferences/ui_assets(mob/user)
	var/list/assets = list(
		get_asset_datum(/datum/asset/spritesheet/preferences),
		get_asset_datum(/datum/asset/json/preferences),
	)

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		assets += preference_middleware.get_ui_assets()

	return assets

/datum/preferences/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if (.)
		return

	switch (action)
		if ("change_slot")
			// Save existing character
			save_character()

			// SAFETY: `load_character` performs sanitization the slot number
			if (!load_character(params["slot"]))
				tainted_character_profiles = TRUE
				randomise_appearance_prefs()
				save_character()

			for (var/datum/preference_middleware/preference_middleware as anything in middleware)
				preference_middleware.on_new_character(usr)

			character_preview_view.update_body()

			return TRUE
		if ("rotate")
			character_preview_view.dir = turn(character_preview_view.dir, -90)

			return TRUE
		if ("set_preference")
			var/requested_preference_key = params["preference"]
			var/value = params["value"]

			for (var/datum/preference_middleware/preference_middleware as anything in middleware)
				if (preference_middleware.pre_set_preference(usr, requested_preference_key, value))
					return TRUE

			var/datum/preference/requested_preference = GLOB.preference_entries_by_key[requested_preference_key]
			if (isnull(requested_preference))
				return FALSE

			// SAFETY: `update_preference` performs validation checks
			if (!update_preference(requested_preference, value))
				return FALSE

			if (istype(requested_preference, /datum/preference/name))
				tainted_character_profiles = TRUE

			return TRUE
		if ("set_color_preference")
			var/requested_preference_key = params["preference"]

			var/datum/preference/requested_preference = GLOB.preference_entries_by_key[requested_preference_key]
			if (isnull(requested_preference))
				return FALSE

			if (!istype(requested_preference, /datum/preference/color))
				return FALSE

			var/default_value = read_preference(requested_preference.type)

			// Yielding
			var/new_color = input(
				usr,
				"Select new color",
				null,
				default_value || COLOR_WHITE,
			) as color | null

			if (!new_color)
				return FALSE

			if (!update_preference(requested_preference, new_color))
				return FALSE

			return TRUE

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		var/delegation = preference_middleware.action_delegations[action]
		if (!isnull(delegation))
			return call(preference_middleware, delegation)(params, usr)

	return FALSE

/datum/preferences/ui_close(mob/user)
	save_character()
	save_preferences()
	QDEL_NULL(character_preview_view)

/datum/preferences/Topic(href, list/href_list)
	. = ..()
	if (.)
		return

	if (href_list["open_keybindings"])
		current_window = PREFERENCE_TAB_KEYBINDINGS
		update_static_data(usr)
		ui_interact(usr)
		return TRUE

/datum/preferences/proc/create_character_preview_view(mob/user)
	character_preview_view = new(null, src)
	character_preview_view.generate_view("character_preview_[REF(character_preview_view)]")
	character_preview_view.update_body()
	character_preview_view.display_to(user)

	return character_preview_view

/datum/preferences/proc/compile_character_preferences(mob/user)
	var/list/preferences = list()

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (!preference.is_accessible(src))
			continue

		LAZYINITLIST(preferences[preference.category])

		var/value = read_preference(preference.type)
		var/data = preference.compile_ui_data(user, value)

		preferences[preference.category][preference.savefile_key] = data

	for (var/datum/preference_middleware/preference_middleware as anything in middleware)
		var/list/append_character_preferences = preference_middleware.get_character_preferences(user)
		if (isnull(append_character_preferences))
			continue

		for (var/category in append_character_preferences)
			if (category in preferences)
				preferences[category] += append_character_preferences[category]
			else
				preferences[category] = append_character_preferences[category]

	return preferences

/// Applies all PREFERENCE_PLAYER preferences
/datum/preferences/proc/apply_all_client_preferences()
	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (preference.savefile_identifier != PREFERENCE_PLAYER)
			continue

		value_cache -= preference.type
		preference.apply_to_client(parent, read_preference(preference.type))

/// A preview of a character for use in the preferences menu
/atom/movable/screen/map_view/char_preview
	name = "character_preview"

	/// The body that is displayed
	var/mob/living/carbon/human/dummy/body
	/// The preferences this refers to
	var/datum/preferences/preferences

/atom/movable/screen/map_view/char_preview/Initialize(mapload, datum/preferences/preferences)
	. = ..()
	src.preferences = preferences

/atom/movable/screen/map_view/char_preview/Destroy()
	QDEL_NULL(body)
	preferences?.character_preview_view = null
	preferences = null
	return ..()

/// Updates the currently displayed body
/atom/movable/screen/map_view/char_preview/proc/update_body()
	if (isnull(body))
		create_body()
	else
		body.wipe_state()
	appearance = preferences.render_new_preview_appearance(body)

/atom/movable/screen/map_view/char_preview/proc/create_body()
	QDEL_NULL(body)

	body = new

	// Without this, it doesn't show up in the menu
	body.appearance_flags &= ~KEEP_TOGETHER

/datum/preferences/proc/create_character_profiles()
	var/list/profiles = list()

	for (var/index in 1 to max_save_slots)
		// It won't be updated in the savefile yet, so just read the name directly
		if (index == default_slot)
			profiles += read_preference(/datum/preference/name/real_name)
			continue

		var/tree_key = "character[index]"
		var/save_data = savefile.get_entry(tree_key)
		var/name = save_data?["real_name"]

		if (isnull(name))
			profiles += null
			continue

		profiles += name

	return profiles

/datum/preferences/proc/set_job_preference_level(datum/job/job, level)
	if (!job)
		return FALSE

	if(level > JP_HIGH || level < 0)
		return FALSE

	if(level == JP_HIGH)
		var/datum/job/overflow_role = SSjob.overflow_role
		var/overflow_role_title = initial(overflow_role.title)

		for(var/other_job in job_preferences)
			var/other_job_priority = job_preferences[other_job]
			if(other_job_priority != JP_HIGH)
				continue

			if(other_job == overflow_role_title)
				job_preferences[other_job] = null
			else
				job_preferences[other_job] = JP_MEDIUM

	if(level)
		job_preferences[job.title] = level
	else
		job_preferences -= job.title

	return TRUE

/datum/preferences/proc/GetQuirkBalance()
	var/bal = 0
	for(var/V in all_quirks)
		var/datum/quirk/T = SSquirks.quirks[V]
		bal -= initial(T.value)
	return bal

/datum/preferences/proc/GetPositiveQuirkCount()
	. = 0
	for(var/q in all_quirks)
		if(SSquirks.quirk_points[q] > 0)
			.++

/datum/preferences/proc/validate_quirks()
	if(GetQuirkBalance() < 0)
		all_quirks = list()

/// Sanitizes the preferences, applies the randomization prefs, and then applies the preference to the human mob.
/datum/preferences/proc/safe_transfer_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE, is_antag = FALSE)
	apply_character_randomization_prefs(is_antag)
	apply_prefs_to(character, icon_updates)

/// Applies the given preferences to a human mob.
/datum/preferences/proc/apply_prefs_to(mob/living/carbon/human/character, icon_updates = TRUE)
	character.dna.features = list()

	for (var/datum/preference/preference as anything in get_preferences_in_priority_order())
		if (preference.savefile_identifier != PREFERENCE_CHARACTER)
			continue

		preference.apply_to_human(character, read_preference(preference.type))

	character.dna.real_name = character.real_name

	if(icon_updates)
		character.icon_render_keys = list()
		character.update_body(is_creating = TRUE)


/// Returns whether the parent mob should have the random hardcore settings enabled. Assumes it has a mind.
/datum/preferences/proc/should_be_random_hardcore(datum/job/job, datum/mind/mind)
	if(!read_preference(/datum/preference/toggle/random_hardcore))
		return FALSE
	if(job.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND) //No command staff
		return FALSE
	for(var/datum/antagonist/antag as anything in mind.antag_datums)
		if(antag.get_team()) //No team antags
			return FALSE
	return TRUE

/// Inverts the key_bindings list such that it can be used for key_bindings_by_key
/datum/preferences/proc/get_key_bindings_by_key(list/key_bindings)
	var/list/output = list()

	for (var/action in key_bindings)
		for (var/key in key_bindings[action])
			LAZYADD(output[key], action)

	return output

/// Returns the default `randomise` variable ouptut
/datum/preferences/proc/get_default_randomization()
	var/list/default_randomization = list()

	for (var/preference_key in GLOB.preference_entries_by_key)
		var/datum/preference/preference = GLOB.preference_entries_by_key[preference_key]
		if (preference.is_randomizable() && preference.randomize_by_default)
			default_randomization[preference_key] = RANDOM_ENABLED

	return default_randomization

/datum/preferences/proc/handle_client_importing(raw_data)
	if(IsAdminAdvancedProcCall())
		return

	last_import_error_map = list()
	if(!istext(raw_data) || !length(raw_data))
		last_import_error_map[PREFERENCE_IMPORT_ERROR_INVALID_JSON] = TRUE
		return

	try
		raw_data = json_decode(raw_data)
	catch
		last_import_error_map[PREFERENCE_IMPORT_ERROR_INVALID_JSON] = TRUE
		return

	var/raw_data_version = raw_data["version"]
	var/imported_data_version = isnum(raw_data_version) ? raw_data_version : text2num(raw_data_version)
	if(imported_data_version < PREFERENCES_VERSION_MINIMUM)
		to_chat(parent, span_userdanger("Cannot import this savefile, it is too old!"))
		last_import_error_map[PREFERENCE_IMPORT_ERROR_VERSION] += list(imported_data_version)
		return

	if(imported_data_version != PREFERENCES_VERSION_CURRENT)
		if(tgui_alert(
			parent,
			"Importing a savefile which is older, this might cause issues.",
			"Savefile Import",
			list("Attempt Import", "Cancel"),
		) != "Attempt Import")
			return

	var/static/regex/character_slot_regex = regex(@"^character[0-9]+$")
	for(var/data_key in raw_data)
		if(character_slot_regex.Find(data_key))
			var/slot_id = text2num(replacetext(data_key, "character", ""))
			if(slot_id <= max_save_slots)
				if(PREFERENCE_IMPORT_ERROR_NOT_ENOUGH_CHARACTER_SLOTS in last_import_error_map)
					var/new_value = max(
						last_import_error_map[PREFERENCE_IMPORT_ERROR_NOT_ENOUGH_CHARACTER_SLOTS],
						slot_id,
					)
					last_import_error_map[PREFERENCE_IMPORT_ERROR_NOT_ENOUGH_CHARACTER_SLOTS] = new_value
					continue

			var/list/character_data_raw = raw_data[data_key]
			load_character(slot_id)
			for(var/character_data_key in character_data_raw)
				if(handle_import_preference(character_data_key, character_data_raw[character_data_key], PREFERENCE_CHARACTER))
					continue
				last_import_error_map[PREFERENCE_IMPORT_ERROR_UNKNOWN_CHARACTER_DATA_KEY] += list(character_data_key)

			save_character()
			continue

		if(handle_import_preference(data_key, raw_data[data_key], PREFERENCE_PLAYER))
			continue

		if(handle_import_raw(data_key, raw_data[data_key]))
			continue

		last_import_error_map[PREFERENCE_IMPORT_ERROR_UNKNOWN_PLAYER_DATA_KEY] += list(data_key)

	// save and load to trigger full refresh on preferences
	save_preferences()
	load_preferences()

/// Handles importing data that isnt managed using preferences
/datum/preferences/proc/handle_import_raw(key, data)
	// keys that should not be overwritten when imported
	var/static/list/ignored_keys = list(
		"muted",
		"lastchangelog",
		"hearted_until",
		"version",
	)

	if(key in ignored_keys)
		return TRUE

	switch(key)
		if("default_slot")
			default_slot = sanitize_integer(data, 1, max_save_slots, initial(default_slot))
			return TRUE

		if("chat_toggles")
			chat_toggles = sanitize_integer(data, NONE, ~NONE, initial(toggles))
			return TRUE

		if("toggles")
			toggles = sanitize_integer(data, NONE, ~NONE, initial(toggles))
			return TRUE

		if("ignoring")
			ignoring = sort_list(SANITIZE_LIST(data))
			if(length(ignoring) >= 255)
				ignoring.len = 255
			return TRUE

		if("be_special")
			be_special = sanitize_be_special(SANITIZE_LIST(data))
			return TRUE

		if("favorite_outfits")
			var/list/parsed_favs = list()
			for(var/typetext in SANITIZE_LIST(data))
				var/datum/outfit/path = text2path(typetext)
				if(ispath(path)) //whatever typepath fails this check probably doesn't exist anymore
					parsed_favs += path
			favorite_outfits = unique_list(parsed_favs)
			return TRUE

		if("key_bindings")
			key_bindings = sanitize_keybindings(SANITIZE_LIST(data))
			key_bindings_by_key = get_key_bindings_by_key(key_bindings)
			return TRUE

/// Handles importing special preferences for characters
/datum/preferences/proc/handle_specialized_character_preference_import(key, data)
	switch(key)
		if("version") // we already checked this
			return TRUE

		if("randomise")
			randomise = list()
			var/datum/preference_middleware/random/randomization_handler = locate() in middleware
			data = SANITIZE_LIST(data)
			for(var/randomization_key in data)
				if(!randomization_handler.set_random_preference(randomization_key, data[randomization_key], parent.mob))
					last_import_error_map[PREFERENCE_IMPORT_ERROR_INVALID_VALUE_RANDOMIZATION_KEY] += list(randomization_key)
			return TRUE

		if("all_quirks")
			all_quirks = SANITIZE_LIST(data)
			for(var/quirk_type in all_quirks)
				if(!ispath(quirk_type, /datum/quirk))
					all_quirks -= quirk_type
					last_import_error_map[PREFERENCE_IMPORT_ERROR_INVALID_VALUE_QUIRK_TYPE] += list(quirk_type)
			return TRUE

		if("job_preferences")
			job_preferences = list()
			data = SANITIZE_LIST(data)
			for(var/job_title in data)
				var/datum/job/job = SSjob.name_occupations[job_title]
				if(isnull(job) || !set_job_preference_level(job, data[job_title]))
					last_import_error_map[PREFERENCE_IMPORT_ERROR_INVALID_VALUE_JOB_TITLE] += list(job_title)
					continue
			return TRUE

/// Handles the import of a preference based on its savefile key. Returns true if the savefile key exists
/datum/preferences/proc/handle_import_preference(key, data, expected_savefile_identifier)
	if(!(key in GLOB.preference_entries_by_key))
		if(handle_specialized_character_preference_import(key, data))
			return TRUE
		return FALSE

	var/datum/preference/prefence_instance = GLOB.preference_entries_by_key[key]
	if(prefence_instance.savefile_identifier != expected_savefile_identifier)
		last_import_error_map[PREFERENCE_IMPORT_ERROR_INVALID_SAVEFILE_IDENTIFIER] += list("[prefence_instance.savefile_identifier]) != [expected_savefile_identifier]")

	else if(!write_preference(prefence_instance, data))
		last_import_error_map[PREFERENCE_IMPORT_ERROR_INVALID_VALUE] += list(key)

	return TRUE

/datum/preferences/proc/display_import_errors(target)
	var/list/error_messages = list()
	for(var/error_key in last_import_error_map)
		// not always a list, but most are
		var/list/error_value = last_import_error_map[error_key]
		switch(error_key)
			if(PREFERENCE_IMPORT_ERROR_INVALID_JSON)
				error_messages += "The savefile was not valid JSON."

			if(PREFERENCE_IMPORT_ERROR_VERSION)
				error_messages += "The savefile was too old to import. Minimum version is [PREFERENCES_VERSION_MINIMUM], savefile version was [error_value]."

			if(PREFERENCE_IMPORT_ERROR_NOT_ENOUGH_CHARACTER_SLOTS)
				error_messages += "The savefile had a character slot that was too high. Maximum character slot is [max_save_slots], max imported savefile slot was [error_value]."

			if(PREFERENCE_IMPORT_ERROR_UNKNOWN_CHARACTER_DATA_KEY)
				error_messages += "The savefile had a character data key that was unknown. Key(s) were [english_list(error_value)]."

			if(PREFERENCE_IMPORT_ERROR_UNKNOWN_PLAYER_DATA_KEY)
				error_messages += "The savefile had a player data key that was unknown. Key(s) were [english_list(error_value)]."

			if(PREFERENCE_IMPORT_ERROR_INVALID_SAVEFILE_IDENTIFIER)
				error_messages += "The savefile had a preference with an invalid savefile identifier. [error_value.Join("|")]."

			if(PREFERENCE_IMPORT_ERROR_INVALID_VALUE)
				error_messages += "The savefile had a preference with an invalid value. Key(s) were [english_list(error_value)]."

			else
				stack_trace("unknown preference import error: [error_key]")
				error_messages += "An unknown error occured while importing the savefile. Please report this to a maintainer."

	if(length(error_messages))
		tgui_alert(target, "The savefile could not be imported. The following errors occured:\n[error_messages.Join("\n")]", "Savefile Import Errors")

/client/proc/export_preferences()
	set name = "Export Preferences"
	set desc = "Export your current preferences to a file."
	set category = "Preferences"
	ASSERT(prefs, "Client had a null pref datum!")
	prefs.savefile.export_json_to_client(usr, ckey)

/client/proc/import_preferences()
	set name = "Import Preferences"
	set desc = "Import your preferences from a json dump."
	set category = "Preferences"
	ASSERT(prefs, "Client had a null pref datum!")
	if(file_spam_check())
		return

	var/file = input(src, "Select the file to import") as file|null
	if(isnull(file))
		return

	var/data_raw = file2text(file)
	prefs.handle_client_importing(data_raw)
	if(length(prefs.last_import_error_map))
		prefs.display_import_errors(src)
