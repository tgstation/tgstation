/// UI style preference
/datum/preference/choiced/ui_style
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_identifier = PREFERENCE_PLAYER
	savefile_key = "UI_style"
	should_generate_icons = TRUE

/datum/preference/choiced/ui_style/init_possible_values()
	var/list/values = list()

	for (var/style in GLOB.available_hud_styles)
		var/datum/hud_style/hud_style = GLOB.available_hud_styles[style]

		var/icon/icon = hud_style.hand_icon("r")
		icon.Crop(1, 1, world.icon_size * 2, world.icon_size)
		icon.Blend(hud_style.hand_icon("l"), ICON_OVERLAY, world.icon_size)

		values[style] = icon

	return values

/datum/preference/choiced/ui_style/create_default_value()
	return GLOB.default_hud_style.name

/datum/preference/choiced/ui_style/apply_to_client(client/client, value)
	client.mob?.hud_used?.update_ui_style(GLOB.available_hud_styles[value])
