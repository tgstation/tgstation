/// UI style preference
/datum/preference/choiced/ui_style
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_identifier = PREFERENCE_PLAYER
	savefile_key = "UI_style"
	should_generate_icons = TRUE

/datum/preference/choiced/ui_style/init_possible_values()
	var/list/values = list()

	for (var/style in GLOB.available_ui_styles)
		var/icon/icons = GLOB.available_ui_styles[style]

		var/icon/icon = icon(icons, "hand_r")
		icon.Crop(1, 1, world.icon_size * 2, world.icon_size)
		icon.Blend(icon(icons, "hand_l"), ICON_OVERLAY, world.icon_size)

		values[style] = icon

	return values

/datum/preference/choiced/ui_style/create_default_value()
	return GLOB.available_ui_styles[1]

/datum/preference/choiced/ui_style/apply_to_client(client/client, value)
	client.mob?.hud_used?.update_ui_style(ui_style2icon(value))
