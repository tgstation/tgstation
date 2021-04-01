

////VARS FOR ISOMETRICS
/world
	map_format = ISOMETRIC_MAP
	icon_size = 64

////FLATS//// -things that should be flat
/atom/proc/flatify()
	// 32 icon size
	//transform = matrix(0.5, 0.5, 0, -0.25, 0.25, 0)
	transform = matrix(1, 1, 0, -0.5, 0.5, 0)


////WALLMOUNTS//// -things that should be flat, but on a wall. (it's blockify but no top)

///only call this on things with at least some pixel_x or pixel_y
/atom/proc/wallmountify()

	var/skip_right = FALSE
	var/skip_left = FALSE

	//i bet math could do this but i lack many skills
	if(pixel_y > 0)
		pixel_y = 64
	else if(pixel_y < 0)
		pixel_y = -64
	else
		skip_left = TRUE // dont draw left side
	if(pixel_x > 0)
		pixel_x = 64
	else if(pixel_x < 0)
		pixel_x = -64
	else
		skip_right = TRUE // dont draw right side

	if(skip_left && skip_right) //for things with no pixel_x we just add both
		var/mutable_appearance/right_side
		right_side = new(src)
		right_side.transform =  matrix(0, 1, 16, -1, 0.5, 8)
		right_side.appearance_flags |= RESET_TRANSFORM
		overlays += right_side
		transform = matrix(1, 0, -16, -0.5, 1, 8)
	if(skip_left)
		transform = matrix(0, 1, 16, -1, 0.5, 8)
	if(skip_right)
		transform = matrix(1, 0, -16, -0.5, 1, 8)

////TABLES//// -yeah only really for tables man. does some super cool stuff though read this proc
/atom/proc/tableify()

	//table icon but chopped to be only the table legs
	var/icon/table_legs = icon(icon, icon_state)
	table_legs.DrawBox(null,1,8,64,64)

	//table icon but chopped to be only the center
	var/icon/table_top = icon(icon, icon_state)
	table_top.DrawBox(null,1,(8),1,1)

	var/mutable_appearance/left_side
	left_side = new(table_legs)
	left_side.transform = matrix(1, 0, -16, -0.5, 1, 8)
	left_side.appearance_flags |= RESET_TRANSFORM
	var/mutable_appearance/right_side
	right_side = new(table_legs)
	var/matrix/right_side_matrix = matrix()
	right_side_matrix.Turn(-90)
	right_side_matrix.Multiply(matrix(0, 1, 16, -1, 0.5, 4))
	right_side.transform = right_side_matrix
	right_side.appearance_flags |= RESET_TRANSFORM

	overlays += left_side
	overlays += right_side

	transform = matrix(1, 1, 0, -0.5, 0.5, 8) //top side, how high up the table is


////BLOCKS//// -things that should look 3d

#define NORTH_JUNCTION NORTH //(1<<0)
#define SOUTH_JUNCTION SOUTH //(1<<1)
#define EAST_JUNCTION EAST  //(1<<2)
#define WEST_JUNCTION WEST  //(1<<3)
#define NORTHEAST_JUNCTION (1<<4)
#define SOUTHEAST_JUNCTION (1<<5)
#define SOUTHWEST_JUNCTION (1<<6)
#define NORTHWEST_JUNCTION (1<<7)

#define AIRLOCK_DETERMINE_ORIENTATION(TYPEPATH) do { \
    for(var/TYPEPATH/object in orange(1, src)) { \
        if(src.x == object.x && src.y != object.y) { \
            airlock_orientation = EAST; \
            break; \
        }; \
    }; \
} while(FALSE);

/atom/proc/blockify()
	if(istype(src, /obj/machinery/door/airlock) && !istype(src, /obj/machinery/door/firedoor))
		// Check for connected objects
		var/airlock_orientation = NORTH
		AIRLOCK_DETERMINE_ORIENTATION(obj/machinery/door)
		AIRLOCK_DETERMINE_ORIENTATION(obj/structure/window)
		AIRLOCK_DETERMINE_ORIENTATION(turf/closed/wall)
		// Orient the door plane along NORTH or EAST axis
		var/matrix/airlock_transform
		if(airlock_orientation == NORTH)
			airlock_transform = matrix(1, 0, -16, -0.5, 1, 8)
			airlock_transform.Translate(16, 8)
		else
			airlock_transform = matrix(1, 0, 16, 0.5, 1, 8) // THIS ONE CHANGED
			airlock_transform.Translate(-16, 8)
		transform = airlock_transform
		return
	var/mutable_appearance/mut_app_a = new(src)
	var/mutable_appearance/mut_app_b = new(src) //quick maffs
	/* 32 icon_size transforms
	transform = matrix(0.5, 0.5, 0, -0.25, 0.25, 16) //top side
	mut_app_a.transform = matrix(0.5, 0, -8, -0.25, 0.5, 4) //left side
	mut_app_a.appearance_flags |= RESET_TRANSFORM
	mut_app_b.transform = matrix(0, 0.5, 8, -0.5, 0.25, 4) //right side
	mut_app_b.appearance_flags |= RESET_TRANSFORM
	*/

	// 64 icon_size transforms
	transform = matrix(1, 1, 0, -0.5, 0.5, 32) //top side
	mut_app_a.transform = matrix(1, 0, -16, -0.5, 1, 8) //left side
	mut_app_a.appearance_flags |= RESET_TRANSFORM
	mut_app_b.transform =  matrix(0, 1, 16, -1, 0.5, 8) //right side
	mut_app_b.appearance_flags |= RESET_TRANSFORM

	//Smoothing
	if(smoothing_flags & SMOOTH_BITMASK && !(smoothing_flags & SMOOTH_BORDER))
		var/side_junction = smoothing_junction
		side_junction &= ~(NORTH_JUNCTION|NORTHEAST_JUNCTION|NORTHWEST_JUNCTION)
		mut_app_a.icon_state = "[base_icon_state]-[side_junction]"
		side_junction = smoothing_junction
		side_junction &= ~(WEST_JUNCTION|SOUTHWEST_JUNCTION|NORTHWEST_JUNCTION)
		mut_app_b.icon_state = "[base_icon_state]-[side_junction]"
		/* Alternative smoothing method for less noise.
		var/side_junction = smoothing_junction
		side_junction |= NORTH_JUNCTION
		if(side_junction & WEST_JUNCTION)
			side_junction |= NORTHWEST_JUNCTION
		if(side_junction & EAST_JUNCTION)
			side_junction |= NORTHEAST_JUNCTION
		mut_app_a.icon_state = "[base_icon_state]-[side_junction]"
		side_junction = smoothing_junction
		side_junction |= WEST_JUNCTION
		if(side_junction & NORTH_JUNCTION)
			side_junction |= NORTHWEST_JUNCTION
		if(side_junction & SOUTH_JUNCTION)
			side_junction |= SOUTHWEST_JUNCTION
		mut_app_b.icon_state = "[base_icon_state]-[side_junction]"
		*/
	overlays += mut_app_a //There's a proc/macro for this
	overlays += mut_app_b

#undef NORTH_JUNCTION
#undef SOUTH_JUNCTION
#undef EAST_JUNCTION
#undef WEST_JUNCTION
#undef NORTHEAST_JUNCTION
#undef NORTHWEST_JUNCTION
#undef SOUTHEAST_JUNCTION
#undef SOUTHWEST_JUNCTION

