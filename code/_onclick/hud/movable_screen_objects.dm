
//////////////////////////
//Movable Screen Objects//
//   By RemieRichards //
//////////////////////////


//Movable Screen Object
//Not tied to the grid, places it's center where the cursor is

/atom/movable/screen/movable
	mouse_drag_pointer = 'icons/effects/mouse_pointers/screen_drag.dmi'
	var/snap2grid = FALSE
	var/x_off = -16
	var/y_off = -16

//Snap Screen Object
//Tied to the grid, snaps to the nearest turf

/atom/movable/screen/movable/snap
	snap2grid = TRUE

/atom/movable/screen/movable/MouseDrop(over_object, src_location, over_location, src_control, over_control, params)
	var/position = mouse_params_to_position(params)
	if(!position)
		return

	screen_loc = position

/// Takes mouse parmas as input, returns a string representing the appropriate mouse position
/atom/movable/screen/movable/proc/mouse_params_to_position(params)
	var/list/modifiers = params2list(params)

	//No screen-loc information? abort.
	if(!LAZYACCESS(modifiers, SCREEN_LOC))
		return
	var/client/our_client = usr.client
	var/list/offset	= screen_loc_to_offset(LAZYACCESS(modifiers, SCREEN_LOC))
	if(snap2grid) //Discard Pixel Values
		offset[1] = FLOOR(offset[1], world.icon_size) // drops any pixel offset
		offset[2] = FLOOR(offset[2], world.icon_size) // drops any pixel offset
	else //Normalise Pixel Values (So the object drops at the center of the mouse, not 16 pixels off)
		offset[1] += x_off
		offset[2] += y_off
	return offset_to_screen_loc(offset[1], offset[2], our_client?.view)
