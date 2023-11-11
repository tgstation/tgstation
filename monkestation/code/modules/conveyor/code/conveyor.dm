/obj/machinery/conveyor/auto/inside_corners //use me for mapping
	icon = 'monkestation/code/modules/conveyor/icons/conveyor.dmi'


/obj/machinery/conveyor/auto/inside_corners/update_move_direction()
	switch(dir)
		if(NORTH)
			forwards = NORTH
			backwards = SOUTH
		if(SOUTH)
			forwards = SOUTH
			backwards = NORTH
		if(EAST)
			forwards = EAST
			backwards = WEST
		if(WEST)
			forwards = WEST
			backwards = EAST
		if(NORTHEAST)
			forwards = NORTH
			backwards = WEST
		if(NORTHWEST)
			forwards = WEST
			backwards = SOUTH
		if(SOUTHEAST)
			forwards = EAST
			backwards = NORTH
		if(SOUTHWEST)
			forwards = SOUTH
			backwards = EAST
	if(inverted)
		var/temp = forwards
		forwards = backwards
		backwards = temp
	if(flipped)
		var/temp = forwards
		forwards = backwards
		backwards = temp
	if(operating == 1) //I dont want to redefine I am lazy
		movedir = forwards
	else
		movedir = backwards
	update()
