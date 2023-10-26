
//generic (by snowflake) tile smoothing code; smooth your icons with this!
/*
	Each tile is divided in 4 corners, each corner has an appearance associated to it; the tile is then overlayed by these 4 appearances
	To use this, just set your atom's 'smoothing_flags' var to 1. If your atom can be moved/unanchored, set its 'can_be_unanchored' var to 1.
	If you don't want your atom's icon to smooth with anything but atoms of the same type, set the list 'canSmoothWith' to null;
	Otherwise, put all the smoothing groups you want the atom icon to smooth with in 'canSmoothWith', including the group of the atom itself.
	Smoothing groups are just shared flags between objects. If one of the 'canSmoothWith' of A matches one of the `smoothing_groups` of B, then A will smooth with B.

	Each atom has its own icon file with all the possible corner states. See 'smooth_wall.dmi' for a template.

	DIAGONAL SMOOTHING INSTRUCTIONS
	To make your atom smooth diagonally you need all the proper icon states (see 'smooth_wall.dmi' for a template) and
	to add the 'SMOOTH_DIAGONAL_CORNERS' flag to the atom's smoothing_flags var (in addition to either SMOOTH_TRUE or SMOOTH_MORE).

	For turfs, what appears under the diagonal corners depends on the turf that was in the same position previously: if you make a wall on
	a plating floor, you will see plating under the diagonal wall corner, if it was space, you will see space.

	If you wish to map a diagonal wall corner with a fixed underlay, you must configure the turf's 'fixed_underlay' list var, like so:
		fixed_underlay = list("icon"='icon_file.dmi', "icon_state"="iconstatename")
	A non null 'fixed_underlay' list var will skip copying the previous turf appearance and always use the list. If the list is
	not set properly, the underlay will default to regular floor plating.

	To see an example of a diagonal wall, see '/turf/closed/wall/mineral/titanium' and its subtypes.
*/

//Redefinitions of the diagonal directions so they can be stored in one var without conflicts
#define NORTH_JUNCTION NORTH //(1<<0)
#define SOUTH_JUNCTION SOUTH //(1<<1)
#define EAST_JUNCTION EAST  //(1<<2)
#define WEST_JUNCTION WEST  //(1<<3)
#define NORTHEAST_JUNCTION (1<<4)
#define SOUTHEAST_JUNCTION (1<<5)
#define SOUTHWEST_JUNCTION (1<<6)
#define NORTHWEST_JUNCTION (1<<7)

DEFINE_BITFIELD(smoothing_junction, list(
	"NORTH_JUNCTION" = NORTH_JUNCTION,
	"SOUTH_JUNCTION" = SOUTH_JUNCTION,
	"EAST_JUNCTION" = EAST_JUNCTION,
	"WEST_JUNCTION" = WEST_JUNCTION,
	"NORTHEAST_JUNCTION" = NORTHEAST_JUNCTION,
	"SOUTHEAST_JUNCTION" = SOUTHEAST_JUNCTION,
	"SOUTHWEST_JUNCTION" = SOUTHWEST_JUNCTION,
	"NORTHWEST_JUNCTION" = NORTHWEST_JUNCTION,
))

#define NO_ADJ_FOUND 0
#define ADJ_FOUND 1
#define NULLTURF_BORDER 2

GLOBAL_LIST_INIT(adjacent_direction_lookup, generate_adjacent_directions())

