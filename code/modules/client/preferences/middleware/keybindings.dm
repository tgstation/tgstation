/// Middleware to handle keybindings
/datum/preference_middleware/keybindings

// MOTHBLOCKS TODO: Only when requested
/datum/preference_middleware/keybindings/get_ui_static_data(mob/user)
	var/list/keybindings = preferences.key_bindings

	return list(
		"keybindings" = keybindings,
	)

/datum/preference_middleware/keybindings/get_ui_assets()
	return list(
		get_asset_datum(/datum/asset/json/keybindings)
	)

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
