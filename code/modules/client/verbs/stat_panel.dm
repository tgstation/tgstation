/client/verb/toggle_stat_panel()
	set name = "Toggle Stat Panel"
	set hidden = TRUE

	//Flip it
	prefs.write_preference(GLOB.preference_entries[/datum/preference/toggle/statpanel], !prefs.read_preference(/datum/preference/toggle/statpanel))
	set_stat_panel()

/client/proc/set_stat_panel()
	if(prefs.read_preference(/datum/preference/toggle/statpanel) || should_have_stat_panel())
		winset(src, "infowindow.info", "left=statwindow")
	else
		winset(src, "infowindow.info", "left=null")

/client/proc/should_have_stat_panel()
	if(holder)
		return TRUE
	. = mob.get_status_tab_items()
	. -= .[1] //remove the "offset unique stuff"
	return !!length(.)