/* Attempting to mirror the below
 * Each 3x3 grid is a tile, with each X representing a direction a border object could be in IN said grid
 * Directions marked with A are acceptable smoothing targets, M is the example direction
 * The example given here is of a northfacing border object
xxx xxx xxx
xxx AxA xxx
xxx xAx xxx

xAx xMx xAx
xxx AxA xxx
xxx xxx xxx

xxx xxx xxx
xxx xxx xxx
xxx xxx xxx
*/
/// Encodes connectivity between border objects
/// Returns a list accessable by a border object's dir, the direction between it and a target, and a target
/// Said list will return the direction the two objects connect, if any exists (if the target isn't a border object and the direction is fine, return the inverse of the direction in use)
/proc/generate_adjacent_directions()
	// Have to hold all conventional dir pairs, so we size to the largest
	// We don't HAVE diagonal border objects, so I'm gonna pretend they'll never exist

	// You might be like, lemon, can't we use GLOB.cardinals/GLOB.alldirs here
	// No, they aren't loaded yet. life is pain
	var/list/cardinals = list(NORTH, SOUTH, EAST, WEST)
	var/list/alldirs = cardinals + list(NORTH|EAST, SOUTH|EAST, NORTH|WEST, SOUTH|WEST)
	var/largest_cardinal = max(cardinals)
	var/largest_dir = max(alldirs)

	var/list/direction_map = new /list(largest_cardinal)
	for(var/dir in cardinals)
		var/left = turn(dir, 90)
		var/right = turn(dir, -90)
		var/opposite = REVERSE_DIR(dir)
		// Need to encode diagonals here because it's possible, even if it is always false
		var/list/acceptable_adjacents = new /list(largest_dir)
		// Alright, what directions are acceptable to us
		for(var/connectable_dir in (cardinals + NONE))
			// And what border objects INSIDE those directions are alright
			var/list/smoothable_dirs = new /list(largest_cardinal + 1) // + 1 because we need to provide space for NONE to be a valid index
			// None is fine, we want to smooth with things on our own turf
			// We'll do the two dirs to our left and right
			// They connect.. "below" us and on their side
			if(connectable_dir == NONE)
				smoothable_dirs[left] = opposite | left
				smoothable_dirs[right] = opposite | right
			// If it's to our right or left we'll include just the dir matching ours
			// Left edge touches only our left side, and so on
			else if (connectable_dir == left)
				smoothable_dirs[dir] = left
			else if (connectable_dir == right)
				smoothable_dirs[dir] = right
			// If it's straight on we'll include all cardinals but us, since all 3 bits would touch us
			// Turf opposite gets just our dir as the connection, the other two get our dir + theirs
			// Since they touch the edges
			else if(connectable_dir == dir)
				smoothable_dirs[opposite] = dir
				smoothable_dirs[left] = dir | left
				smoothable_dirs[right] = dir | right
			// otherwise, go HOME, I don't want to encode anything for you
			else
				continue
			acceptable_adjacents[connectable_dir + 1] = smoothable_dirs
		direction_map[dir] = acceptable_adjacents
	return direction_map

/// Are two atoms border adjacent, takes a border object, something to compare against, and the direction between A and B
/// Returns the way in which the first thing is adjacent to the second
#define CAN_DIAGONAL_SMOOTH(border_obj, target, direction) (\
	(target.smoothing_flags & SMOOTH_BORDER_OBJECT) ? \
		GLOB.adjacent_direction_lookup[border_obj.dir][direction + 1]?[target.dir] : \
		(GLOB.adjacent_direction_lookup[border_obj.dir][direction + 1]) ? REVERSE_DIR(direction) : NONE \
	)

#define DEFAULT_UNDERLAY_ICON 'icons/turf/floors.dmi'
#define DEFAULT_UNDERLAY_ICON_STATE "plating"


///Scans all adjacent turfs to find targets to smooth with.
/atom/proc/calculate_adjacencies()
	. = NONE

	if(!loc)
		return

	for(var/direction in GLOB.cardinals)
		switch(find_type_in_direction(direction))
			if(NULLTURF_BORDER)
				if((smoothing_flags & SMOOTH_BORDER))
					. |= direction //BYOND and smooth dirs are the same for cardinals
			if(ADJ_FOUND)
				. |= direction //BYOND and smooth dirs are the same for cardinals

	if(. & NORTH_JUNCTION)
		if(. & WEST_JUNCTION)
			switch(find_type_in_direction(NORTHWEST))
				if(NULLTURF_BORDER)
					if((smoothing_flags & SMOOTH_BORDER))
						. |= NORTHWEST_JUNCTION
				if(ADJ_FOUND)
					. |= NORTHWEST_JUNCTION

		if(. & EAST_JUNCTION)
			switch(find_type_in_direction(NORTHEAST))
				if(NULLTURF_BORDER)
					if((smoothing_flags & SMOOTH_BORDER))
						. |= NORTHEAST_JUNCTION
				if(ADJ_FOUND)
					. |= NORTHEAST_JUNCTION

	if(. & SOUTH_JUNCTION)
		if(. & WEST_JUNCTION)
			switch(find_type_in_direction(SOUTHWEST))
				if(NULLTURF_BORDER)
					if((smoothing_flags & SMOOTH_BORDER))
						. |= SOUTHWEST_JUNCTION
				if(ADJ_FOUND)
					. |= SOUTHWEST_JUNCTION

		if(. & EAST_JUNCTION)
			switch(find_type_in_direction(SOUTHEAST))
				if(NULLTURF_BORDER)
					if((smoothing_flags & SMOOTH_BORDER))
						. |= SOUTHEAST_JUNCTION
				if(ADJ_FOUND)
					. |= SOUTHEAST_JUNCTION


