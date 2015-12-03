
//////////////////////////
//Movable Screen Objects//
//   By RemieRichards	//
//////////////////////////


//Movable Screen Object
//Not tied to the grid, places it's center where the cursor is

/obj/screen/movable
	var/snap2grid = FALSE


//Snap Screen Object
//Tied to the grid, snaps to the nearest turf

/obj/screen/movable/snap
	snap2grid = TRUE


/obj/screen/movable/MouseDrop(over_object, src_location, over_location, src_control, over_control, params)
	var/list/PM = params2list(params)

	//No screen-loc information? abort.
	if(!PM || !PM["screen-loc"])
		return

	//Split screen-loc up into X+Pixel_X and Y+Pixel_Y
	var/list/screen_loc_params = text2list(PM["screen-loc"], ",")

	//Split X+Pixel_X up into list(X, Pixel_X)
	var/list/screen_loc_X = text2list(screen_loc_params[1],":")
	screen_loc_X[1] = encode_screen_X(text2num(screen_loc_X[1]))
	//Split Y+Pixel_Y up into list(Y, Pixel_Y)
	var/list/screen_loc_Y = text2list(screen_loc_params[2],":")
	screen_loc_Y[1] = encode_screen_Y(text2num(screen_loc_Y[1]))

	if(snap2grid) //Discard Pixel Values
		screen_loc = "[screen_loc_X[1]],[screen_loc_Y[1]]"

	else //Normalise Pixel Values (So the object drops at the center of the mouse, not 16 pixels off)
		var/pix_X = text2num(screen_loc_X[2]) - 16
		var/pix_Y = text2num(screen_loc_Y[2]) - 16
		screen_loc = "[screen_loc_X[1]]:[pix_X],[screen_loc_Y[1]]:[pix_Y]"

/obj/screen/movable/proc/get_view_size()
	if(usr && usr.client)
		. = usr.client.view
	else
		. = world.view

/obj/screen/movable/spell_master/get_view_size()
	if(spell_holder && spell_holder.client)
		. = spell_holder.client.view
	else if(usr && usr.client)
		. = usr.client.view
	else
		. = world.view

/obj/screen/movable/proc/encode_screen_X(X)
	var/view = get_view_size()
	if(X > view+1)
		. = "EAST-[view*2 + 1-X]"
	else if(X < view+1)
		. = "WEST+[X-1]"
	else
		. = "CENTER"

/obj/screen/movable/proc/decode_screen_X(X)
	//Find EAST/WEST implementations
	var/view = get_view_size()
	if(findtext(X,"EAST-"))
		var/num = text2num(copytext(X,6)) //Trim EAST-
		if(!num)
			num = 0
		. = view*2 + 1 - num
	else if(findtext(X,"WEST+"))
		var/num = text2num(copytext(X,6)) //Trim WEST+
		if(!num)
			num = 0
		. = num+1
	else if(findtext(X,"CENTER"))
		. = view+1

/obj/screen/movable/proc/encode_screen_Y(Y)
	var/view = get_view_size()
	if(Y > view+1)
		. = "NORTH-[view*2 + 1-Y]"
	else if(Y < view+1)
		. = "SOUTH+[Y-1]"
	else
		. = "CENTER"

/obj/screen/movable/proc/decode_screen_Y(Y)
	var/view = get_view_size()
	if(findtext(Y,"NORTH-"))
		var/num = text2num(copytext(Y,7)) //Trim NORTH-
		if(!num)
			num = 0
		. = view*2 + 1 - num
	else if(findtext(Y,"SOUTH+"))
		var/num = text2num(copytext(Y,7)) //Time SOUTH+
		if(!num)
			num = 0
		. = num+1
	else if(findtext(Y,"CENTER"))
		. = view+1

//Debug procs
/client/proc/test_movable_UI()
	set category = "Debug"
	set name = "Spawn Movable UI Object"

	var/obj/screen/movable/M = new()
	M.name = "Movable UI Object"
	M.icon_state = "block"
	M.maptext = "Movable"
	M.maptext_width = 64

	var/screen_l = input(usr,"Where on the screen? (Formatted as 'X,Y' e.g: '1,1' for bottom left)","Spawn Movable UI Object") as text
	if(!screen_l)
		return

	M.screen_loc = screen_l

	screen += M


/client/proc/test_snap_UI()
	set category = "Debug"
	set name = "Spawn Snap UI Object"

	var/obj/screen/movable/snap/S = new()
	S.name = "Snap UI Object"
	S.icon_state = "block"
	S.maptext = "Snap"
	S.maptext_width = 64

	var/screen_l = input(usr,"Where on the screen? (Formatted as 'X,Y' e.g: '1,1' for bottom left)","Spawn Snap UI Object") as text
	if(!screen_l)
		return

	S.screen_loc = screen_l

	screen += S