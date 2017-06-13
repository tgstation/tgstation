/client/verb/enable_tips()
	set name = "Toggle examine tooltips"
	set desc = "Toggles examine hover-over tooltips"
	set category = "OOC"

	if(prefs.enable_tips)
		prefs.enable_tips = FALSE
	else
		prefs.enable_tips = TRUE