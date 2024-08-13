/// Lookup table for diagonal -> junction
GLOBAL_LIST_INIT(diagonal_junctions, generate_splitvis_lookup())

/proc/generate_splitvis_lookup()
	// It should be as long as all 4 directions combined, so it can act as a lookup for all of them
	var/list/diagonal_to_junction = new /list(NORTH|SOUTH|EAST|WEST)
	// Set defaults
	for(var/i in 1 to length(diagonal_to_junction))
		diagonal_to_junction[i] = NONE
	diagonal_to_junction[NORTH|EAST] = dir_to_junction(NORTH|EAST)
	diagonal_to_junction[SOUTH|EAST] = dir_to_junction(SOUTH|EAST)
	diagonal_to_junction[SOUTH|WEST] = dir_to_junction(SOUTH|WEST)
	diagonal_to_junction[NORTH|WEST] = dir_to_junction(NORTH|WEST)
	return diagonal_to_junction

/mutable_appearance/split_vis

/mutable_appearance/split_vis/New()
	. = ..()
	// Need to do this here because it's overriden by the parent call
	appearance_flags = TILE_BOUND | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM

// Thinking on it, we really only need to generate a copy for each direction accounting for frill, and then just set the overlay based off that
// Except that doesn't work with frills, but frills don't vary by direction, and frills could inherit icon/state from the parent with appearance flags
/proc/get_splitvis_object(z_offset, icon_path, junction, dir, color, pixel_x = 0, pixel_y = 0, plane = GAME_PLANE, layer = WALL_LAYER, cache = TRUE)
	var/key = "[icon_path]-[junction]-[dir]-[color]-[pixel_x]-[pixel_y]-[plane]-[layer]-[z_offset]"
	// FUCKING GLOBAL CONTEXT
	var/static/list/split_visibility_objects = list()
	var/mutable_appearance/split_vis/vis = split_visibility_objects[key]
	if(vis && cache)
		return vis

	vis = new /mutable_appearance/split_vis()
	vis.icon = icon_path
	vis.icon_state = "[junction || "0"]-[dir]"
	vis.color = color
	vis.pixel_x = pixel_x
	vis.pixel_y = pixel_y
	SET_PLANE_W_SCALAR(vis, plane, z_offset)
	vis.layer = layer

	if(cache)
		split_visibility_objects[key] = vis
	return vis

