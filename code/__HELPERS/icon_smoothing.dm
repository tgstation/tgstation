
//generic (by snowflake) tile smoothing code; smooth your icons with this!
/*
	Each tile is divided in 4 corners, each corner has an appearance associated to it; the tile is then overlayed by these 4 appearances
	To use this, just set your atom's 'smooth' var to 1. If your atom can be moved/unanchored, set its 'can_be_unanchored' var to 1.
	If you don't want your atom's icon to smooth with anything but atoms of the same type, set the list 'smoothWith' to null;
	Otherwise, put all types you want the atom icon to smooth with in 'smoothWith' INCLUDING THE TYPE OF THE ATOM ITSELF.
	If you want the subtypes to be included too, add the bitflag SMOOTH_SUBTYPES as value. e.g. list(turf = SMOOTH_SUBTYPES)
	If you want it to show a connection bit, add the bitflag SMOOTH_CONNECT as value.

	Each atom has its own icon file with all the possible corner states. See 'smooth_wall.dmi' for a template.

	DIAGONAL SMOOTHING INSTRUCTIONS
	To make your atom smooth diagonally you need all the proper icon states (see 'smooth_wall.dmi' for a template) and
	to add the 'SMOOTH_DIAGONAL' flag to the atom's smooth var (in addition to SMOOTH_TRUE).

	For turfs, what appears under the diagonal corners depends on the turf that was in the same position previously: if you make a wall on
	a plating floor, you will see plating under the diagonal wall corner, if it was space, you will see space.

	If you wish to map a diagonal wall corner with a fixed underlay, you must configure the turf's 'fixed_underlay' list var, like so:
		fixed_underlay = list("icon"='icon_file.dmi', "icon_state"="iconstatename")
	A non null 'fixed_underlay' list var will skip copying the previous turf appearance and always use the list. If the list is
	not set properly, the underlay will default to regular floor plating.

	To see an example of a diagonal wall, see '/turf/closed/wall/mineral/titanium' and its subtypes.
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

#define SMOOTH_FALSE	0	//not smooth
#define SMOOTH_TRUE		1	//smooths with exact specified types or just itself
#define SMOOTH_DIAGONAL	2	//if atom should smooth diagonally, this should be present in 'smooth' var
#define SMOOTH_BORDER	4	//atom will smooth with the borders of the map
#define SMOOTH_QUEUED	8	//atom is currently queued to smooth.

#define SMOOTH_SUBTYPES	1
#define SMOOTH_CONNECT	2

#define NULLTURF_BORDER 123456789

#define DEFAULT_UNDERLAY_ICON 			'icons/turf/floors.dmi'
#define DEFAULT_UNDERLAY_ICON_STATE 	"plating"

#define WALL_SMOOTH_LIST1(type) list(\
	/turf/closed/wall = SMOOTH_CONNECT | SMOOTH_SUBTYPES,\
	type,\
	/obj/machinery/door = SMOOTH_CONNECT | SMOOTH_SUBTYPES,\
	/obj/structure/falsewall = SMOOTH_CONNECT | SMOOTH_SUBTYPES,\
	/obj/structure/shuttle/engine/heater,\
	/obj/structure/window/fulltile = SMOOTH_CONNECT,\
	/obj/structure/window/reinforced/fulltile = SMOOTH_CONNECT,\
	/obj/structure/window/reinforced/tinted/fulltile = SMOOTH_CONNECT,\
	/obj/structure/window/plasma/fulltile = SMOOTH_CONNECT,\
	/obj/structure/window/plasma/reinforced/fulltile = SMOOTH_CONNECT,\
	/obj/structure/window/shuttle = SMOOTH_CONNECT,\
	/obj/structure/window/shuttle/tinted = SMOOTH_CONNECT,\
	/obj/structure/window/plastitanium = SMOOTH_CONNECT,\
	)

#define WALL_SMOOTH_LIST(type, falsewall_type) list(\
	/turf/closed/wall = SMOOTH_CONNECT | SMOOTH_SUBTYPES,\
	type,\
	/obj/machinery/door = SMOOTH_CONNECT | SMOOTH_SUBTYPES,\
	/obj/structure/falsewall = SMOOTH_CONNECT | SMOOTH_SUBTYPES,\
	falsewall_type,\
	/obj/structure/shuttle/engine/heater,\
	/obj/structure/window/fulltile = SMOOTH_CONNECT,\
	/obj/structure/window/reinforced/fulltile = SMOOTH_CONNECT,\
	/obj/structure/window/reinforced/tinted/fulltile = SMOOTH_CONNECT,\
	/obj/structure/window/plasma/fulltile = SMOOTH_CONNECT,\
	/obj/structure/window/plasma/reinforced/fulltile = SMOOTH_CONNECT,\
	/obj/structure/window/shuttle = SMOOTH_CONNECT,\
	/obj/structure/window/shuttle/tinted = SMOOTH_CONNECT,\
	/obj/structure/window/plastitanium = SMOOTH_CONNECT,\
	)

#define WINDOW_SMOOTH_LIST list(\
	/turf/closed/wall = SMOOTH_CONNECT | SMOOTH_SUBTYPES,\
	/obj/machinery/door = SMOOTH_CONNECT | SMOOTH_SUBTYPES,\
	/obj/structure/window = SMOOTH_CONNECT | SMOOTH_SUBTYPES,\
	/obj/structure/falsewall = SMOOTH_CONNECT | SMOOTH_SUBTYPES,\
	/obj/structure/window/fulltile,\
	/obj/structure/window/reinforced/fulltile,\
	/obj/structure/window/reinforced/tinted/fulltile,\
	/obj/structure/window/plasma/fulltile,\
	/obj/structure/window/plasma/reinforced/fulltile,\
	/obj/structure/window/shuttle,\
	/obj/structure/window/shuttle/tinted,\
	/obj/structure/window/plastitanium,\
	)

/atom
	var/smooth = SMOOTH_FALSE
	var/top_left_corner
	var/top_right_corner
	var/bottom_left_corner
	var/bottom_right_corner
	var/list/smoothWith = null // TYPE PATHS I CAN SMOOTH WITH~~~~~ If this is null and atom is smooth, it smooths only with itself

/atom/movable
	var/can_be_unanchored = FALSE

/turf
	var/list/fixed_underlay = null

//do not use, use queue_smooth(atom)
/proc/smooth_icon(atom/A)
	if(!A || !A.smooth)
		return
	A.smooth &= ~SMOOTH_QUEUED
	if (!A.z || !A.loc || QDELETED(A))
		return
	if(A.smooth & SMOOTH_TRUE)
		var/atom/movable/AM

		// calculate adjacencies
		var/adjacencies = 0

		if(ismovableatom(A))
			AM = A

		if(!AM || (!AM.can_be_unanchored || AM.anchored))
			for(var/direction in GLOB.cardinals)
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

		//smooth
		if(A.smooth & SMOOTH_DIAGONAL)
			A.diagonal_smooth(adjacencies)
		else
			cardinal_smooth(A, adjacencies)

		//add connect overlays

		A.cut_overlay("c-n")
		A.cut_overlay("c-s")
		A.cut_overlay("c-w")
		A.cut_overlay("c-e")

		var/list/condirs = list(NORTH=list(), SOUTH=list(), WEST=list(), EAST=list())
		var/turf/target_turf
		var/atom/A2

		for(var/direction in GLOB.cardinals)
			target_turf = get_step(A, direction)
			for(var/a_type in A.smoothWith)
				A2 = locate(a_type) in target_turf
				if(A.smoothWith[a_type] & SMOOTH_CONNECT)
					if(A.smoothWith[a_type] & SMOOTH_SUBTYPES)
						if(istype(target_turf, a_type))
							condirs[direction].Add(target_turf)
						if(A2 && istype(A2, a_type))
							condirs[direction].Add(A2)
					else
						if(a_type == target_turf.type)
							condirs[direction].Add(target_turf)
						if(A2 && A2.type == a_type)
							condirs[direction].Add(A2)
				else
					for(var/atom/an_atom in condirs[direction])
						if((A.smoothWith[a_type] & SMOOTH_SUBTYPES && istype(an_atom, a_type)) || (a_type == an_atom.type))
							condirs[direction].Cut(an_atom)

		for(var/direction in GLOB.cardinals)
			if(length(condirs[direction]))
				switch(direction)
					if(NORTH)
						A.add_overlay("c-n")
					if(SOUTH)
						A.add_overlay("c-s")
					if(EAST)
						A.add_overlay("c-e")
					if(WEST)
						A.add_overlay("c-w")

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
		var/mutable_appearance/underlay_appearance = mutable_appearance(layer = TURF_LAYER)
		var/list/U = list(underlay_appearance)
		if(fixed_underlay)
			if(fixed_underlay["space"])
				underlay_appearance.icon = 'icons/turf/space.dmi'
				underlay_appearance.icon_state = SPACE_ICON_STATE
				underlay_appearance.plane = PLANE_SPACE
			else
				underlay_appearance.icon = fixed_underlay["icon"]
				underlay_appearance.icon_state = fixed_underlay["icon_state"]
		else
			var/turned_adjacency = turn(adjacencies, 180)
			var/turf/T = get_step(src, turned_adjacency)
			if(!T.get_smooth_underlay_icon(underlay_appearance, src, turned_adjacency))
				T = get_step(src, turn(adjacencies, 135))
				if(!T.get_smooth_underlay_icon(underlay_appearance, src, turned_adjacency))
					T = get_step(src, turn(adjacencies, 225))
			//if all else fails, ask our own turf
			if(!T.get_smooth_underlay_icon(underlay_appearance, src, turned_adjacency) && !get_smooth_underlay_icon(underlay_appearance, src, turned_adjacency))
				underlay_appearance.icon = DEFAULT_UNDERLAY_ICON
				underlay_appearance.icon_state = DEFAULT_UNDERLAY_ICON_STATE
		underlays = U

		// Drop posters which were previously placed on this wall.
		for(var/obj/structure/sign/poster/P in src)
			P.roll_and_drop(src)


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

	var/list/New

	if(A.top_left_corner != nw)
		A.cut_overlay(A.top_left_corner)
		A.top_left_corner = nw
		LAZYADD(New, nw)

	if(A.top_right_corner != ne)
		A.cut_overlay(A.top_right_corner)
		A.top_right_corner = ne
		LAZYADD(New, ne)

	if(A.bottom_right_corner != sw)
		A.cut_overlay(A.bottom_right_corner)
		A.bottom_right_corner = sw
		LAZYADD(New, sw)

	if(A.bottom_left_corner != se)
		A.cut_overlay(A.bottom_left_corner)
		A.bottom_left_corner = se
		LAZYADD(New, se)

	if(New)
		A.add_overlay(New)

/proc/find_type_in_direction(atom/source, direction)
	var/turf/target_turf = get_step(source, direction)
	if(!target_turf)
		return NULLTURF_BORDER

	var/area/target_area = get_area(target_turf)
	var/area/source_area = get_area(source)
	if(source_area.smoothWithAreas && !is_type_in_typecache(target_area, source_area.smoothWithAreas))
		return null
	if(target_area.smoothWithAreas && !is_type_in_typecache(source_area, target_area.smoothWithAreas))
		return null

	if(source.smoothWith)
		var/atom/A

		for(var/a_type in source.smoothWith)
			if(source.smoothWith[a_type] & SMOOTH_SUBTYPES)
				if(istype(target_turf, a_type))
					return target_turf
				A = locate(a_type) in target_turf
				if(A && istype(A, a_type))
					return A
			else
				if(a_type == target_turf.type)
					return target_turf
				A = locate(a_type) in target_turf
				if(A && A.type == a_type)
					return A

		return null

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
	cut_overlay(top_left_corner)
	top_left_corner = null
	cut_overlay(top_right_corner)
	top_right_corner = null
	cut_overlay(bottom_right_corner)
	bottom_right_corner = null
	cut_overlay(bottom_left_corner)
	bottom_left_corner = null
	cut_overlay("c-n")
	cut_overlay("c-s")
	cut_overlay("c-w")
	cut_overlay("c-e")

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
	if(!A.smooth || A.smooth & SMOOTH_QUEUED)
		return

	SSicon_smooth.smooth_queue += A
	SSicon_smooth.can_fire = 1
	A.smooth |= SMOOTH_QUEUED


//Example smooth wall
/turf/closed/wall/smooth
	name = "smooth wall"
	icon = 'icons/turf/smooth_wall.dmi'
	icon_state = "smooth"
	smooth = SMOOTH_TRUE|SMOOTH_DIAGONAL|SMOOTH_BORDER
