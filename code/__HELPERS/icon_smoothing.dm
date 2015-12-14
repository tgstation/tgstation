//Redefinitions of the diagonal directions so they can be stored in one var without conflicts
#define NORTH_EAST	16
#define NORTH_WEST	32
#define SOUTH_EAST	64
#define SOUTH_WEST	128

#define SMOOTH_FALSE	0 //not smooth
#define SMOOTH_TRUE		1 //smooths with exact specified types or just itself
#define SMOOTH_MORE		2 //smooths with all subtypes of specified types or just itself

/atom/var/smooth = SMOOTH_FALSE
/atom/var/top_left_corner
/atom/var/top_right_corner
/atom/var/bottom_left_corner
/atom/var/bottom_right_corner
/atom/var/can_be_unanchored = 0
/atom/var/list/canSmoothWith = null // TYPE PATHS I CAN SMOOTH WITH~~~~~ If this is null and atom is smooth, it smooths only with itself

/atom/proc/clear_smooth_overlays()
	overlays -= top_left_corner
	overlays -= top_right_corner
	overlays -= bottom_right_corner
	overlays -= bottom_left_corner

//generic (by snowflake) tile smoothing code; smooth your icons with this!
/*
	Each tile is divided in 4 corners, each corner has an image associated to it; the tile is then overlayed by these 4 images
	To use this, just set your atom's 'smooth' var to 1. If your atom can be moved/unanchored, set its 'can_be_unanchored' var to 1.
	If you don't want your atom's icon to smooth with anything but atoms of the same type, set the list 'canSmoothWith' to null;
	Otherwise, put all types you want the atom icon to smooth with in 'canSmoothWith' INCLUDING THE TYPE OF THE ATOM ITSELF.

	Each atom has its own icon file with all the possible corner states. See 'smooth_wall.dmi' for a template.
*/

/proc/calculate_adjacencies(atom/A)
	if(!A.loc)
		return 0

	var/adjacencies = 0

	if(A.can_be_unanchored)
		var/atom/movable/AM = A
		if(!AM.anchored)
			return 0

		for(var/direction in alldirs)
			AM = find_type_in_direction(A, direction)
			if(istype(AM))
				if(AM.anchored)
					adjacencies |= transform_dir(direction)
			else
				if(AM)
					adjacencies |= transform_dir(direction)
	else
		for(var/direction in alldirs)
			if(find_type_in_direction(A, direction))
				adjacencies |= transform_dir(direction)
	return adjacencies

/proc/smooth_icon(atom/A)
	if(qdeleted(A))
		return
	spawn(0) //don't remove this, otherwise smoothing breaks
		if(A && A.smooth)
			var/adjacencies = calculate_adjacencies(A)

			A.clear_smooth_overlays()

			A.top_left_corner = make_nw_corner(adjacencies)
			A.top_right_corner = make_ne_corner(adjacencies)
			A.bottom_left_corner = make_sw_corner(adjacencies)
			A.bottom_right_corner = make_se_corner(adjacencies)

			A.overlays += A.top_left_corner
			A.overlays += A.top_right_corner
			A.overlays += A.bottom_right_corner
			A.overlays += A.bottom_left_corner

/proc/make_nw_corner(adjacencies)
	var/sdir = "i"
	if((adjacencies & NORTH) && (adjacencies & WEST))
		if(adjacencies & NORTH_WEST)
			sdir = "f"
		else
			sdir = "nw"
	else
		if(adjacencies & NORTH)
			sdir = "n"
		else if(adjacencies & WEST)
			sdir = "w"
	return "1-[sdir]"

/proc/make_ne_corner(adjacencies)
	var/sdir = "i"
	if((adjacencies & NORTH) && (adjacencies & EAST))
		if(adjacencies & NORTH_EAST)
			sdir = "f"
		else
			sdir = "ne"
	else
		if(adjacencies & NORTH)
			sdir = "n"
		else if(adjacencies & EAST)
			sdir = "e"
	return "2-[sdir]"

/proc/make_sw_corner(adjacencies)
	var/sdir = "i"
	if((adjacencies & SOUTH) && (adjacencies & WEST))
		if(adjacencies & SOUTH_WEST)
			sdir = "f"
		else
			sdir = "sw"
	else
		if(adjacencies & SOUTH)
			sdir = "s"
		else if(adjacencies & WEST)
			sdir = "w"
	return "3-[sdir]"

/proc/make_se_corner(adjacencies)
	var/sdir = "i"
	if((adjacencies & SOUTH) && (adjacencies & EAST))
		if(adjacencies & SOUTH_EAST)
			sdir = "f"
		else
			sdir = "se"
	else
		if(adjacencies & SOUTH)
			sdir = "s"
		else
			if(adjacencies & EAST)
				sdir = "e"
	return "4-[sdir]"

/proc/smooth_icon_neighbors(atom/A)
	for(var/V in orange(1,A))
		var/atom/T = V
		if(T.smooth)
			smooth_icon(T)

/proc/find_type_in_direction(atom/source, direction, range=1)
	var/x_offset = 0
	var/y_offset = 0

	if(direction & NORTH)
		y_offset = range
	else if(direction & SOUTH)
		y_offset -= range

	if(direction & EAST)
		x_offset = range
	else if(direction & WEST)
		x_offset -= range

	var/turf/target_turf = locate(source.x + x_offset, source.y + y_offset, source.z)
	if(source.canSmoothWith)
		var/atom/A
		if(source.smooth == SMOOTH_MORE)
			for(var/a_type in source.canSmoothWith)
				if( istype(target_turf, a_type) )
					return target_turf
				A = locate(a_type) in target_turf
				if(A)
					return A
			return null

		for(var/a_type in source.canSmoothWith)
			if(a_type == target_turf.type)
				return target_turf
			A = locate(a_type) in target_turf
			if(A && A.type == a_type)
				return A
		return null
	else
		if(isturf(source))
			return source.type == target_turf.type ? target_turf : null
		var/atom/A = locate(source.type) in target_turf
		return A && A.type == source.type ? A : null

/proc/transform_dir(direction)
	switch(direction)
		if(NORTH,SOUTH,EAST,WEST)
			return direction
		if(NORTHEAST)
			return NORTH_EAST
		if(NORTHWEST)
			return NORTH_WEST
		if(SOUTHEAST)
			return SOUTH_EAST
		if(SOUTHWEST)
			return SOUTH_WEST

//Icon smoothing helpers
/proc/smooth_zlevel(var/zlevel)
	var/list/away_turfs = block(locate(1, 1, zlevel), locate(world.maxx, world.maxy, zlevel))
	for(var/V in away_turfs)
		var/turf/T = V
		if(T.smooth)
			smooth_icon(T)
		for(var/R in T)
			var/atom/A = R
			if(A.smooth)
				smooth_icon(A)

/mob/proc/resmooth(times=1)
	var/list/L = block(locate(1, 1, z), locate(world.maxx, world.maxy, z))
	while(times)
		for(var/V in L)
			var/turf/T = V
			if(T.smooth)
				smooth_icon(T)
			for(var/R in T)
				var/atom/A = R
				if(A.smooth)
					smooth_icon(A)
		times--