/atom/movable/calculate_adjacencies()
	if(can_be_unanchored && !anchored)
		return NONE
	return ..()


///do not use, use QUEUE_SMOOTH(atom)
/atom/proc/smooth_icon()
	smoothing_flags &= ~SMOOTH_QUEUED
	flags_1 |= HTML_USE_INITAL_ICON_1
	if (!z)
		CRASH("[type] called smooth_icon() without being on a z-level")
	if(smoothing_flags & SMOOTH_CORNERS)
		if(smoothing_flags & SMOOTH_DIAGONAL_CORNERS)
			corners_diagonal_smooth(calculate_adjacencies())
		else
			corners_cardinal_smooth(calculate_adjacencies())
	else if(smoothing_flags & SMOOTH_BITMASK)
		bitmask_smooth()
	else
		CRASH("smooth_icon called for [src] with smoothing_flags == [smoothing_flags]")
	SEND_SIGNAL(src, COMSIG_ATOM_SMOOTHED_ICON)

// As a rule, movables will most always care about smoothing changes
// Turfs on the other hand, don't, so we don't do the update for THEM unless they explicitly request it
/atom/movable/smooth_icon()
	. = ..()
	update_appearance(~UPDATE_SMOOTHING)

/atom/proc/corners_diagonal_smooth(adjacencies)
	switch(adjacencies)
		if(NORTH_JUNCTION|WEST_JUNCTION)
			replace_smooth_overlays("d-se","d-se-0")
		if(NORTH_JUNCTION|EAST_JUNCTION)
			replace_smooth_overlays("d-sw","d-sw-0")
		if(SOUTH_JUNCTION|WEST_JUNCTION)
			replace_smooth_overlays("d-ne","d-ne-0")
		if(SOUTH_JUNCTION|EAST_JUNCTION)
			replace_smooth_overlays("d-nw","d-nw-0")

		if(NORTH_JUNCTION|WEST_JUNCTION|NORTHWEST_JUNCTION)
			replace_smooth_overlays("d-se","d-se-1")
		if(NORTH_JUNCTION|EAST_JUNCTION|NORTHEAST_JUNCTION)
			replace_smooth_overlays("d-sw","d-sw-1")
		if(SOUTH_JUNCTION|WEST_JUNCTION|SOUTHWEST_JUNCTION)
			replace_smooth_overlays("d-ne","d-ne-1")
		if(SOUTH_JUNCTION|EAST_JUNCTION|SOUTHEAST_JUNCTION)
			replace_smooth_overlays("d-nw","d-nw-1")

		else
			corners_cardinal_smooth(adjacencies)
			return FALSE

	icon_state = ""
	return TRUE


