#define MAX_HOTKEY_SLOTS 3

/// Middleware to handle keybindings
/datum/preference_middleware/keybindings
	action_delegations = list(
		"reset_all_keybinds" = PROC_REF(reset_all_keybinds),
		"reset_keybinds_to_defaults" = PROC_REF(reset_keybinds_to_defaults),
		"set_keybindings" = PROC_REF(set_keybindings),
	)

#if DM_VERSION >= 516
#warn We're on a new BYOND version that (hopefully) has Webview2.
#warn Right now, it is quite likely that on the TGUI side, we are still parsing inputs from the 'ESC' key on a keyboard as "Esc" - likely a Internet Explorer oddity.
#warn It is highly probably that now that this will change to "Escape" - this will break the ability to unbind a key.
#warn So, if you're working on moving the codebase to 516: ensure that the TGUI to unbind a keybinding with the 'ESC' key works. Thank you!
#endif

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
	user.client.update_special_keybinds()

	return TRUE

/datum/preference_middleware/keybindings/proc/reset_keybinds_to_defaults(list/params, mob/user)
	var/keybind_name = params["keybind_name"]
	var/datum/keybinding/keybinding = GLOB.keybindings_by_name[keybind_name]

	if (isnull(keybinding))
		return FALSE

	preferences.key_bindings[keybind_name] = preferences.parent.hotkeys ? keybinding.hotkey_keys : keybinding.classic_keys
	preferences.key_bindings_by_key = preferences.get_key_bindings_by_key(preferences.key_bindings)

	preferences.update_static_data(user)
	user.client.update_special_keybinds()

	return TRUE

/datum/preference_middleware/keybindings/proc/set_keybindings(list/params, mob/user)
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

	user.client.update_special_keybinds()

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
