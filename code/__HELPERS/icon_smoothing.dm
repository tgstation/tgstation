
//generic (by snowflake) tile smoothing code; smooth your icons with this!
/*
	Each tile is divided in 4 corners, each corner has an image associated to it; the tile is then overlayed by these 4 images
	To use this, just set your atom's 'smooth' var to 1. If your atom can be moved/unanchored, set its 'can_be_unanchored' var to 1.
	If you don't want your atom's icon to smooth with anything but atoms of the same type, set the list 'canSmoothWith' to null;
	Otherwise, put all types you want the atom icon to smooth with in 'canSmoothWith' INCLUDING THE TYPE OF THE ATOM ITSELF.

	Each atom has its own icon file with all the possible corner states. See 'smooth_wall.dmi' for a template.

	DIAGONAL SMOOTHING INSTRUCTIONS
	To make your atom smooth diagonally you need all the proper icon states (see 'smooth_wall.dmi' for a template) and
	to add the 'SMOOTH_DIAGONAL' flag to the atom's smooth var (in addition to either SMOOTH_TRUE or SMOOTH_MORE).

	For turfs, what appears under the diagonal corners depends on the turf that was in the same position previously: if you make a wall on
	a plating floor, you will see plating under the diagonal wall corner, if it was space, you will see space.

	If you wish to map a diagonal wall corner with a fixed underlay, you must configure the turf's 'fixed_underlay' list var, like so:
		fixed_underlay = list("icon"='icon_file.dmi', "icon_state"="iconstatename")
	A non null 'fixed_underlay' list var will skip copying the previous turf appearance and always use the list. If the list is
	not set properly, the underlay will default to regular floor plating.

	To see an example of a diagonal wall, see '/turf/closed/wall/shuttle' and its subtypes.
*/

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
#define SMOOTH_MORE		2 //smooths with all subtypes of specified types or just itself (this value can replace SMOOTH_TRUE)
#define SMOOTH_DIAGONAL	4 //if atom should smooth diagonally, this should be present in 'smooth' var
#define SMOOTH_BORDER	8 //atom will smooth with the borders of the map

#define NULLTURF_BORDER 123456789

#define DEFAULT_UNDERLAY_ICON 			'icons/turf/floors.dmi'
#define DEFAULT_UNDERLAY_ICON_STATE 	"plating"
#define DEFAULT_UNDERLAY_IMAGE			image(DEFAULT_UNDERLAY_ICON, DEFAULT_UNDERLAY_ICON_STATE)

/atom/var/smooth = SMOOTH_FALSE
/atom/var/top_left_corner
/atom/var/top_right_corner
/atom/var/bottom_left_corner
/atom/var/bottom_right_corner
/atom/var/list/canSmoothWith = null // TYPE PATHS I CAN SMOOTH WITH~~~~~ If this is null and atom is smooth, it smooths only with itself
/atom/movable/var/can_be_unanchored = 0
/turf/var/list/fixed_underlay = null

/proc/calculate_adjacencies(atom/A)
	if(!A.loc)
		return 0

	var/adjacencies = 0

	var/atom/movable/AM
	if(istype(A, /atom/movable))
		AM = A
		if(AM.can_be_unanchored && !AM.anchored)
			return 0

	for(var/direction in cardinal)
		AM = find_type_in_direction(A, direction)
		if(AM == NULLTURF_BORDER)
			if((A.smooth & SMOOTH_BORDER))
				adjacencies |= 1 << direction
		else if( (AM && !istype(AM)) || (istype(AM) && AM.anchored) )
			adjacencies |= 1 << direction

	if(adjacencies & N_NORTH)
		if(adjacencies & N_WEST)
			AM = find_type_in_direction(A, NORTHWEST)
			if(AM == NULLTURF_BORDER)
				if((A.smooth & SMOOTH_BORDER))
					adjacencies |= N_NORTHWEST
			else if( (AM && !istype(AM)) || (istype(AM) && AM.anchored) )
				adjacencies |= N_NORTHWEST
		if(adjacencies & N_EAST)
			AM = find_type_in_direction(A, NORTHEAST)
			if(AM == NULLTURF_BORDER)
				if((A.smooth & SMOOTH_BORDER))
					adjacencies |= N_NORTHEAST
			else if( (AM && !istype(AM)) || (istype(AM) && AM.anchored) )
				adjacencies |= N_NORTHEAST

	if(adjacencies & N_SOUTH)
		if(adjacencies & N_WEST)
			AM = find_type_in_direction(A, SOUTHWEST)
			if(AM == NULLTURF_BORDER)
				if((A.smooth & SMOOTH_BORDER))
					adjacencies |= N_SOUTHWEST
			else if( (AM && !istype(AM)) || (istype(AM) && AM.anchored) )
				adjacencies |= N_SOUTHWEST
		if(adjacencies & N_EAST)
			AM = find_type_in_direction(A, SOUTHEAST)
			if(AM == NULLTURF_BORDER)
				if((A.smooth & SMOOTH_BORDER))
					adjacencies |= N_SOUTHEAST
			else if( (AM && !istype(AM)) || (istype(AM) && AM.anchored) )
				adjacencies |= N_SOUTHEAST

	return adjacencies