/atom/proc/corners_cardinal_smooth(adjacencies)
	var/mutable_appearance/temp_ma

	//NW CORNER
	var/nw = "1-i"
	if((adjacencies & NORTH_JUNCTION) && (adjacencies & WEST_JUNCTION))
		if(adjacencies & NORTHWEST_JUNCTION)
			nw = "1-f"
		else
			nw = "1-nw"
	else
		if(adjacencies & NORTH_JUNCTION)
			nw = "1-n"
		else if(adjacencies & WEST_JUNCTION)
			nw = "1-w"
	temp_ma = mutable_appearance(icon, nw)
	nw = temp_ma.appearance

	//NE CORNER
	var/ne = "2-i"
	if((adjacencies & NORTH_JUNCTION) && (adjacencies & EAST_JUNCTION))
		if(adjacencies & NORTHEAST_JUNCTION)
			ne = "2-f"
		else
			ne = "2-ne"
	else
		if(adjacencies & NORTH_JUNCTION)
			ne = "2-n"
		else if(adjacencies & EAST_JUNCTION)
			ne = "2-e"
	temp_ma = mutable_appearance(icon, ne)
	ne = temp_ma.appearance

	//SW CORNER
	var/sw = "3-i"
	if((adjacencies & SOUTH_JUNCTION) && (adjacencies & WEST_JUNCTION))
		if(adjacencies & SOUTHWEST_JUNCTION)
			sw = "3-f"
		else
			sw = "3-sw"
	else
		if(adjacencies & SOUTH_JUNCTION)
			sw = "3-s"
		else if(adjacencies & WEST_JUNCTION)
			sw = "3-w"
	temp_ma = mutable_appearance(icon, sw)
	sw = temp_ma.appearance

	//SE CORNER
	var/se = "4-i"
	if((adjacencies & SOUTH_JUNCTION) && (adjacencies & EAST_JUNCTION))
		if(adjacencies & SOUTHEAST_JUNCTION)
			se = "4-f"
		else
			se = "4-se"
	else
		if(adjacencies & SOUTH_JUNCTION)
			se = "4-s"
		else if(adjacencies & EAST_JUNCTION)
			se = "4-e"
	temp_ma = mutable_appearance(icon, se)
	se = temp_ma.appearance

	var/list/new_overlays

	if(top_left_corner != nw)
		cut_overlay(top_left_corner)
		top_left_corner = nw
		LAZYADD(new_overlays, nw)

	if(top_right_corner != ne)
		cut_overlay(top_right_corner)
		top_right_corner = ne
		LAZYADD(new_overlays, ne)

	if(bottom_right_corner != sw)
		cut_overlay(bottom_right_corner)
		bottom_right_corner = sw
		LAZYADD(new_overlays, sw)

	if(bottom_left_corner != se)
		cut_overlay(bottom_left_corner)
		bottom_left_corner = se
		LAZYADD(new_overlays, se)

	if(new_overlays)
		add_overlay(new_overlays)


///Scans direction to find targets to smooth with.
/atom/proc/find_type_in_direction(direction)
	var/turf/target_turf = get_step(src, direction)
	if(!target_turf)
		return NULLTURF_BORDER

	var/area/target_area = get_area(target_turf)
	var/area/source_area = get_area(src)
	if((source_area.area_limited_icon_smoothing && !istype(target_area, source_area.area_limited_icon_smoothing)) || (target_area.area_limited_icon_smoothing && !istype(source_area, target_area.area_limited_icon_smoothing)))
		return NO_ADJ_FOUND

	if(isnull(canSmoothWith)) //special case in which it will only smooth with itself
		if(isturf(src))
			return (type == target_turf.type) ? ADJ_FOUND : NO_ADJ_FOUND
		var/atom/matching_obj = locate(type) in target_turf
		return (matching_obj && matching_obj.type == type) ? ADJ_FOUND : NO_ADJ_FOUND

	if(!isnull(target_turf.smoothing_groups))
		for(var/target in canSmoothWith)
			if(!(canSmoothWith[target] & target_turf.smoothing_groups[target]))
				continue
			return ADJ_FOUND

	if(smoothing_flags & SMOOTH_OBJ)
		for(var/atom/movable/thing as anything in target_turf)
			if(!thing.anchored || isnull(thing.smoothing_groups))
				continue
			for(var/target in canSmoothWith)
				if(!(canSmoothWith[target] & thing.smoothing_groups[target]))
					continue
				return ADJ_FOUND

	return NO_ADJ_FOUND

