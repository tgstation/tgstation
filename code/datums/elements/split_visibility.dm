GLOBAL_LIST_EMPTY(split_visibility_objects)

/proc/get_splitvis_object(icon_path, junction, dir, shadow = FALSE, alpha = 255, pixel_x = 0, pixel_y = 0, plane = WALL_PLANE, layer = ABOVE_MOB_LAYER)
	. = GLOB.split_visibility_objects["[icon_path]-[junction]-[dir]-[shadow]-[alpha]-[pixel_x]-[pixel_y]-[plane]-[layer]"]
	if(.)
		return
	. = GLOB.split_visibility_objects["[icon_path]-[junction]-[dir]-[shadow]-[alpha]-[pixel_x]-[pixel_y]-[plane]-[layer]"] = new /atom/movable/visual/split_vis(null, icon_path, junction, dir, shadow, alpha, pixel_x, pixel_y, plane, layer)

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

	src.icon_path = icon_path

	add_split_vis_objects(target_turf, icon_path)
	RegisterSignal(target, COMSIG_ATOM_SET_SMOOTHED_ICON_STATE, .proc/on_junction_change)

/datum/element/split_visibility/proc/add_split_vis_objects(turf/target_turf, icon_path, new_junction)
	//There's no doubt a cleaner way of doing this but I'm too stupid to figure it out and eh

	var/junction = new_junction ? new_junction : target_turf.smoothing_junction

	var/turf/operating_turf
	//north
	operating_turf = get_step(target_turf, NORTH)
	if(!istype(operating_turf, target_turf.type))
		operating_turf.vis_contents += get_splitvis_object(icon_path, junction, NORTH, TRUE, pixel_y = -32, plane = FRILL_PLANE)
	//south
	operating_turf = get_step(target_turf, SOUTH)
	if(!istype(operating_turf, target_turf.type))
		operating_turf.vis_contents += get_splitvis_object(icon_path, junction, SOUTH, FALSE, pixel_y = 32)
	//east
	operating_turf = get_step(target_turf, EAST)
	if(!istype(operating_turf, target_turf.type))
		operating_turf.vis_contents += get_splitvis_object(icon_path, junction, EAST, FALSE, pixel_x = -32)
	//west
	operating_turf = get_step(target_turf, WEST)
	if(!istype(operating_turf, target_turf.type))
		operating_turf.vis_contents += get_splitvis_object(icon_path, junction, WEST, FALSE, pixel_x = 32)

	if((junction & NORTH) && (junction & EAST))
		operating_turf = get_step(target_turf, NORTHEAST)
		operating_turf.vis_contents += get_splitvis_object(icon_path, junction, NORTHEAST, FALSE, pixel_x = -32, pixel_y = -32)

	if((junction & NORTH) && (junction & WEST))
		operating_turf = get_step(target_turf, NORTHWEST)
		operating_turf.vis_contents += get_splitvis_object(icon_path, junction, NORTHWEST, FALSE, pixel_x = 32, pixel_y = -32)

	if((junction & SOUTH) && (junction & EAST))
		operating_turf = get_step(target_turf, SOUTHEAST)
		operating_turf.vis_contents += get_splitvis_object(icon_path, junction, SOUTHEAST, FALSE, pixel_x = -32, pixel_y = 32)

	if((junction & SOUTH) && (junction & WEST))
		operating_turf = get_step(target_turf, SOUTHWEST)
		operating_turf.vis_contents += get_splitvis_object(icon_path, junction, SOUTHWEST, SOUTHWEST, pixel_x = 32, pixel_y = 32)

/datum/element/split_visibility/proc/remove_split_vis_objects(turf/target_turf, icon_path, new_junction)
	var/junction = new_junction ? new_junction : target_turf.smoothing_junction

	var/turf/operating_turf
	//north
	operating_turf = get_step(target_turf, NORTH)
	operating_turf.vis_contents -= get_splitvis_object(icon_path, junction, NORTH, TRUE, pixel_y = -32, plane = FRILL_PLANE)
	//south
	operating_turf = get_step(target_turf, SOUTH)
	operating_turf.vis_contents -= get_splitvis_object(icon_path, junction, SOUTH, FALSE, pixel_y = 32)
	//east
	operating_turf = get_step(target_turf, EAST)
	operating_turf.vis_contents -= get_splitvis_object(icon_path, junction, EAST, FALSE, pixel_x = -32)
	//west
	operating_turf = get_step(target_turf, WEST)
	operating_turf.vis_contents -= get_splitvis_object(icon_path, junction, WEST, FALSE, pixel_x = 32)

	if(junction & (NORTH | EAST))
		operating_turf = get_step(target_turf, NORTHEAST)
		operating_turf.vis_contents -= get_splitvis_object(icon_path, junction, NORTH, FALSE, pixel_x = -32, pixel_y = -32, layer = WALL_OBJ_LAYER)

	if(junction & (NORTH | WEST))
		operating_turf = get_step(target_turf, NORTHWEST)
		operating_turf.vis_contents -= get_splitvis_object(icon_path, junction, NORTH, FALSE, pixel_x = 32, pixel_y = -32, layer = WALL_OBJ_LAYER)

	if(junction & (SOUTH | EAST))
		operating_turf = get_step(target_turf, SOUTHEAST)
		operating_turf.vis_contents -= get_splitvis_object(icon_path, junction, SOUTH, FALSE, pixel_x = -32, pixel_y = 32, layer = WALL_OBJ_LAYER)

	if(junction & (SOUTH | WEST))
		operating_turf = get_step(target_turf, SOUTHWEST)
		operating_turf.vis_contents -= get_splitvis_object(icon_path, junction, SOUTH, FALSE, pixel_x = 32, pixel_y = 32, layer = WALL_OBJ_LAYER)

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
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = TILE_BOUND
	layer = ABOVE_MOB_LAYER
	plane = WALL_PLANE
	vis_flags = NONE


/atom/movable/visual/split_vis/Initialize(mapload, icon, junction, dir, shadow, custom_alpha, custom_pixel_x, custom_pixel_y, custom_plane, custom_layer)
	. = ..()
	src.icon = icon
	var/junc = junction ? junction : "0"
	icon_state = "[dir]-[junc]"
	if(shadow)
		vis_contents += get_splitvis_object(icon, junction, dir, FALSE, 120, pixel_x = 0, pixel_y = 0, plane = UNDER_FRILL_PLANE)
	if(!isnull(custom_alpha))
		alpha = custom_alpha
	if(!isnull(custom_pixel_x))
		pixel_x = custom_pixel_x l
	if(!isnull(custom_pixel_y))
		pixel_y = custom_pixel_y
	if(!isnull(custom_plane))
		plane = custom_plane
	if(!isnull(custom_layer))
		layer = custom_layer