//do not use, use queue_smooth(atom)
/proc/smooth_icon(atom/A)
	if(!A || !A.smooth || !A.z)
		return
	if(qdeleted(A))
		return
	if((A.smooth & SMOOTH_TRUE) || (A.smooth & SMOOTH_MORE))
		var/adjacencies = calculate_adjacencies(A)

		if(A.smooth & SMOOTH_DIAGONAL)
			A.diagonal_smooth(adjacencies)
		else
			cardinal_smooth(A, adjacencies)

/atom/proc/diagonal_smooth(adjacencies)
	switch(adjacencies)
		if(N_NORTH|N_WEST)
			replace_smooth_overlays("d-se","d-se-0")
		if(N_NORTH|N_EAST)
			replace_smooth_overlays("d-sw","d-sw-0")
		if(N_SOUTH|N_WEST)
			replace_smooth_overlays("d-ne","d-ne-0")
		if(N_SOUTH|N_EAST)
			replace_smooth_overlays("d-nw","d-nw-0")

		if(N_NORTH|N_WEST|N_NORTHWEST)
			replace_smooth_overlays("d-se","d-se-1")
		if(N_NORTH|N_EAST|N_NORTHEAST)
			replace_smooth_overlays("d-sw","d-sw-1")
		if(N_SOUTH|N_WEST|N_SOUTHWEST)
			replace_smooth_overlays("d-ne","d-ne-1")
		if(N_SOUTH|N_EAST|N_SOUTHEAST)
			replace_smooth_overlays("d-nw","d-nw-1")

		else
			cardinal_smooth(src, adjacencies)
			return

	icon_state = ""
	return adjacencies

//only walls should have a need to handle underlays
/turf/closed/wall/diagonal_smooth(adjacencies)
	adjacencies = reverse_ndir(..())
	if(adjacencies)
		var/list/U = list()
		if(fixed_underlay)
			if(fixed_underlay["space"])
				var/image/I = image('icons/turf/space.dmi', SPACE_ICON_STATE, layer=TURF_LAYER)
				I.plane = PLANE_SPACE
				U += I
			else
				U += image(fixed_underlay["icon"], fixed_underlay["icon_state"], layer=TURF_LAYER)
		else
			var/turf/T = get_step(src, turn(adjacencies, 180))
			if(T && (T.density || T.smooth))
				T = get_step(src, turn(adjacencies, 135))
				if(T && (T.density || T.smooth))
					T = get_step(src, turn(adjacencies, 225))

			if(isspaceturf(T) && !istype(T, /turf/open/space/transit))
				var/image/I = image('icons/turf/space.dmi', SPACE_ICON_STATE, layer=TURF_LAYER)
				I.plane = PLANE_SPACE
				U += I
			else if(T && !T.density && !T.smooth)
				U += T
			else if(baseturf && !initial(baseturf.density) && !initial(baseturf.smooth))
				U += image(initial(baseturf.icon), initial(baseturf.icon_state), layer=TURF_LAYER)
			else
				U += DEFAULT_UNDERLAY_IMAGE
		underlays = U