/**
 * Basic smoothing proc. The atom checks for adjacent directions to smooth with and changes the icon_state based on that.
 *
 * Returns the previous smoothing_junction state so the previous state can be compared with the new one after the proc ends, and see the changes, if any.
 *
*/
/atom/proc/bitmask_smooth()
	var/new_junction = NONE

	// cache for sanic speed
	var/canSmoothWith = src.canSmoothWith

	var/smooth_border = (smoothing_flags & SMOOTH_BORDER)
	var/smooth_obj = (smoothing_flags & SMOOTH_OBJ)
	var/border_object_smoothing = (smoothing_flags & SMOOTH_BORDER_OBJECT)

	// Did you know you can pass defines into other defines? very handy, lets take advantage of it here to allow 0 cost variation
	#define SEARCH_ADJ_IN_DIR(direction, direction_flag, ADJ_FOUND, WORLD_BORDER, BORDER_CHECK) \
		do { \
			var/turf/neighbor = get_step(src, direction); \
			if(neighbor && ##BORDER_CHECK(neighbor, direction)) { \
				var/neighbor_smoothing_groups = neighbor.smoothing_groups; \
				if(neighbor_smoothing_groups) { \
					for(var/target in canSmoothWith) { \
						if(canSmoothWith[target] & neighbor_smoothing_groups[target]) { \
							##ADJ_FOUND(neighbor, direction, direction_flag); \
						} \
					} \
				} \
				if(smooth_obj) { \
					for(var/atom/movable/thing as anything in neighbor) { \
						var/thing_smoothing_groups = thing.smoothing_groups; \
						if(!thing.anchored || isnull(thing_smoothing_groups) || !##BORDER_CHECK(thing, direction)) { \
							continue; \
						}; \
						for(var/target in canSmoothWith) { \
							if(canSmoothWith[target] & thing_smoothing_groups[target]) { \
								##ADJ_FOUND(thing, direction, direction_flag); \
							} \
						} \
					} \
				} \
			} else if (smooth_border) { \
				##WORLD_BORDER(null, direction, direction_flag); \
			} \
		} while(FALSE) \

	#define BITMASK_FOUND(target, direction, direction_flag) \
		new_junction |= direction_flag; \
		break set_adj_in_dir; \
	/// Check that non border objects use to smooth against border objects
	/// Returns true if the smooth is acceptable, FALSE otherwise
	#define BITMASK_ON_BORDER_CHECK(target, direction) (!(target.smoothing_flags & SMOOTH_BORDER_OBJECT) || CAN_DIAGONAL_SMOOTH(target, src, REVERSE_DIR(direction)))

	#define BORDER_FOUND(target, direction, direction_flag) new_junction |= CAN_DIAGONAL_SMOOTH(src, target, direction)
	// Border objects require an object as context, so we need a dummy. I'm sorry
	#define WORLD_BORDER_FOUND(target, direction, direction_flag) \
		var/static/atom/dummy; \
		if(!dummy) { \
			dummy = new(); \
			dummy.smoothing_flags &= ~SMOOTH_BORDER_OBJECT; \
		} \
		BORDER_FOUND(dummy, direction, direction_flag);
	// Handle handle border on border checks. no-op, we handle this check inside CAN_DIAGONAL_SMOOTH
	#define BORDER_ON_BORDER_CHECK(target, direction) (TRUE)

	// We're building 2 different types of smoothing searches here
	// One for standard bitmask smoothing (We provide a label so our macro can eary exit, as it wants to do)
	#define SET_ADJ_IN_DIR(direction, direction_flag) do { set_adj_in_dir: { SEARCH_ADJ_IN_DIR(direction, direction_flag, BITMASK_FOUND, BITMASK_FOUND, BITMASK_ON_BORDER_CHECK) }} while(FALSE)
	// and another for border object work (Doesn't early exit because we can hit more then one direction by checking the same turf)
	#define SET_BORDER_ADJ_IN_DIR(direction) SEARCH_ADJ_IN_DIR(direction, direction, BORDER_FOUND, WORLD_BORDER_FOUND, BORDER_ON_BORDER_CHECK)

	// Let's go over all our cardinals
	if(border_object_smoothing)
		SET_BORDER_ADJ_IN_DIR(NORTH)
		SET_BORDER_ADJ_IN_DIR(SOUTH)
		SET_BORDER_ADJ_IN_DIR(EAST)
		SET_BORDER_ADJ_IN_DIR(WEST)
		// We want to check against stuff in our own turf
		SET_BORDER_ADJ_IN_DIR(NONE)
		// Border objects don't do diagonals, so GO HOME
		set_smoothed_icon_state(new_junction)
		return

	SET_ADJ_IN_DIR(NORTH, NORTH)
	SET_ADJ_IN_DIR(SOUTH, SOUTH)
	SET_ADJ_IN_DIR(EAST, EAST)
	SET_ADJ_IN_DIR(WEST, WEST)

	// If there's nothing going on already
	if(!(new_junction & (NORTH|SOUTH)) || !(new_junction & (EAST|WEST)))
		set_smoothed_icon_state(new_junction)
		return

	if(new_junction & NORTH_JUNCTION)
		if(new_junction & WEST_JUNCTION)
			SET_ADJ_IN_DIR(NORTHWEST, NORTHWEST_JUNCTION)

		if(new_junction & EAST_JUNCTION)
			SET_ADJ_IN_DIR(NORTHEAST, NORTHEAST_JUNCTION)

	if(new_junction & SOUTH_JUNCTION)
		if(new_junction & WEST_JUNCTION)
			SET_ADJ_IN_DIR(SOUTHWEST, SOUTHWEST_JUNCTION)

		if(new_junction & EAST_JUNCTION)
			SET_ADJ_IN_DIR(SOUTHEAST, SOUTHEAST_JUNCTION)

	set_smoothed_icon_state(new_junction)

	#undef SET_BORDER_ADJ_IN_DIR
	#undef SET_ADJ_IN_DIR
	#undef BORDER_ON_BORDER_CHECK
	#undef WORLD_BORDER_FOUND
	#undef BORDER_FOUND
	#undef BITMASK_ON_BORDER_CHECK
	#undef BITMASK_FOUND
	#undef SEARCH_ADJ_IN_DIR

