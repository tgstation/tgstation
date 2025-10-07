
//generic (by snowflake + others) tile smoothing code; smooth your icons with this!
/*
	Smoothed atoms are displayed using prebaked icon states which have been "cut" from a template to match a set of possible smoothing directions.
	This allows for a variety of effects, such as nice wall textures, gloopy slime, carpet that makes sense, etc etc etc

	To use this, just set your atom's 'smoothing_flags' var to SMOOTH_BITMASK. There are other smoothing strategies but that's all we need to worry about right now
	If you don't want your atom's icon to smooth with anything but atoms of the same type, set the string 'canSmoothWith' to null;
	Otherwise, put all the smoothing groups you want the atom icon to smooth with in 'canSmoothWith', including the group of the atom itself.
	Smoothing groups are just shared flags between objects. If one of the 'canSmoothWith' of A matches one of the `smoothing_groups` of B, then A will smooth with B.

	Each atom has its own icon file with all its icon states, this file is typically generated automatically from a png/toml using hypnagoic, our external cutter.
	See `wall.dmi' 'wall.png' and 'wall.png.toml' for an example, alongside [the icon cutter documentation](../../icons/Cutter.md)

	DIAGONAL SMOOTHING INSTRUCTIONS
	To make your atom smooth diagonally you need all the proper icon states (hypnagoic does not support these currently, TODO)
	They're constructed out of 12 "corners", 4 outer corners, 4 "outside" inner corners and 4 "inside" inner corners
	- 5, 6, 9 and 10 get what you can think of as "outside" bars, they're corners with no inside, like below (smoothing from the POV of [X]).
	-	[X]X
	-    X
	- 21, 38, 74, 137 get "inside" bars, still built with the same "outside" edges.
	-   [X]X
	-    X X
	I shouldn't like, need to tell you this, ideally hypnagogic would just support it, but I haven't done that yet and I wanted to write this down for now.

	Then add the 'SMOOTH_DIAGONAL_CORNERS' flag to the atom's smoothing_flags var (in addition to SMOOTH_BITMASK).

	For turfs, what appears under the diagonal corners depends on the turf that was in the same position previously: if you make a wall on
	a plating floor, you will see plating under the diagonal wall corner, if it was space, you will see space.

	If you wish to map a diagonal wall corner with a fixed underlay, you must configure the turf's 'fixed_underlay' list var, like so:
		fixed_underlay = list("icon"='icon_file.dmi', "icon_state"="iconstatename")
	A non null 'fixed_underlay' list var will skip copying the previous turf appearance and always use the list. If the list is
		not set properly, the underlay will default to regular floor plating.
	NOTE: a special case of this involves setting fixed_underlay to list("space" = TRUE), which will force it to draw space below the wall, no matter what

	To see an example of a diagonal wall, see '/turf/closed/wall/mineral/titanium' and its subtypes.

	BORDER SMOOTHING INSTRUCTIONS
	Ok so we have code to smooth border objects together, unfortunately for you I don't remember how they're supposed to be rendered (AND WE HAVE NO CUTTER SUPPORT)
	I'll fill this in when/if I add proper cutting for these, they're so painful to put together by hand I don't really want to even describe it to you

	ADVANCED FILTERING INSTRUCTIONS
	Smoothing allows you to manually filter out potential smoothing oppertunities by toggling SMOOTH_PROC_FILTER
	(or SMOOTH_BORDER_OBJECT but you should just be calling should_border_obj_smooth()) and overriding smoothing_allowed(atom/smoothing_with, direction, junction)
	This gives you control over if two atoms filter together, and what junction they will use (you likely do not want to touch this)

	PLEASE NOTE: you are giving up the convenience features of smoothing autoupdating if an input changes. If you do this you need to update and such MANUALLY.
	ALSO NOTE: this function cannot have side effects, as it is called when other atoms attempt to smooth with YOU as well.
*/

GLOBAL_LIST_INIT(adjacent_direction_lookup, generate_adjacent_directions())