/proc/cardinal_smooth(atom/A, adjacencies)
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

	var/list/New = list()

	if(A.top_left_corner != nw)
		A.overlays -= A.top_left_corner
		A.top_left_corner = nw
		New += nw

	if(A.top_right_corner != ne)
		A.overlays -= A.top_right_corner
		A.top_right_corner = ne
		New += ne

	if(A.bottom_right_corner != sw)
		A.overlays -= A.bottom_right_corner
		A.bottom_right_corner = sw
		New += sw

	if(A.bottom_left_corner != se)
		A.overlays -= A.bottom_left_corner
		A.bottom_left_corner = se
		New += se

	if(New.len)
		A.add_overlay(New)


/proc/find_type_in_direction(atom/source, direction)
	var/turf/target_turf = get_step(source, direction)
	if(!target_turf)
		return NULLTURF_BORDER

	if(source.canSmoothWith)
		var/atom/A
		if(source.smooth & SMOOTH_MORE)
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
/proc/smooth_zlevel(var/zlevel, now = FALSE)
	var/list/away_turfs = block(locate(1, 1, zlevel), locate(world.maxx, world.maxy, zlevel))
	for(var/V in away_turfs)
		var/turf/T = V
		if(T.smooth)
			if(now)
				smooth_icon(T)
			else
				queue_smooth(T)
		for(var/R in T)
			var/atom/A = R
			if(A.smooth)
				if(now)
					smooth_icon(A)
				else
					queue_smooth(A)

/atom/proc/clear_smooth_overlays()
	overlays -= top_left_corner
	top_left_corner = null
	overlays -= top_right_corner
	top_right_corner = null
	overlays -= bottom_right_corner
	bottom_right_corner = null
	overlays -= bottom_left_corner
	bottom_left_corner = null

/atom/proc/replace_smooth_overlays(nw, ne, sw, se)
	clear_smooth_overlays()
	var/list/O = list()
	top_left_corner = nw
	O += nw
	top_right_corner = ne
	O += ne
	bottom_left_corner = sw
	O += sw
	bottom_right_corner = se
	O += se
	add_overlay(O)

/proc/reverse_ndir(ndir)
	switch(ndir)
		if(N_NORTH)
			return NORTH
		if(N_SOUTH)
			return SOUTH
		if(N_WEST)
			return WEST
		if(N_EAST)
			return EAST
		if(N_NORTHWEST)
			return NORTHWEST
		if(N_NORTHEAST)
			return NORTHEAST
		if(N_SOUTHEAST)
			return SOUTHEAST
		if(N_SOUTHWEST)
			return SOUTHWEST
		if(N_NORTH|N_WEST)
			return NORTHWEST
		if(N_NORTH|N_EAST)
			return NORTHEAST
		if(N_SOUTH|N_WEST)
			return SOUTHWEST
		if(N_SOUTH|N_EAST)
			return SOUTHEAST
		if(N_NORTH|N_WEST|N_NORTHWEST)
			return NORTHWEST
		if(N_NORTH|N_EAST|N_NORTHEAST)
			return NORTHEAST
		if(N_SOUTH|N_WEST|N_SOUTHWEST)
			return SOUTHWEST
		if(N_SOUTH|N_EAST|N_SOUTHEAST)
			return SOUTHEAST
		else
			return 0

//SSicon_smooth
/proc/queue_smooth_neighbors(atom/A)
	for(var/V in orange(1,A))
		var/atom/T = V
		if(T.smooth)
			queue_smooth(T)

//SSicon_smooth
/proc/queue_smooth(atom/A)
	if(SSicon_smooth)
		SSicon_smooth.smooth_queue[A] = A
		SSicon_smooth.can_fire = 1
	else
		smooth_icon(A)

//Example smooth wall
/turf/closed/wall/smooth
	name = "smooth wall"
	icon = 'icons/turf/smooth_wall.dmi'
	icon_state = "smooth"
	smooth = SMOOTH_TRUE|SMOOTH_DIAGONAL|SMOOTH_BORDER
	canSmoothWith = null
