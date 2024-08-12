#define VIS_BLOCK_FLAGS (RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM|NO_CLIENT_COLOR|KEEP_TOGETHER)
/// Abstract object that gets smoothed,
/// used to allow code to get smoothing junctions for more then one "class of thing" at a time
/// (while not breaking our existing system)
/// Bit of a hack but that's life atm
/obj/effect/abstract/finder
	// To make smoothin work
	anchored = TRUE
	invisibility = INVISIBILITY_MAXIMUM
	smoothing_flags = SMOOTH_BITMASK

/obj/effect/abstract/finder/wall
	canSmoothWith = SMOOTH_GROUP_TALL_WALLS

/obj/effect/abstract/finder/vis_block
	smoothing_groups = SMOOTH_GROUP_VIS_BLOCK
	canSmoothWith = SMOOTH_GROUP_VIS_BLOCK

/obj/effect/abstract/finder/Initialize(mapload)
	. = ..()
	if(smoothing_flags & (SMOOTH_BITMASK|SMOOTH_CORNERS|SMOOTH_BORDER_OBJECT) && isturf(loc))
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)

/obj/effect/abstract/finder/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if(!(smoothing_flags & (SMOOTH_BITMASK|SMOOTH_CORNERS|SMOOTH_BORDER_OBJECT)))
		return
	if(isturf(old_loc))
		QUEUE_SMOOTH_NEIGHBORS(old_loc)
	if(isturf(loc))
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)
	else
		SSicon_smooth.remove_from_queues(src)

/// Applies directional opacity through a series of "vis" overlays
/// (drawing darkness onto our main object, and masks of that darkness on the turfs around us)
/datum/component/vis_block
	/// List of direction -> mask to display
	var/list/mutable_appearance/direction_to_mask = list()
	/// Abstract object we keep on our turf to use (with smoothing) to keep track of adjacent walls
	var/obj/effect/abstract/finder/wall/stud_finder
	/// Abstract object we keep on our turf to use (with smoothing) to keep track of other instances of active vis_block
	var/obj/effect/abstract/finder/vis_block/us_finder
	/// Are we applying partial inner darkness right now
	var/partial_darkness = FALSE
	/// Are we actively blocking sight right now or not
	var/actively_blocking = FALSE
	/// What directions in which we do not fully cover our darkness with masks
	var/dir_mask = NONE
	/// Similar to the above but used for cases where walls are adjacent
	var/edge_dir_mask = NONE
	/// Allows for full directional visibility
	/// Icon state prefix to use for masks from vis_mask.dmi
	var/inner_transparent_dirs = NONE
	/// Hack to get around the offset we use to hack an issue with vis_contents and large objects
	/// Shifts overlays (ON OUR PARENT)'s z position by this amount
	var/parent_z_shift = 0
	/// Directions in which there is a wall
	var/wall_junction = NONE
	/// Directions in which there is another active source of vis_block
	var/us_junction = NONE

/datum/component/vis_block/Initialize(dir_mask, edge_dir_mask, inner_transparent_dirs = NONE, parent_z_shift = 0)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/atom_parent = parent
	src.dir_mask = dir_mask
	src.edge_dir_mask = edge_dir_mask
	src.inner_transparent_dirs = inner_transparent_dirs
	src.parent_z_shift = parent_z_shift
	RegisterSignal(atom_parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(dir_changing))
	RegisterSignal(atom_parent, COMSIG_ATOM_SET_OPACITY, PROC_REF(opacity_changing))
	RegisterSignal(atom_parent, COMSIG_MOVABLE_MOVED, PROC_REF(parent_moved))
	stud_finder = new(atom_parent.loc)
	wall_junction = stud_finder.smoothing_junction
	RegisterSignal(stud_finder, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE, PROC_REF(wall_state_changed))
	us_finder = new(null)
	RegisterSignal(us_finder, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE, PROC_REF(vis_block_state_changed))
	handle_new_position()

/datum/component/vis_block/Destroy(force)
	var/atom/atom_parent = parent
	clear_opacity(atom_parent)
	QDEL_NULL(stud_finder)
	QDEL_NULL(us_finder)
	return ..()

/datum/component/vis_block/proc/dir_changing(datum/source, old_dir, new_dir)
	SIGNAL_HANDLER
	var/atom/atom_parent = parent
	regenerate_opacity(new_dir, atom_parent.opacity)

