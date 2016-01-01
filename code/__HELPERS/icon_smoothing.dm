//Redefinitions of the diagonal directions so they can be stored in one var without conflicts
#define N_NORTH	2
#define N_SOUTH	4
#define N_EAST	16
#define N_WEST	256
#define N_NORTHEAST	32
#define N_NORTHWEST	512
#define N_SOUTHEAST	64
#define N_SOUTHWEST	1024

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
					adjacencies |= 1 << direction
			else
				if(AM)
					adjacencies |= 1 << direction
	else
		for(var/direction in alldirs)
			if(find_type_in_direction(A, direction))
				adjacencies |= 1 << direction
	return adjacencies

/proc/smooth_icon(atom/A)
	if(qdeleted(A))
		return
	spawn(0) //don't remove this, otherwise smoothing breaks
		if(A && A.smooth)
			var/adjacencies = calculate_adjacencies(A)

			//NW CORNER
			var/nw = "1-i"
			if((adjacencies & N_NORTH) && (adjacencies & N_WEST))
				if(adjacencies & N_NORTHWEST)
					nw = "1-f"
				else
					nw = "1-nw"
			else
				if(adjacencies & N_NORTH)
					nw = "1-n"
				else if(adjacencies & N_WEST)
					nw = "1-w"

			//NE CORNER
			var/ne = "2-i"
			if((adjacencies & N_NORTH) && (adjacencies & N_EAST))
				if(adjacencies & N_NORTHEAST)
					ne = "2-f"
				else
					ne = "2-ne"
			else
				if(adjacencies & N_NORTH)
					ne = "2-n"
				else if(adjacencies & N_EAST)
					ne = "2-e"

			//SW CORNER
			var/sw = "3-i"
			if((adjacencies & N_SOUTH) && (adjacencies & N_WEST))
				if(adjacencies & N_SOUTHWEST)
					sw = "3-f"
				else
					sw = "3-sw"
			else
				if(adjacencies & N_SOUTH)
					sw = "3-s"
				else if(adjacencies & N_WEST)
					sw = "3-w"

			//SE CORNER
			var/se = "4-i"
			if((adjacencies & N_SOUTH) && (adjacencies & N_EAST))
				if(adjacencies & N_SOUTHEAST)
					se = "4-f"
				else
					se = "4-se"
			else
				if(adjacencies & N_SOUTH)
					se = "4-s"
				else if(adjacencies & N_EAST)
					se = "4-e"

			if(A.top_left_corner != nw)
				A.overlays -= A.top_left_corner
				A.top_left_corner = nw
				A.overlays += nw

			if(A.top_right_corner != ne)
				A.overlays -= A.top_right_corner
				A.top_right_corner = ne
				A.overlays += ne

			if(A.bottom_right_corner != sw)
				A.overlays -= A.bottom_right_corner
				A.bottom_right_corner = sw
				A.overlays += sw

			if(A.bottom_left_corner != se)
				A.overlays -= A.bottom_left_corner
				A.bottom_left_corner = se
				A.overlays += se

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

//Icon smoothing helpers

/proc/smooth_icon_neighbors(atom/A)
	for(var/V in orange(1,A))
		var/atom/T = V
		if(T.smooth)
			smooth_icon(T)

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

/atom/proc/clear_smooth_overlays()
	overlays -= top_left_corner
	top_left_corner = null
	overlays -= top_right_corner
	top_right_corner = null
	overlays -= bottom_right_corner
	bottom_right_corner = null
	overlays -= bottom_left_corner
	bottom_left_corner = null
