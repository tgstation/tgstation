/datum/hotkeys_help
	var/static/list/hotkeys = list()

/datum/hotkeys_help/ui_state()
	return GLOB.always_state

/datum/hotkeys_help/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "HotkeysHelp")
		ui.open()

// Not static data since user could rebind keys.
/datum/hotkeys_help/ui_data(mob/user)
	// List every keybind to chat.
	var/list/keys_list = list()

	// Show them in alphabetical order by key
	var/list/key_bindings_by_key = user.client.prefs.key_bindings_by_key.Copy()
	sortTim(key_bindings_by_key, cmp = GLOBAL_PROC_REF(cmp_text_asc))

	for(var/key in key_bindings_by_key)
		// Get the full names
		var/list/binding_names = list()
		for(var/kb_name in key_bindings_by_key[key])
			var/datum/keybinding/binding = GLOB.keybindings_by_name[kb_name]
			binding_names += list(list(
				"name" = binding.full_name,
				"desc" = binding.description
			))

		// Add to list
		keys_list += list(list(
			"key" = key,
			"bindings" = binding_names
		))

	return list(
		"hotkeys" = keys_list
	)
