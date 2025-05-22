// Unrolled versions of DEFINE_VERB(), exists because src is set to client which fucks EVERYTHING up
// I HATE it here dude SO MUCH
/datum/verbs/menu/Preferences/verb/open_character_preferences()
	set name = "Open Character Preferences"
	set desc = "Open Character Preferences"
	set category = "OOC"
	SHOULD_NOT_OVERRIDE(TRUE)
	if(caller)
		__open_preferences_window(PREFERENCE_TAB_CHARACTER_PREFERENCES)
	else
		var/datum/verb_cost_tracker/__store_cost = new /datum/verb_cost_tracker(TICK_USAGE, callee)
		ASYNC
			__open_preferences_window(PREFERENCE_TAB_CHARACTER_PREFERENCES)
		__store_cost.usage_at_end = TICK_USAGE
		__store_cost.finished_on = world.time

/datum/verbs/menu/Preferences/verb/open_game_preferences()
	set name = "Open Game Preferences"
	set desc = "Open Game Preferences"
	set category = "OOC"
	SHOULD_NOT_OVERRIDE(TRUE)
	if(caller)
		__open_preferences_window(PREFERENCE_TAB_GAME_PREFERENCES)
	else
		var/datum/verb_cost_tracker/__store_cost = new /datum/verb_cost_tracker(TICK_USAGE, callee)
		ASYNC
			__open_preferences_window(PREFERENCE_TAB_GAME_PREFERENCES)
		__store_cost.usage_at_end = TICK_USAGE
		__store_cost.finished_on = world.time

// I am sorry. I am so sorry.
/proc/__open_preferences_window(preference_tab)
	var/datum/preferences/preferences = usr?.client?.prefs
	if (!preferences)
		return

	preferences.current_window = preference_tab
	preferences.update_static_data(usr)
	preferences.ui_interact(usr)
