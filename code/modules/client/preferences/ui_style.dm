/// UI style preference
/datum/preference/choiced/ui_style
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	savefile_identifier = PREFERENCE_PLAYER
	savefile_key = "UI_style"
	should_generate_icons = TRUE

/datum/preference/choiced/ui_style/init_possible_values()
	return assoc_to_keys(GLOB.available_ui_styles)

/datum/preference/choiced/ui_style/icon_for(value)
	var/icon/icons = GLOB.available_ui_styles[value]

	var/icon/icon = icon(icons, "hand_r")
	icon.Crop(1, 1, ICON_SIZE_X * 2, ICON_SIZE_Y)
	icon.Blend(icon(icons, "hand_l"), ICON_OVERLAY, ICON_SIZE_X)

	return icon

/datum/preference/choiced/ui_style/create_default_value()
	return GLOB.available_ui_styles[1]

/datum/preference/choiced/ui_style/apply_to_client(client/client, value)
	client.mob?.hud_used?.update_ui_style(ui_style2icon(value))
