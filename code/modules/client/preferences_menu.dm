DEFINE_VERB(/client, open_character_preferences, "Open Character Preferences", "Open Character Preferences", FALSE, "OOC")
	if(!prefs)
		return
	prefs.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
	prefs.update_static_data(usr)
	prefs.ui_interact(usr)

DEFINE_VERB(/client, open_game_preferences, "Open Game Preferences", "Open Game Preferences", FALSE, "OOC")
	if(!prefs)
		return
	prefs.current_window = PREFERENCE_TAB_GAME_PREFERENCES
	prefs.update_static_data(usr)
	prefs.ui_interact(usr)