///Changes the icon state based on the new junction bitmask
/atom/proc/set_smoothed_icon_state(new_junction)
	. = smoothing_junction
	smoothing_junction = new_junction
	icon_state = "[base_icon_state]-[smoothing_junction]"


/turf/closed/set_smoothed_icon_state(new_junction)
	// Avoid calling ..() here to avoid setting icon_state twice, which is expensive given how hot this proc is
	var/old_junction = smoothing_junction
	smoothing_junction = new_junction

	if (!(smoothing_flags & SMOOTH_DIAGONAL_CORNERS))
		icon_state = "[base_icon_state]-[smoothing_junction]"
		return

	switch(new_junction)
		if(
			NORTH_JUNCTION|WEST_JUNCTION,
			NORTH_JUNCTION|EAST_JUNCTION,
			SOUTH_JUNCTION|WEST_JUNCTION,
			SOUTH_JUNCTION|EAST_JUNCTION,
			NORTH_JUNCTION|WEST_JUNCTION|NORTHWEST_JUNCTION,
			NORTH_JUNCTION|EAST_JUNCTION|NORTHEAST_JUNCTION,
			SOUTH_JUNCTION|WEST_JUNCTION|SOUTHWEST_JUNCTION,
			SOUTH_JUNCTION|EAST_JUNCTION|SOUTHEAST_JUNCTION,
		)
			icon_state = "[base_icon_state]-[smoothing_junction]-d"
			if(new_junction == old_junction || fixed_underlay) // Mutable underlays?
				return

			var/junction_dir = reverse_ndir(smoothing_junction)
			var/turned_adjacency = REVERSE_DIR(junction_dir)
			var/turf/neighbor_turf = get_step(src, turned_adjacency & (NORTH|SOUTH))
			var/mutable_appearance/underlay_appearance = mutable_appearance(layer = TURF_LAYER, offset_spokesman = src, plane = FLOOR_PLANE)
			if(!neighbor_turf.get_smooth_underlay_icon(underlay_appearance, src, turned_adjacency))
				neighbor_turf = get_step(src, turned_adjacency & (EAST|WEST))

				if(!neighbor_turf.get_smooth_underlay_icon(underlay_appearance, src, turned_adjacency))
					neighbor_turf = get_step(src, turned_adjacency)

					if(!neighbor_turf.get_smooth_underlay_icon(underlay_appearance, src, turned_adjacency))
						if(!get_smooth_underlay_icon(underlay_appearance, src, turned_adjacency)) //if all else fails, ask our own turf
							underlay_appearance.icon = DEFAULT_UNDERLAY_ICON
							underlay_appearance.icon_state = DEFAULT_UNDERLAY_ICON_STATE
			underlays += underlay_appearance
		else
			icon_state = "[base_icon_state]-[smoothing_junction]"

/turf/open/floor/set_smoothed_icon_state(new_junction)
	if(broken || burnt)
		return
	return ..()