/// Generates a mutable appearance of the passed in junction
/// Needs to be kept in parity with the non offsetting bits of [/datum/element/split_vis/proc/apply_splitvis_objs]
/// I'm sorry bros
/proc/generate_joined_wall(icon_path, junction, color, draw_darkness = TRUE)
	var/list/overlays = list()
	if(draw_darkness)
		overlays += mutable_appearance('icons/turf/walls/wall_blackness.dmi', "wall_background", layer = FLOAT_LAYER - 1, appearance_flags = TILE_BOUND | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM)

	// This lets us do O(1) logic down later, and ensure logic works as we'd like
	var/static/list/diagonal_to_junction = generate_splitvis_lookup()
	// You might ask "lemon why are you using lists of directions here instead of the GLOBs"
	// it's because we use this proc in a global context, so it cannot rely on OTHER globals. I hate byond
	for(var/direction in list(NORTH, SOUTH, EAST, WEST))
		// If we're connected in this direction, please don't draw a wall side
		if((junction & direction) == direction)
			continue
		overlays += get_splitvis_object(0, icon_path, junction, direction, color, plane = FLOAT_PLANE, layer = FLOAT_LAYER, cache = FALSE)

	for(var/direction in list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
		// If we're connected in the two components of this direction
		if((junction & direction) != direction)
			continue
		// AND if we're not connected to anything in the SUM of those directions
		var/diagonal_junction = diagonal_to_junction[direction]
		if((junction & diagonal_junction) == diagonal_junction)
			continue

		overlays += get_splitvis_object(0, icon_path, "innercorner", direction, color, plane = FLOAT_PLANE, layer = FLOAT_LAYER, cache = FALSE)

	var/mutable_appearance/holder = mutable_appearance(appearance_flags = KEEP_TOGETHER)
	holder.overlays += overlays
	return holder

// Hello lads
// This element exists so sides of a turf "pop off" it visually, preventing weird popin when you walk below it
// It also ensures you can't see anything but the side visible to you, which makes walking in say, maint a lot nicer
/datum/element/split_visibility
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY | ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/icon_path
	var/color

/datum/element/split_visibility/Attach(datum/target, icon_path, color)
	if(!isatom(target)) // Turfs only cause this would do wacky shit on things that can move
		return ELEMENT_INCOMPATIBLE
	. = ..()
	var/atom/target_atom = target
	if(!(target_atom.smoothing_flags & (SMOOTH_BITMASK|SMOOTH_BITMASK_CARDINALS)))
		CRASH("We tried to splitvis [target.type] without bitmask smoothing. What?")

	target_atom.add_overlay(mutable_appearance('icons/turf/walls/wall_blackness.dmi', "wall_background", UNDER_WALL_LAYER, target_atom, GAME_PLANE))
	// We draw a copy to the wall plane so we can use it to mask byond darkness, that's all
	target_atom.add_overlay(mutable_appearance('icons/turf/walls/wall_blackness.dmi', "wall_background", UNDER_WALL_LAYER, target_atom, WALL_PLANE))
	// Ensures when you try to click on a turf, you actually click on the turf, and not the adjacent things holding it
	target_atom.add_overlay(mutable_appearance('icons/turf/walls/wall_blackness.dmi', "wall_clickcatcher", WALL_CLICKCATCH_LAYER, target_atom, GAME_PLANE))

	src.icon_path = icon_path
	src.color = color

	if(ismovable(target))
		RegisterSignal(target, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE, PROC_REF(on_movable_junction_change))
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
		if(isturf(target_atom.loc))
			var/ref = REF(target)
			ADD_TRAIT(target_atom.loc, TRAIT_CONTAINS_SPLITVIS, ref)
			if(!HAS_TRAIT(target_atom.loc, TRAIT_CONTAINS_SPLITVIS))
				RegisterSignal(target_atom.loc, COMSIG_TURF_CHANGE, PROC_REF(on_movable_turf_change))
			add_split_vis_objects(target_atom.loc, target_atom.smoothing_junction)
	else
		ADD_TRAIT(target, TRAIT_CONTAINS_SPLITVIS, UNLINT(src)) // We use src here because this code is hot, and we assert that bespoke elements cannot self delete. Not a good pattern but fast
		RegisterSignal(target, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE, PROC_REF(on_turf_junction_change))
		add_split_vis_objects(target_atom, target_atom.smoothing_junction)


/datum/element/split_visibility/proc/add_split_vis_objects(turf/target_turf, junction)
	apply_splitvis_objs(target_turf, junction)
	target_turf.set_lighting_state("[junction]")

/datum/element/split_visibility/proc/remove_split_vis_objects(turf/target_turf, junction)
	apply_splitvis_objs(target_turf, junction, add_to_turfs = FALSE)
	target_turf.set_lighting_state("lighting")

/datum/element/split_visibility/proc/apply_splitvis_objs(turf/target_turf, junction, add_to_turfs = TRUE)
	// cache for sonic speed
	var/icon_path = src.icon_path
	var/color = src.color

	var/offset = GET_Z_PLANE_OFFSET(target_turf.z)

	// This lets us do O(1) logic down later, and ensure logic works as we'd like
	var/list/diagonal_to_junction = GLOB.diagonal_junctions

	for(var/direction in GLOB.cardinals)
		// If we're connected in this direction, please don't draw a wall side
		if((junction & direction) == direction)
			continue

		var/active_plane = GAME_PLANE
		if(direction & NORTH)
			active_plane = FRILL_PLANE

		var/turf/operating_turf = get_step(target_turf, direction)
		// Right up against an edge of the map eh?
		if(!operating_turf)
			continue

		if(add_to_turfs)
			var/mutable_appearance/split_vis/vis
			// If we're trying to draw to something with splitvis, just draw to yourself, and use the hidden wall plane
			if(HAS_TRAIT(operating_turf, TRAIT_CONTAINS_SPLITVIS))
				vis = get_splitvis_object(offset, icon_path, junction, direction, color, 0, 0, HIDDEN_WALL_PLANE)
				target_turf.overlays += vis
			else
				vis = get_splitvis_object(offset, icon_path, junction, direction, color, -DIR_TO_PIXEL_X(direction), -DIR_TO_PIXEL_Y(direction), active_plane)
				operating_turf.overlays += vis
		else
			// I HATE the code duping, but we need to try both to ensure it's properly cleared
			var/mutable_appearance/split_vis/vis
			vis = get_splitvis_object(offset, icon_path, junction, direction, color, 0, 0, HIDDEN_WALL_PLANE)
			target_turf.overlays -= vis
			vis = get_splitvis_object(offset, icon_path, junction, direction, color, -DIR_TO_PIXEL_X(direction), -DIR_TO_PIXEL_Y(direction), active_plane)
			operating_turf.overlays -= vis

	for(var/direction in GLOB.diagonals)
		// If we're connected in the two components of this direction
		if((junction & direction) != direction)
			continue
		// AND if we're not connected to anything in the SUM of those directions
		var/diagonal_junction = diagonal_to_junction[direction]
		if((junction & diagonal_junction) == diagonal_junction)
			continue

		var/turf/operating_turf = get_step(target_turf, direction)
		// Right up against an edge of the map eh?
		if(!operating_turf)
			continue

		if(!add_to_turfs)
			// I HATE the code duping, but we need to try both to ensure it's properly cleared
			var/mutable_appearance/split_vis/vis
			vis = get_splitvis_object(offset, icon_path, "innercorner", direction, color, 0, 0, HIDDEN_WALL_PLANE, ABOVE_WALL_LAYER)
			target_turf.overlays -= vis
			vis = get_splitvis_object(offset, icon_path, "innercorner", direction, color, -DIR_TO_PIXEL_X(direction), -DIR_TO_PIXEL_Y(direction), layer = ABOVE_WALL_LAYER)
			operating_turf.overlays -= vis
			continue
		var/mutable_appearance/split_vis/vis
		// If we're trying to draw to something with splitvis, just draw to yourself, and use the hidden wall plane
		// Wallening todo: Frills should block emissives
		if(HAS_TRAIT(operating_turf, TRAIT_CONTAINS_SPLITVIS))
			vis = get_splitvis_object(offset, icon_path, "innercorner", direction, color, 0, 0, HIDDEN_WALL_PLANE, ABOVE_WALL_LAYER)
			target_turf.overlays += vis
		else
			vis = get_splitvis_object(offset, icon_path, "innercorner", direction, color, -DIR_TO_PIXEL_X(direction), -DIR_TO_PIXEL_Y(direction), layer = ABOVE_WALL_LAYER)
			operating_turf.overlays += vis


/datum/element/split_visibility/Detach(atom/target)
	target.cut_overlay(mutable_appearance('icons/turf/walls/wall_blackness.dmi', "wall_background", UNDER_WALL_LAYER, target, GAME_PLANE))
	// We draw a copy to the wall plane so we can use it to mask byond darkness, that's all
	target.cut_overlay(mutable_appearance('icons/turf/walls/wall_blackness.dmi', "wall_background", UNDER_WALL_LAYER, target, WALL_PLANE))
	// Ensures when you try to click on a turf, you actually click on the turf, and not the adjacent things holding it
	target.cut_overlay(mutable_appearance('icons/turf/walls/wall_blackness.dmi', "wall_clickcatcher", WALL_CLICKCATCH_LAYER, target, GAME_PLANE))
	UnregisterSignal(target, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE)
	if(ismovable(target))
		UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
		if(isturf(target.loc))
			remove_split_vis_objects(target.loc, target.smoothing_junction)
			var/ref = REF(target)
			REMOVE_TRAIT(target.loc, TRAIT_CONTAINS_SPLITVIS, ref)
			if(!HAS_TRAIT(target.loc, TRAIT_CONTAINS_SPLITVIS))
				UnregisterSignal(target.loc, COMSIG_TURF_CHANGE)

	else
		remove_split_vis_objects(target, target.smoothing_junction)
		REMOVE_TRAIT(target, TRAIT_CONTAINS_SPLITVIS, UNLINT(src)) // We use src here because this code is hot, and we assert that bespoke elements cannot self delete. Not a good pattern but fast
	return ..()

/datum/element/split_visibility/proc/on_turf_junction_change(turf/source, new_junction)
	SIGNAL_HANDLER
	remove_split_vis_objects(source, source.smoothing_junction)
	add_split_vis_objects(source, new_junction)

/datum/element/split_visibility/proc/on_movable_junction_change(atom/movable/source, new_junction)
	SIGNAL_HANDLER
	if(isturf(source.loc))
		remove_split_vis_objects(source.loc, source.smoothing_junction)
		add_split_vis_objects(source.loc, new_junction)

/datum/element/split_visibility/proc/on_movable_turf_change(turf/source, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER
	// I am EVEN MORE SORRY FUCKKKKK
	// This is a wacko case, traits as lists AHHHHH
	for(var/ref in GET_TRAIT_SOURCES(source, TRAIT_CONTAINS_SPLITVIS))
		var/atom/thing = locate(ref)
		if(thing.loc != source)
			continue
		post_change_callbacks += CALLBACK(src, PROC_REF(movable_post_turf_change), thing)

/datum/element/split_visibility/proc/movable_post_turf_change(atom/movable/parent, turf/changed)
	changed.set_lighting_state("[parent.smoothing_junction]")

/datum/element/split_visibility/proc/on_move(atom/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	var/ref = REF(source)
	if(isturf(old_loc))
		remove_split_vis_objects(old_loc, source.smoothing_junction) // We trust that junction changing will create the new visuals. just gotta cover the old
		QUEUE_SMOOTH_NEIGHBORS(old_loc)
		REMOVE_TRAIT(old_loc, TRAIT_CONTAINS_SPLITVIS, ref)
		if(!HAS_TRAIT(old_loc, TRAIT_CONTAINS_SPLITVIS))
			UnregisterSignal(old_loc, COMSIG_TURF_CHANGE)
	QUEUE_SMOOTH(source)
	QUEUE_SMOOTH_NEIGHBORS(source)
	if(isturf(source.loc))
		ADD_TRAIT(source.loc, TRAIT_CONTAINS_SPLITVIS, ref)
		if(!HAS_TRAIT(source.loc, TRAIT_CONTAINS_SPLITVIS))
			RegisterSignal(source.loc, COMSIG_TURF_CHANGE, PROC_REF(on_movable_turf_change))
