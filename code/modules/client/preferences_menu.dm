/client/verb/open_character_preferences()
	set category = "OOC"
	set name = "Open Character Preferences"
	set desc = "Open Character Preferences"

	if(!pref)
		return

	prefs.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
	prefs.update_static_data(usr)
	prefs.ui_interact(usr)

/client/verb/open_game_preferences()
	set category = "OOC"
	set name = "Open Game Preferences"
	set desc = "Open Game Preferences"

	if(!pref)
		return
	prefs.current_window = PREFERENCE_TAB_GAME_PREFERENCES
	prefs.update_static_data(usr)
	prefs.ui_interact(usr)