/* Attempting to mirror the below
 * Each 3x3 grid is a tile, with each X representing a direction a border object could be in IN said grid
 * Directions marked with A are acceptable smoothing targets, M is the example direction
 * The example given here is of a northfacing border object
xxx AxA xxx
xxx AxA xxx
xxx AxA xxx

AAA MMM AAA
xxx AxA xxx
xxx AxA xxx

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
				smoothable_dirs[left] = dir_to_junction(opposite | left)
				smoothable_dirs[right] = dir_to_junction(opposite | right)
			// If it's to our right or left we'll include just the dir matching ours
			// Left edge touches only our left side, and so on
			else if (connectable_dir == left)
				smoothable_dirs[dir] = left
			else if (connectable_dir == right)
				smoothable_dirs[dir] = right
			// If it's straight on we'll include our direction as a link
			// Then include the two edges on the other side as diagonals
			else if(connectable_dir == dir)
				smoothable_dirs[opposite] = dir
				smoothable_dirs[left] = dir_to_junction(dir | left)
				smoothable_dirs[right] = dir_to_junction(dir | right)
			// otherwise, go HOME, I don't want to encode anything for you
			else
				continue
			acceptable_adjacents[connectable_dir + 1] = smoothable_dirs
		direction_map[dir] = acceptable_adjacents
	return direction_map

/// Helper proc for smoothing border objects. Return this from smoothing_allowed() to get the desired effect
/// Indexes into some global lists that encode direction bullshit
/proc/should_border_obj_smooth(atom/border_obj, atom/target, direction)
	// If the target is also a border obj, take its dirs into account
	if(target.smoothing_flags & SMOOTH_BORDER_OBJECT)
		return GLOB.adjacent_direction_lookup[border_obj?.dir || NORTH][direction + 1]?[target.dir]
	// Otherwise, do it normal style
	if(GLOB.adjacent_direction_lookup[border_obj?.dir || NORTH][direction + 1])
		return REVERSE_DIR(direction)
	return NONE

///do not use, use QUEUE_SMOOTH(atom)
/atom/proc/smooth_icon()
	if(QDELETED(src))
		return
	smoothing_flags &= ~SMOOTH_QUEUED
	flags_1 |= HTML_USE_INITAL_ICON_1
	if (!z)
		CRASH("[type] called smooth_icon() without being on a z-level")
	if(smoothing_flags & (SMOOTH_BITMASK|SMOOTH_BITMASK_CARDINALS))
		bitmask_smooth()
	else
		CRASH("smooth_icon called for [src] with smoothing_flags == [smoothing_flags]")
	SEND_SIGNAL(src, COMSIG_ATOM_SMOOTHED_ICON)

// As a rule, movables will most always care about smoothing changes
// Turfs on the other hand, don't, so we don't do the update for THEM unless they explicitly request it
/atom/movable/smooth_icon()
	. = ..()
	update_appearance(~UPDATE_SMOOTHING)

/**
 * Allows for more direct control over filtering smoothing targets. Only runs if SMOOTH_PROC_FILTER (OR SMOOTH_BORDER_OBJECT) is enabled
 * Called as a final point of decision on if a smooth should go through or not.
 *
 * NOTE: this proc NEEDS TO BE pure (same result if inputs with the same state are passed in, has no side effects)
 * You are taking some control away from the smoothing system, so you also need to force an update if something you are dependent on changes. This can be hard.
 *
 * atom/smoothing_with : the atom we are attemption to smooth with, or null if SMOOTH_BORDER is set and we're talking to the edge of the map
 * direction : the cardinal direction from us to our target atom (provided for convenience)
 * junction : the smoothing junction this atom would normally lie on (you almost always want to return this)
 *
 * Returns the junction to use (you almost always want this to just be junction)
*/
/atom/proc/smoothing_allowed(atom/smoothing_with, direction, junction)
	SHOULD_BE_PURE(TRUE)
	stack_trace("Unoverrided call to allow_smooth by [type], if you're going to have SMOOTH_PROC_FILTER (or SMOOTH_BORDER_OBJECT) set you need to do something with it")
	return NONE

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
	var/area/home_base = get_area(src)
	var/area_limited_icon_smoothing = home_base?.area_limited_icon_smoothing

	var/smooth_border = (smoothing_flags & SMOOTH_BORDER)
	var/smooth_obj = (smoothing_flags & SMOOTH_OBJ)
	var/border_object_smoothing = (smoothing_flags & SMOOTH_BORDER_OBJECT)
	var/smooth_proc_filter = (smoothing_flags & SMOOTH_PROC_FILTER)
	var/just_set_junction = !(border_object_smoothing || smooth_proc_filter)

	#define SEARCH_ADJ_IN_DIR(direction, direction_flag) \
		do {  \
			set_adj_in_dir: { \
			var/turf/neighbor = get_step(src, direction); \
			if(neighbor && (!area_limited_icon_smoothing || istype(neighbor.loc, area_limited_icon_smoothing))) { \
				var/neighbor_smoothing_groups = neighbor.smoothing_groups; \
				if(neighbor_smoothing_groups) { \
					SMOOTH_AGAINST(neighbor, direction, direction_flag, neighbor_smoothing_groups); \
				} \
				if(smooth_obj) { \
					for(var/atom/movable/thing as anything in neighbor) { \
						var/thing_smoothing_groups = thing.smoothing_groups; \
						if(!thing.anchored || isnull(thing_smoothing_groups)) { \
							continue; \
						}; \
						SMOOTH_AGAINST(thing, direction, direction_flag, thing_smoothing_groups); \
					} \
				} \
			} else if (smooth_border) { \
				JUNCTION_FOUND(null, direction, direction_flag); \
			} \
			} \
		} while(FALSE)

	#define SMOOTH_AGAINST(thing, direction, direction_flag, their_groups) \
		for(var/target in canSmoothWith) { \
			if(canSmoothWith[target] & their_groups[target] && \
				(!(thing.smoothing_flags & SMOOTH_PROC_FILTER) || thing.smoothing_allowed(src, REVERSE_DIR(direction), reverse_junction(direction_flag)))) { \
				JUNCTION_FOUND(thing, direction, direction_flag); \
			} \
		}

	#define JUNCTION_FOUND(target, direction, direction_flag) \
		if (just_set_junction) { \
			new_junction |= direction_flag; \
			break set_adj_in_dir; \
		} \
		if (border_object_smoothing) { \
			new_junction |= smoothing_allowed(target, direction, direction_flag); \
			break; /* border objects can find more then one junction on one turf, sooo */ \
		} \
		if(smooth_proc_filter) { \
			var/old_junction = new_junction; \
			new_junction |= smoothing_allowed(target, direction, direction_flag); \
			if(old_junction == new_junction) { \
				break; \
			} \
			break set_adj_in_dir; \
		}

	// Let's go over all our cardinals
	if(border_object_smoothing)
		SEARCH_ADJ_IN_DIR(NORTH, NORTH)
		SEARCH_ADJ_IN_DIR(SOUTH, SOUTH)
		SEARCH_ADJ_IN_DIR(EAST, EAST)
		SEARCH_ADJ_IN_DIR(WEST, WEST)
		// We want to check against stuff in our own turf
		SEARCH_ADJ_IN_DIR(NONE, NONE)
		// Border objects don't do diagonals, so GO HOME
		set_smoothed_icon_state(new_junction)
		return

	SEARCH_ADJ_IN_DIR(NORTH, NORTH)
	SEARCH_ADJ_IN_DIR(SOUTH, SOUTH)
	SEARCH_ADJ_IN_DIR(EAST, EAST)
	SEARCH_ADJ_IN_DIR(WEST, WEST)

	// If there's nothing going on already
	if(smoothing_flags & SMOOTH_BITMASK_CARDINALS || !(new_junction & (NORTH|SOUTH)) || !(new_junction & (EAST|WEST)))
		set_smoothed_icon_state(new_junction)
		return

	if(new_junction & NORTH_JUNCTION)
		if(new_junction & WEST_JUNCTION)
			SEARCH_ADJ_IN_DIR(NORTHWEST, NORTHWEST_JUNCTION)

		if(new_junction & EAST_JUNCTION)
			SEARCH_ADJ_IN_DIR(NORTHEAST, NORTHEAST_JUNCTION)

	if(new_junction & SOUTH_JUNCTION)
		if(new_junction & WEST_JUNCTION)
			SEARCH_ADJ_IN_DIR(SOUTHWEST, SOUTHWEST_JUNCTION)

		if(new_junction & EAST_JUNCTION)
			SEARCH_ADJ_IN_DIR(SOUTHEAST, SOUTHEAST_JUNCTION)

	set_smoothed_icon_state(new_junction)

	#undef JUNCTION_FOUND
	#undef SMOOTH_AGAINST
	#undef SEARCH_ADJ_IN_DIR

