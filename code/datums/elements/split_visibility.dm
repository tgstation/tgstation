

// Hello lads
// This element exists so sides of a turf "pop off" it visually, preventing weird popin when you walk below it
// It also ensures you can't see anything but the side visible to you, which makes walking in say, maint a lot nicer
// It's not finished yet, which is why this file isn't ticked. We need to rework how sprite files get split up
// For now tho, it'll just sit here

/mutable_appearance/split_vis

/mutable_appearance/split_vis/New()
	. = ..()
	// Need to do this here because it's overriden by the parent call
	appearance_flags = TILE_BOUND

GLOBAL_LIST_EMPTY(split_visibility_objects)

/proc/get_splitvis_object(turf/apply_to, icon_path, junction, dir, shadow = FALSE, alpha = 255, pixel_x = 0, pixel_y = 0, plane = WALL_PLANE, layer = ABOVE_MOB_LAYER)
	var/offset = GET_TURF_PLANE_OFFSET(apply_to)
	var/key = "[icon_path]-[junction]-[dir]-[shadow]-[alpha]-[pixel_x]-[pixel_y]-[plane]-[layer]-[offset]"
	var/mutable_appearance/split_vis/vis = GLOB.split_visibility_objects[key]
	if(vis)
		return vis

	vis = new /mutable_appearance/split_vis()
	vis.icon = icon_path
	var/junc = junction ? junction : "0"
	vis.icon_state = "[junc]"
	vis.dir = dir
	if(shadow)
		vis.overlays += get_splitvis_object(apply_to, icon_path, junction, dir, FALSE, 120, pixel_x = 0, pixel_y = 0, plane = UNDER_FRILL_PLANE)
	vis.alpha = alpha
/*
	vis.pixel_x = pixel_x
	vis.pixel_y = pixel_y
*/
	SET_PLANE_W_SCALAR(vis, plane, offset)
	vis.layer = layer

	GLOB.split_visibility_objects[key] = vis
	return vis

/datum/element/split_visibility
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2
	var/icon_path

/datum/element/split_visibility/Attach(datum/target, icon_path)
	if(!isturf(target)) // Turfs only cause this would do wacky shit on things that can move
		return ELEMENT_INCOMPATIBLE
	. = ..()
	var/turf/target_turf = target
	if(!target_turf.opacity)
		CRASH("Just attempted to attach a split visibility object to [target] which is not opaque. This makes no sense.")

	// Temporary stuff to hide that we don't have good "over" sprites
	target_turf.icon = 'wall_blackness.dmi'
	target_turf.icon_state = "wall_background"
	// End temp code

	src.icon_path = icon_path

	add_split_vis_objects(target_turf, icon_path)
	RegisterSignal(target, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE, .proc/on_junction_change)

#define DIR_TO_PIXEL_Y(dir) ((dir & NORTH) ? 32 : (dir & SOUTH) ? -32 : 0)
#define DIR_TO_PIXEL_X(dir) ((dir & EAST) ? 32 : (dir & WEST) ? -32 : 0)


/datum/element/split_visibility/proc/add_split_vis_objects(turf/target_turf, icon_path, new_junction)
	apply_splitvis_objs(target_turf, icon_path, new_junction)

/datum/element/split_visibility/proc/remove_split_vis_objects(turf/target_turf, icon_path, new_junction)
	apply_splitvis_objs(target_turf, icon_path, new_junction, add_to_turfs = FALSE)

/turf
	var/icon_state_key

/datum/element/split_visibility/proc/apply_splitvis_objs(turf/target_turf, icon_path, new_junction, add_to_turfs = TRUE)
	var/static/frilled_dirs = (NORTH)

	var/junction = new_junction
	if(isnull(junction))
		junction = target_turf.smoothing_junction

	for(var/direction in GLOB.cardinals)
		// If we're connected in this direction, please don't draw a wall side
		if((junction & direction) == direction)
			continue

		var/active_plane = WALL_PLANE
		var/uses_shadow = FALSE
		if(direction & frilled_dirs)
			active_plane = FRILL_PLANE
			uses_shadow = TRUE

		var/turf/operating_turf = get_step(target_turf, direction)
		// Right up against an edge of the map eh?
		if(!operating_turf)
			continue

		var/mutable_appearance/split_vis/vis = get_splitvis_object(operating_turf, icon_path, junction, direction, uses_shadow, 255, -DIR_TO_PIXEL_X(direction), -DIR_TO_PIXEL_Y(direction), active_plane)
		if(add_to_turfs)
			operating_turf.overlays += vis
		else
			operating_turf.overlays -= vis

	for(var/direction in GLOB.diagonals)
		// If we're not connected in this direction, don't draw a joiner
		if((junction & direction) != direction)
			continue

		var/turf/operating_turf = get_step(target_turf, direction)
		// Right up against an edge of the map eh?
		if(!operating_turf)
			continue

		var/mutable_appearance/split_vis/vis = get_splitvis_object(operating_turf, icon_path, junction, direction, FALSE, 255, -DIR_TO_PIXEL_X(direction), -DIR_TO_PIXEL_Y(direction), layer = WALL_OBJ_LAYER)

		if(add_to_turfs)
			operating_turf.overlays += vis
		else
			operating_turf.overlays -= vis

/datum/element/split_visibility/Detach(turf/target)
	remove_split_vis_objects(target, icon_path)
	UnregisterSignal(target, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE)
	return ..()


/datum/element/split_visibility/proc/on_junction_change(atom/source, new_junction)
	SIGNAL_HANDLER
	var/turf/turf_or_movable = source
	remove_split_vis_objects(turf_or_movable, icon_path)
	add_split_vis_objects(turf_or_movable, icon_path, new_junction)
