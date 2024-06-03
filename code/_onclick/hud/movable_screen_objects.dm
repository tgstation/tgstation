
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

/atom/movable/screen/movable/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
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

ADMIN_VERB(test_movable_UI, R_DEBUG, "Spawn Movable UI Object", "Spawn a movable UI object for testing.", ADMIN_CATEGORY_DEBUG)
	var/atom/movable/screen/movable/M = new
	M.name = "Movable UI Object"
	M.icon_state = "block"
	M.maptext = MAPTEXT("Movable")
	M.maptext_width = 64

	var/screen_l = input(user, "Where on the screen? (Formatted as 'X,Y' e.g: '1,1' for bottom left)","Spawn Movable UI Object") as text|null
	if(!screen_l)
		return

	M.screen_loc = screen_l
	user.screen += M

ADMIN_VERB(test_snap_ui, R_DEBUG, "Spawn Snap UI Object", "Spawn a snap UI object for testing.", ADMIN_CATEGORY_DEBUG)
	var/atom/movable/screen/movable/snap/S = new
	S.name = "Snap UI Object"
	S.icon_state = "block"
	S.maptext = MAPTEXT("Snap")
	S.maptext_width = 64

	var/screen_l = input(user,"Where on the screen? (Formatted as 'X,Y' e.g: '1,1' for bottom left)","Spawn Snap UI Object") as text|null
	if(!screen_l)
		return

	S.screen_loc = screen_l
	user.screen += S