#define DEFAULT_UNDERLAY_ICON 'icons/turf/floors.dmi'
#define DEFAULT_UNDERLAY_ICON_STATE "plating"

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
			icon_state = "[base_icon_state]-[smoothing_junction]-diagonal"
			if(new_junction == old_junction || fixed_underlay) // Mutable underlays?
				return

			var/junction_dir = reverse_ndir(smoothing_junction)
			var/turned_adjacency = REVERSE_DIR(junction_dir)
			var/turf/neighbor_turf = get_step(src, turned_adjacency & (NORTH|SOUTH))
			var/mutable_appearance/underlay_appearance = mutable_appearance(layer = LOW_FLOOR_LAYER, offset_spokesman = src, plane = FLOOR_PLANE)
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

#undef DEFAULT_UNDERLAY_ICON
#undef DEFAULT_UNDERLAY_ICON_STATE

//Icon smoothing helpers
/proc/smooth_zlevel(zlevel, now = FALSE)
	var/list/away_turfs = Z_TURFS(zlevel)
	for(var/turf/turf_to_smooth as anything in away_turfs)
		if(turf_to_smooth.smoothing_flags & USES_SMOOTHING)
			if(now)
				turf_to_smooth.smooth_icon()
			else
				QUEUE_SMOOTH(turf_to_smooth)
		for(var/atom/movable/movable_to_smooth as anything in turf_to_smooth)
			if(movable_to_smooth.smoothing_flags & USES_SMOOTHING)
				if(now)
					movable_to_smooth.smooth_icon()
				else
					QUEUE_SMOOTH(movable_to_smooth)