//Icon smoothing helpers
/proc/smooth_zlevel(zlevel, now = FALSE)
	var/list/away_turfs = Z_TURFS(zlevel)
	for(var/turf/turf_to_smooth as anything in away_turfs)
		if(turf_to_smooth.smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
			if(now)
				turf_to_smooth.smooth_icon()
			else
				QUEUE_SMOOTH(turf_to_smooth)
		for(var/atom/movable/movable_to_smooth as anything in turf_to_smooth)
			if(movable_to_smooth.smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
				if(now)
					movable_to_smooth.smooth_icon()
				else
					QUEUE_SMOOTH(movable_to_smooth)


/atom/proc/clear_smooth_overlays()
	cut_overlay(top_left_corner)
	top_left_corner = null
	cut_overlay(top_right_corner)
	top_right_corner = null
	cut_overlay(bottom_right_corner)
	bottom_right_corner = null
	cut_overlay(bottom_left_corner)
	bottom_left_corner = null

/// Internal: Takes icon states as text to replace smoothing corner overlays
/atom/proc/replace_smooth_overlays(nw, ne, sw, se)
	clear_smooth_overlays()
	var/mutable_appearance/temp_ma

	temp_ma = mutable_appearance(icon, nw)
	nw = temp_ma.appearance

	temp_ma = mutable_appearance(icon, ne)
	ne = temp_ma.appearance

	temp_ma = mutable_appearance(icon, sw)
	sw = temp_ma.appearance

	temp_ma = mutable_appearance(icon, se)
	se = temp_ma.appearance

	var/list/new_overlays = list()

	top_left_corner = nw
	new_overlays += nw

	top_right_corner = ne
	new_overlays += ne

	bottom_left_corner = sw
	new_overlays += sw

	bottom_right_corner = se
	new_overlays += se

	add_overlay(new_overlays)


/proc/reverse_ndir(ndir)
	switch(ndir)
		if(NORTH_JUNCTION)
			return NORTH
		if(SOUTH_JUNCTION)
			return SOUTH
		if(WEST_JUNCTION)
			return WEST
		if(EAST_JUNCTION)
			return EAST
		if(NORTHWEST_JUNCTION)
			return NORTHWEST
		if(NORTHEAST_JUNCTION)
			return NORTHEAST
		if(SOUTHEAST_JUNCTION)
			return SOUTHEAST
		if(SOUTHWEST_JUNCTION)
			return SOUTHWEST
		if(NORTH_JUNCTION | WEST_JUNCTION)
			return NORTHWEST
		if(NORTH_JUNCTION | EAST_JUNCTION)
			return NORTHEAST
		if(SOUTH_JUNCTION | WEST_JUNCTION)
			return SOUTHWEST
		if(SOUTH_JUNCTION | EAST_JUNCTION)
			return SOUTHEAST
		if(NORTH_JUNCTION | WEST_JUNCTION | NORTHWEST_JUNCTION)
			return NORTHWEST
		if(NORTH_JUNCTION | EAST_JUNCTION | NORTHEAST_JUNCTION)
			return NORTHEAST
		if(SOUTH_JUNCTION | WEST_JUNCTION | SOUTHWEST_JUNCTION)
			return SOUTHWEST
		if(SOUTH_JUNCTION | EAST_JUNCTION | SOUTHEAST_JUNCTION)
			return SOUTHEAST
		else
			return NONE


//Example smooth wall
/turf/closed/wall/smooth
	name = "smooth wall"
	icon = 'icons/turf/smooth_wall.dmi'
	icon_state = "smooth"
	smoothing_flags = SMOOTH_CORNERS|SMOOTH_DIAGONAL_CORNERS|SMOOTH_BORDER
	smoothing_groups = null
	canSmoothWith = null

#undef NORTH_JUNCTION
#undef SOUTH_JUNCTION
#undef EAST_JUNCTION
#undef WEST_JUNCTION
#undef NORTHEAST_JUNCTION
#undef NORTHWEST_JUNCTION
#undef SOUTHEAST_JUNCTION
#undef SOUTHWEST_JUNCTION

#undef NO_ADJ_FOUND
#undef ADJ_FOUND
#undef NULLTURF_BORDER

#undef DEFAULT_UNDERLAY_ICON
#undef DEFAULT_UNDERLAY_ICON_STATE
#undef CAN_DIAGONAL_SMOOTH
