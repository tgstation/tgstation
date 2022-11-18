#define MAX_HOTKEY_SLOTS 3

/// Middleware to handle keybindings
/datum/preference_middleware/keybindings
	action_delegations = list(
		"reset_all_keybinds" = .proc/reset_all_keybinds,
		"reset_keybinds_to_defaults" = .proc/reset_keybinds_to_defaults,
		"set_keybindings" = .proc/set_keybindings,
	)

/datum/preference_middleware/keybindings/get_ui_static_data(mob/user)
	if (preferences.current_window == PREFERENCE_TAB_CHARACTER_PREFERENCES)
		return list()

	var/list/keybindings = preferences.key_bindings

	return list(
		"keybindings" = keybindings,
	)

/datum/preference_middleware/keybindings/get_ui_assets()
	return list(
		get_asset_datum(/datum/asset/json/keybindings)
	)

/datum/preference_middleware/keybindings/proc/reset_all_keybinds(list/params, mob/user)
	preferences.key_bindings = deep_copy_list(GLOB.default_hotkeys)
	preferences.key_bindings_by_key = preferences.get_key_bindings_by_key(preferences.key_bindings)
	preferences.update_static_data(user)

	return TRUE

/datum/preference_middleware/keybindings/proc/reset_keybinds_to_defaults(list/params, mob/user)
	var/keybind_name = params["keybind_name"]
	var/datum/keybinding/keybinding = GLOB.keybindings_by_name[keybind_name]

	if (isnull(keybinding))
		return FALSE

	preferences.key_bindings[keybind_name] = preferences.parent.hotkeys ? keybinding.hotkey_keys : keybinding.classic_keys
	preferences.key_bindings_by_key = preferences.get_key_bindings_by_key(preferences.key_bindings)

	preferences.update_static_data(user)

	return TRUE

/datum/preference_middleware/keybindings/proc/set_keybindings(list/params)
	var/keybind_name = params["keybind_name"]

	if (isnull(GLOB.keybindings_by_name[keybind_name]))
		return FALSE

	var/list/raw_hotkeys = params["hotkeys"]
	if (!istype(raw_hotkeys))
		return FALSE

	if (raw_hotkeys.len > MAX_HOTKEY_SLOTS)
		return FALSE

	// There's no optimal, easy way to check if something is an array
	// and not an object in BYOND, so just sanitize it to make sure.
	var/list/hotkeys = list()
	for (var/hotkey in raw_hotkeys)
		if (!istext(hotkey))
			return FALSE

		// Fairly arbitrary number, it's just so you don't save enormous fake keybinds.
		if (length(hotkey) > 100)
			return FALSE

		hotkeys += hotkey

	preferences.key_bindings[keybind_name] = hotkeys
	preferences.key_bindings_by_key = preferences.get_key_bindings_by_key(preferences.key_bindings)

	return TRUE

/datum/asset/json/keybindings
	name = "keybindings"

/datum/asset/json/keybindings/generate()
	var/list/keybindings = list()

	for (var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/keybinding = GLOB.keybindings_by_name[name]

		if (!(keybinding.category in keybindings))
			keybindings[keybinding.category] = list()

		keybindings[keybinding.category][keybinding.name] = list(
			"name" = keybinding.full_name,
			"description" = keybinding.description,
		)

	return keybindings

#undef MAX_HOTKEY_SLOTS
