/client/verb/toggle_stat_panel()
	set name = "Toggle Stat Panel"
	set hidden = TRUE

	//Flip it
	prefs.write_preference(GLOB.preference_entries[/datum/preference/toggle/statpanel], !prefs.read_preference(/datum/preference/toggle/statpanel))
	set_stat_panel()

///Sets the stat panel's visibility to the player, depending on whether they need it/have it enabled or not.
/client/proc/set_stat_panel()
	if(prefs.read_preference(/datum/preference/toggle/statpanel) || needs_stat_panel())
		winset(src, "infowindow.info", "left=statwindow")
	else
		winset(src, "infowindow.info", "left=null")

///Returns TRUE if the player has something that necessitates the stat panel.
/client/proc/needs_stat_panel()
	if(holder)
		return TRUE
	. = mob.get_status_tab_items()
	return length(.) >= 2
