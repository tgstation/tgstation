/client/proc/create_dimension()
	set category = "Fun"
	set name = "Create Pocket Dimension"
	set desc = "Creates a new empty z level that contains a 'pocket dimension'"
	set hidden = 1
	if(!check_rights(R_FUN))
		return
	if(!ismob(movingmob))
		to_chat(movingmob,"<span class = 'warning'> You must be a mob to do this action!</span>")
		return
	GLOB.pocket_dimension_customizer.ui_interact(movingmob)