/atom/proc/set_can_smooth_with(canSmoothWith)
	if(!canSmoothWith)
		src.canSmoothWith = null
		return
	PARSE_CAN_SMOOTH_WITH(canSmoothWith, src.canSmoothWith, smoothing_flags)

/atom/proc/set_smoothing_groups(smoothing_groups)
	if(!smoothing_groups)
		src.smoothing_groups = null
		return
	PARSE_SMOOTHING_GROUPS(smoothing_groups, src.smoothing_groups)

/// Takes a direction, turns it into all the junctions that contain it
/proc/dir_to_all_junctions(dir)
	var/handback = NONE
	if(dir & NORTH)
		handback |= NORTH_JUNCTION | NORTHEAST_JUNCTION | NORTHWEST_JUNCTION
	if(dir & SOUTH)
		handback |= SOUTH_JUNCTION | SOUTHEAST_JUNCTION | SOUTHWEST_JUNCTION
	if(dir & EAST)
		handback |= EAST_JUNCTION | SOUTHEAST_JUNCTION | NORTHEAST_JUNCTION
	if(dir & WEST)
		handback |= WEST_JUNCTION | NORTHWEST_JUNCTION | SOUTHWEST_JUNCTION
	return handback

/proc/dir_to_junction(dir)
	switch(dir)
		if(NORTH)
			return NORTH_JUNCTION
		if(SOUTH)
			return SOUTH_JUNCTION
		if(WEST)
			return WEST_JUNCTION
		if(EAST)
			return EAST_JUNCTION
		if(NORTHWEST)
			return NORTHWEST_JUNCTION
		if(NORTHEAST)
			return NORTHEAST_JUNCTION
		if(SOUTHEAST)
			return SOUTHEAST_JUNCTION
		if(SOUTHWEST)
			return SOUTHWEST_JUNCTION
		else
			return NONE

/proc/reverse_junction(junction)
	var/handback = NONE
	if(junction & NORTH_JUNCTION)
		handback |= SOUTH_JUNCTION
	if(junction & SOUTH_JUNCTION)
		handback |= NORTH_JUNCTION
	if(junction & EAST_JUNCTION)
		handback |= WEST_JUNCTION
	if(junction & WEST_JUNCTION)
		handback |= EAST_JUNCTION
	if(junction & NORTHEAST_JUNCTION)
		handback |= SOUTHWEST_JUNCTION
	if(junction & SOUTHWEST_JUNCTION)
		handback |= NORTHEAST_JUNCTION
	if(junction & NORTHWEST_JUNCTION)
		handback |= SOUTHEAST_JUNCTION
	if(junction & SOUTHEAST_JUNCTION)
		handback |= NORTHWEST_JUNCTION
	return handback

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
	icon_state = "smooth_wall-0"
	base_icon_state = "smooth_wall"
	smoothing_flags = SMOOTH_BITMASK|SMOOTH_DIAGONAL_CORNERS|SMOOTH_BORDER
	smoothing_groups = SMOOTH_GROUP_TEST_WALL
	canSmoothWith = SMOOTH_GROUP_TEST_WALL
