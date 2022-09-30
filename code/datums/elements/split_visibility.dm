

// Hello lads
// This element exists so sides of a turf "pop off" it visually, preventing weird popin when you walk below it
// It also ensures you can't see anything but the side visible to you, which makes walking in say, maint a lot nicer
// It's not finished yet, which is why this file isn't ticked. We need to rework how sprite files get split up
// For now tho, it'll just sit here


GLOBAL_LIST_EMPTY(split_visibility_objects)
/proc/get_splitvis_object(icon_path, junction, dir, shadow = FALSE, alpha = 255, pixel_x = 0, pixel_y = 0, plane = WALL_PLANE, layer = ABOVE_MOB_LAYER)
	var/key = "[icon_path]-[junction]-[dir]-[shadow]-[alpha]-[pixel_x]-[pixel_y]-[plane]-[layer]"
	var/atom/movable/visual/split_vis/vis = GLOB.split_visibility_objects[key]
	if(vis)
		return vis

	vis = new /atom/movable/visual/split_vis(null, icon_path, junction, dir, shadow, alpha, pixel_x, pixel_y, plane, layer)
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
	var/list/real_overlays = list()

/datum/element/split_visibility/proc/apply_splitvis_objs(turf/target_turf, icon_path, new_junction, add_to_turfs = TRUE)
	var/static/frilled_dirs = (NORTH)

	var/junction = new_junction
	if(isnull(junction))
		junction = target_turf.smoothing_junction

	// Debug stuff begin
	var/icon_state_key = ""
	// Debug stuff end

	for(var/direction in GLOB.cardinals)
		// If we're connected in this direction, please don't draw a wall side
		if((junction & direction) == direction)
			continue

		var/active_plane = WALL_PLANE
		var/uses_shadow = FALSE
		if(direction & frilled_dirs)
			active_plane = FRILL_PLANE
			uses_shadow = TRUE

		var/atom/movable/visual/split_vis/vis = get_splitvis_object(icon_path, junction, direction, uses_shadow, 255, -DIR_TO_PIXEL_X(direction), -DIR_TO_PIXEL_Y(direction), active_plane)

		var/turf/operating_turf = get_step(target_turf, direction)
		// Right up against an edge of the map eh?
		if(!operating_turf)
			continue

		if(add_to_turfs)
			var/junc = junction ? junction : "0"
			icon_state_key += "([direction]-[junc])"
			target_turf.real_overlays += vis
			operating_turf.overlays += vis
		else
			target_turf.real_overlays -= vis
			operating_turf.overlays -= vis

	for(var/direction in GLOB.diagonals)
		// If we're not connected in this direction, don't draw a joiner
		if((junction & direction) != direction)
			continue

		var/atom/movable/visual/split_vis/vis = get_splitvis_object(icon_path, junction, direction, FALSE, 255, -DIR_TO_PIXEL_X(direction), -DIR_TO_PIXEL_Y(direction), layer = WALL_OBJ_LAYER)

		var/turf/operating_turf = get_step(target_turf, direction)
		// Right up against an edge of the map eh?
		if(!operating_turf)
			continue

		if(add_to_turfs)
			var/junc = junction ? junction : "0"
			icon_state_key += "([direction]-[junc])"
			target_turf.real_overlays += vis
			operating_turf.overlays += vis
		else
			target_turf.real_overlays -= vis
			operating_turf.overlays -= vis

	target_turf.icon_state_key = icon_state_key

/datum/element/split_visibility/Detach(turf/target)
	remove_split_vis_objects(target, icon_path)
	UnregisterSignal(target, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE)
	return ..()


/datum/element/split_visibility/proc/on_junction_change(atom/source, new_junction)
	SIGNAL_HANDLER
	var/turf/turf_or_movable = source
	remove_split_vis_objects(turf_or_movable, icon_path)
	add_split_vis_objects(turf_or_movable, icon_path, new_junction)


/atom/movable/visual/split_vis
	appearance_flags = TILE_BOUND
	layer = ABOVE_MOB_LAYER
	plane = WALL_PLANE

/atom/movable/visual/split_vis/Initialize(mapload, icon, junction, dir, shadow, custom_alpha, custom_pixel_x, custom_pixel_y, custom_plane, custom_layer)
	. = ..()
	src.icon = icon
	var/junc = junction ? junction : "0"
	icon_state = "[dir]-[junc]"
	if(shadow)
		overlays += get_splitvis_object(icon, junction, dir, FALSE, 120, pixel_x = 0, pixel_y = 0, plane = UNDER_FRILL_PLANE)
	if(!isnull(custom_alpha))
		alpha = custom_alpha
	if(!isnull(custom_pixel_x))
		pixel_x = custom_pixel_x
	if(!isnull(custom_pixel_y))
		pixel_y = custom_pixel_y
	if(!isnull(custom_plane))
		plane = custom_plane
	if(!isnull(custom_layer))
		layer = custom_layer
