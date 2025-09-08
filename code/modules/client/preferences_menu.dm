// Unrolled versions of DEFINE_VERB(), exists because src is set to client which fucks EVERYTHING up
// I HATE it here dude SO MUCH
/datum/verbs/menu/Preferences/verb/open_character_preferences()
	set name = "Open Character Preferences"
	set desc = "Open Character Preferences"
	set category = "OOC"
	SHOULD_NOT_OVERRIDE(TRUE)
	VERB_QUEUE_OR_FIRE_CUSTOM_ARGS(__open_preferences_window, GLOBAL_PROC, GLOBAL_PROC_REF, SSverb_manager, PREFERENCE_TAB_CHARACTER_PREFERENCES)

/datum/verbs/menu/Preferences/verb/open_game_preferences()
	set name = "Open Game Preferences"
	set desc = "Open Game Preferences"
	set category = "OOC"
	SHOULD_NOT_OVERRIDE(TRUE)
	VERB_QUEUE_OR_FIRE_CUSTOM_ARGS(__open_preferences_window, GLOBAL_PROC, GLOBAL_PROC_REF, SSverb_manager, PREFERENCE_TAB_GAME_PREFERENCES)

// I am sorry. I am so sorry.
/proc/__open_preferences_window(preference_tab)
	var/datum/preferences/preferences = usr?.client?.prefs
	if (!preferences)
		return

	preferences.current_window = preference_tab
	preferences.update_static_data(usr)
	preferences.ui_interact(usr)
