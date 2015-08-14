/atom/var/smooth = 0
/atom/var/top_left_corner
/atom/var/top_right_corner
/atom/var/bottom_left_corner
/atom/var/bottom_right_corner
/atom/var/can_be_unanchored = 0
/atom/var/list/canSmoothWith=list() // TYPE PATHS I CAN SMOOTH WITH~~~~~

//generic (by snowflake) tile smoothing code; smooth your icons with this!
/*
	Each tile is divided in 4 corners, each corner has an image associated to it; the tile is then overlayed by these 4 images
	To use this, just set your atom's 'smooth' var to 1. If your atom can be moved/unanchored, set its 'can_be_unanchored' var to 1.
	If you don't want your atom's icon to smooth with anything but atoms of the same type, set the list 'canSmoothWith' to null;
	Otherwise, put all types you want the atom icon to smooth with in 'canSmoothWith' INCLUDING THE TYPE OF THE ATOM ITSELF.

	Each atom has its own icon file with all the possible corner states. See 'smooth_wall.dmi' for a template.
*/

//Redefinitions of the diagonal directions so they can be stored in one var without conflicts
#define NORTH_EAST	16
#define NORTH_WEST	32
#define SOUTH_EAST	64
#define SOUTH_WEST	128

/proc/calculate_adjacencies(atom/A)
	var/adjacencies = 0

	if(A.can_be_unanchored)
		var/atom/movable/T = A
		if(!T.anchored)
			return 0

		for(var/direction in alldirs)
			var/atom/movable/AM = find_type_in_direction(A, direction)
			if(AM)
				if(AM.anchored)
					adjacencies |= transform_dir(direction)
	else
		for(var/direction in alldirs)
			if(find_type_in_direction(A, direction))
				adjacencies |= transform_dir(direction)
	return adjacencies

/proc/smooth_icon(atom/A)
	spawn(2)
		if(A && A.smooth)
			clear_overlays(A)
			var/adjacencies = calculate_adjacencies(A)

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
		else
			sdir = "i"
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
		else
			sdir = "i"
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
		else
			sdir = "i"
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
			else
				sdir = "i"
	return "4-[sdir]"

/proc/smooth_icon_neighbors(atom/A)
	for(var/atom/T in orange(1,A))
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

	var/list/siblings = source.canSmoothWith
	if(istype(source, /turf))
		if(siblings)
			for(var/a_type in siblings)
				if(ispath(a_type, /obj))
					var/atom/A = locate(a_type) in locate(source.x + x_offset, source.y + y_offset, source.z)
					if(A && A.type == a_type)
						return A
				else
					var/turf/T = locate(source.x + x_offset, source.y + y_offset, source.z)
					if(T.type == a_type)
						return T
			return null
		var/turf/T = locate(source.x + x_offset, source.y + y_offset, source.z)
		return T.type == source.type ? T : null

	if(siblings)
		for(var/a_type in siblings)
			if(ispath(a_type, /turf))
				var/turf/T = locate(source.x + x_offset, source.y + y_offset, source.z)
				if(T.type == a_type)
					return T
			else
				var/atom/A = locate(a_type) in locate(source.x + x_offset, source.y + y_offset, source.z)
				if(A && A.type == a_type)
					return A
		return null
	var/atom/A = locate(source.type) in locate(source.x + x_offset, source.y + y_offset, source.z)
	return A && A.type == source.type ? A : null

/proc/clear_overlays(atom/A)
	A.overlays -= A.top_left_corner
	A.overlays -= A.top_right_corner
	A.overlays -= A.bottom_right_corner
	A.overlays -= A.bottom_left_corner

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