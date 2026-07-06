GAME_VERB_DESC(/client, open_character_preferences, "Open Character Preferences", "Open Character Preferences", "OOC")

	if(!prefs)
		return
	prefs.current_window = PREFERENCE_TAB_CHARACTER_PREFERENCES
	prefs.update_static_data(usr)
	prefs.ui_interact(usr)

GAME_VERB_DESC(/client, open_game_preferences, "Open Game Preferences", "Open Game Preferences", "OOC")

	if(!prefs)
		return
	prefs.current_window = PREFERENCE_TAB_GAME_PREFERENCES
	prefs.update_static_data(usr)
	prefs.ui_interact(usr)