/datum/component/vis_block/proc/opacity_changing(datum/source, new_opacity)
	SIGNAL_HANDLER
	var/atom/atom_parent = parent
	regenerate_opacity(atom_parent.dir, new_opacity)

/datum/component/vis_block/proc/parent_moved(datum/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER
	UnregisterSignal(old_loc, SIGNAL_REMOVETRAIT(TRAIT_INNER_DARKNESS))
	if(inner_transparent_dirs)
		REMOVE_TRAIT(old_loc, TRAIT_INNER_DARKNESS, WEAKREF(src))
	clear_opacity(old_loc)
	handle_new_position()

/datum/component/vis_block/proc/overlay_home_changing(turf/source, path, list/new_baseturfs, flags, list/post_change_callbacks)
	SIGNAL_HANDLER
	post_change_callbacks += CALLBACK(src, PROC_REF(overlay_home_changed), source)

/datum/component/vis_block/proc/overlay_home_changed(turf/changed)
	SHOULD_NOT_SLEEP(TRUE)
	var/atom/atom_parent = parent
	var/turf/home = get_turf(atom_parent)
	var/mutable_appearance/overlay = direction_to_mask["[get_dir(home, changed)]"]
	if(!overlay)
		return

	// Rare case, avoids potential race condition
	changed.cut_overlay(overlay)
	changed.add_overlay(overlay)

/datum/component/vis_block/proc/wall_state_changed(datum/source, new_junction)
	SIGNAL_HANDLER
	wall_junction = new_junction
	var/atom/atom_parent = parent
	regenerate_opacity(atom_parent.dir, atom_parent.opacity)

/datum/component/vis_block/proc/vis_block_state_changed(datum/source, new_junction)
	SIGNAL_HANDLER
	us_junction = new_junction
	var/atom/atom_parent = parent
	regenerate_opacity(atom_parent.dir, atom_parent.opacity)

/datum/component/vis_block/proc/inner_darkness_inactive(datum/source)
	SIGNAL_HANDLER
	if(!partial_darkness)
		return
	var/atom/atom_parent = parent
	var/turf/home = atom_parent.loc
	if(HAS_TRAIT(home, TRAIT_INNER_DARKNESS))
		return
	regenerate_opacity(atom_parent.dir, atom_parent.opacity)

/datum/component/vis_block/proc/handle_new_position()
	var/atom/atom_parent = parent
	stud_finder.forceMove(atom_parent.loc)
	if(actively_blocking)
		us_finder.forceMove(atom_parent.loc)
	generate_opacity(atom_parent.dir, atom_parent.opacity)
	RegisterSignal(atom_parent.loc, SIGNAL_REMOVETRAIT(TRAIT_INNER_DARKNESS), PROC_REF(inner_darkness_inactive))

/datum/component/vis_block/proc/regenerate_opacity(dir, opacity)
	var/atom/atom_parent = parent
	clear_opacity(atom_parent)
	generate_opacity(dir, opacity)

/datum/component/vis_block/proc/clear_opacity(atom/center)
	var/atom/atom_parent = parent
	var/turf/old_home = get_turf(center)
	atom_parent.cut_overlay(direction_to_mask["0"])
	for(var/check_dir in GLOB.cardinals)
		var/mutable_appearance/dir_overlay = direction_to_mask["[check_dir]"]
		if(!dir_overlay)
			continue
		var/turf/in_direction = get_step(old_home, check_dir)
		if(!in_direction)
			continue
		in_direction.cut_overlay(dir_overlay)
		UnregisterSignal(in_direction, COMSIG_TURF_CHANGE)
	if(partial_darkness)
		partial_darkness = FALSE
		REMOVE_TRAIT(atom_parent.loc, TRAIT_INNER_DARKNESS, WEAKREF(src))
	direction_to_mask = list()

/datum/component/vis_block/proc/generate_opacity(dir, opacity)
	var/atom/atom_parent = parent
	if(!isturf(atom_parent.loc) || !opacity)
		if(actively_blocking)
			actively_blocking = FALSE
			us_finder.moveToNullspace()
		return
	if(!actively_blocking)
		actively_blocking = TRUE
		us_finder.forceMove(atom_parent.loc)
	var/turf/home = atom_parent.loc

	/// This is the darkness everything else will be masking out
	var/mutable_appearance/darkness_base = mutable_appearance('icons/effects/vis_darkness.dmi', "[wall_junction]", offset_spokesman = atom_parent, plane = DARKNESS_MASK_PLANE, appearance_flags = VIS_BLOCK_FLAGS|KEEP_APART)
	darkness_base.pixel_w = -5
	darkness_base.pixel_z = parent_z_shift
	partial_darkness = FALSE
	for(var/check_dir in GLOB.cardinals)
		if(!(check_dir & (dir | REVERSE_DIR(dir))))
			// If we are not up against one of our own own, OR a wall
			if(check_dir & (wall_junction|us_junction))
				continue
			// AND we have holes in our darkness (an "inside")
			if(inner_transparent_dirs == NONE)
				continue
			// Then we draw a mask on ourselves, on our OWN turf, to allow say the turf below some vertical headroom
			darkness_base.add_overlay(mutable_appearance('icons/effects/vis_mask.dmi', "[edge_dir_mask]_dark_edge_[dir2text(check_dir)]", HIGHEST_GAME_LAYER, offset_spokesman = atom_parent, plane = DARKNESS_MASK_PLANE, appearance_flags = VIS_BLOCK_FLAGS))
			continue
		var/turf/in_direction = get_step(home, check_dir)
		if(!in_direction)
			continue

		// Base mask applied to darkness, masks out only the side we can see (since we overlay it on the turf facing said side)
		var/mutable_appearance/mask = mutable_appearance('icons/effects/vis_mask.dmi', dir_mask, HIGHEST_GAME_LAYER, offset_spokesman = atom_parent, plane = DARKNESS_MASK_PLANE, appearance_flags = VIS_BLOCK_FLAGS|KEEP_APART)
		mask = make_mutable_appearance_directional(mask)
		mask.dir = check_dir
		mask.pixel_w = -5
		switch(check_dir)
			if(NORTH)
				mask.pixel_y = -32
			if(SOUTH)
				mask.pixel_y = 32
			if(EAST)
				mask.pixel_x = -32
			if(WEST)
				mask.pixel_x = 32

		// These handle connecting edges with walls
		// (since they have different bounds and I want to show walls say, going in slightly in some cases without doing the same to connected blockers)
		if(wall_junction & NORTH)
			mask.add_overlay(mutable_appearance(mask.icon, "[edge_dir_mask]_edge_north", appearance_flags = VIS_BLOCK_FLAGS))
		if(wall_junction & SOUTH)
			mask.add_overlay(mutable_appearance(mask.icon, "[edge_dir_mask]_edge_south", appearance_flags = VIS_BLOCK_FLAGS))
		if(wall_junction & EAST)
			mask.add_overlay(mutable_appearance(mask.icon, "[edge_dir_mask]_edge_east", appearance_flags = VIS_BLOCK_FLAGS))
		if(wall_junction & WEST)
			mask.add_overlay(mutable_appearance(mask.icon, "[edge_dir_mask]_edge_west", appearance_flags = VIS_BLOCK_FLAGS))
		// If our inside is transparent in this case, draw the standard darkness
		// Using a half alpha and BLEND_SUBTRACT
		// This way if both stack we'll get darkness and opacity, and if they don't nothing will happen
		// Also only apply once per turf to avoid breaking on overlap
		if(check_dir & inner_transparent_dirs)
			partial_darkness = TRUE
			if(!HAS_TRAIT(home, TRAIT_INNER_DARKNESS) || HAS_TRAIT_FROM(home, TRAIT_INNER_DARKNESS, WEAKREF(src)))
				ADD_TRAIT(home, TRAIT_INNER_DARKNESS, WEAKREF(src))
				var/mutable_appearance/half_darken = mutable_appearance('icons/effects/vis_darkness.dmi', "[wall_junction]", alpha = 130, appearance_flags = VIS_BLOCK_FLAGS)
				half_darken.blend_mode = BLEND_SUBTRACT
				mask.add_overlay(half_darken)

		in_direction.add_overlay(mask)
		direction_to_mask["[check_dir]"] = mask
		RegisterSignal(in_direction, COMSIG_TURF_CHANGE, PROC_REF(overlay_home_changing))
	direction_to_mask["0"] = darkness_base
	atom_parent.add_overlay(darkness_base)

#undef VIS_BLOCK_FLAGS
