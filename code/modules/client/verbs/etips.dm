/client/verb/enable_tips()
	set name = "Toggle examine tooltips"
	set desc = "Toggles examine hover-over tooltips"
	set category = "OOC"

	if(GLOB.enable_examine_tips)
		GLOB.enable_examine_tips = FALSE
	else
		GLOB.enable_examine_tips = TRUE