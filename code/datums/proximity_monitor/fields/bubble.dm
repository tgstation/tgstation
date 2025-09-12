#define CHANGING_OFFSET "changing_offset"
#define OVERLAY_DATA "overlay_data"
#define STARTING_POSITION "starting_position"
#define ANIMATE_DAMPENER_TIME 1.5 SECONDS

//Only use square radius for this!
/datum/proximity_monitor/advanced/bubble
	edge_is_a_field = TRUE

	///Assoc list of every direction and the image it'll take, so we can form a large radius.
	var/list/effect_direction_images
	///list of all the visual effects we keep track of
	var/list/edgeturf_effects = list()
	///atom that contains all the fields in its vis_contents
	var/atom/movable/field_effect_holder/my_movable

/datum/proximity_monitor/advanced/bubble/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, atom/projector)
	. = ..()
	setup_effect_directions()
	if(_host != projector)
		RegisterSignal(projector, COMSIG_QDELETING, PROC_REF(on_projector_del))
	var/atom/movable/movable_host = _host
	my_movable = new(get_turf(movable_host))
	my_movable.transform = my_movable.transform.Scale(current_range, current_range)
	my_movable.set_glide_size(movable_host.glide_size)
	draw_effect()

/datum/proximity_monitor/advanced/bubble/Destroy()
	for(var/coordinates in edgeturf_effects)
		var/obj/effect/overlay/vis/field/effect_to_remove = edgeturf_effects[coordinates]
		edgeturf_effects -= coordinates
		effect_to_remove.set_wobbly(wobble_duration = ANIMATE_DAMPENER_TIME)
		animate(effect_to_remove, alpha = 0, time = ANIMATE_DAMPENER_TIME, flags = ANIMATION_PARALLEL)
	QDEL_IN(my_movable, ANIMATE_DAMPENER_TIME)
	my_movable = null
	return ..()

/datum/proximity_monitor/advanced/bubble/proc/setup_effect_directions()
	effect_direction_images = list(
		"[SOUTH]" = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_south"),
		"[NORTH]" = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_north"),
		"[WEST]" = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_west"),
		"[EAST]" = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_east"),
		"[NORTHWEST]" = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_northwest"),
		"[SOUTHWEST]" = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_southwest"),
		"[NORTHEAST]" = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_northeast"),
		"[SOUTHEAST]" = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_southeast"),
	)

/datum/proximity_monitor/advanced/bubble/on_moved(atom/movable/source, atom/old_loc)
	. = ..()
	my_movable.forceMove(get_turf(source))

/datum/proximity_monitor/advanced/bubble/on_z_change(datum/source)
	recalculate_field(full_recalc = TRUE)

///rendering all the field visuals. first we render the corners, then we connect them
/datum/proximity_monitor/advanced/bubble/proc/draw_effect()
	var/max_pixel_offset = current_range * ICON_SIZE_ALL
	var/top_right_corner = list(effect_direction_images["[NORTHEAST]"], max_pixel_offset, max_pixel_offset)
	var/top_left_corner = list(effect_direction_images["[NORTHWEST]"], -max_pixel_offset, max_pixel_offset)
	var/bottom_left_corner = list(effect_direction_images["[SOUTHWEST]"], -max_pixel_offset, -max_pixel_offset)
	var/bottom_right_corner = list(effect_direction_images["[SOUTHEAST]"], max_pixel_offset, -max_pixel_offset)

	var/list/corners = list(top_right_corner, top_left_corner, bottom_left_corner, bottom_right_corner)
	for(var/corner in corners)
		draw_corner(corner)

	var/list/corners_to_connect = list(
		list(OVERLAY_DATA = effect_direction_images["[NORTH]"], CHANGING_OFFSET = "x_offset", STARTING_POSITION = max_pixel_offset),
		list(OVERLAY_DATA = effect_direction_images["[SOUTH]"], CHANGING_OFFSET = "x_offset", STARTING_POSITION = -max_pixel_offset),
		list(OVERLAY_DATA = effect_direction_images["[WEST]"], CHANGING_OFFSET = "y_offset", STARTING_POSITION = -max_pixel_offset),
		list(OVERLAY_DATA = effect_direction_images["[EAST]"], CHANGING_OFFSET = "y_offset", STARTING_POSITION = max_pixel_offset),
	)
	for(var/direction in corners_to_connect)
		draw_edge(direction, max_pixel_offset)

///rendering the corners
/datum/proximity_monitor/advanced/bubble/proc/draw_corner(list/corner_data)
	var/obj/effect/overlay/vis/field/corner_effect = new()
	var/image/image_overlay = corner_data[1]
	corner_effect.icon = image_overlay.icon
	corner_effect.icon_state = image_overlay.icon_state
	corner_effect.alpha = 0
	corner_effect.pixel_x = corner_data[2]
	corner_effect.pixel_y = corner_data[3]
	add_effect_to_host(corner_effect)

///connecting the corners to one another
/datum/proximity_monitor/advanced/bubble/proc/draw_edge(list/edge_data, target_offset)
	var/starting_offset = edge_data[STARTING_POSITION]
	var/current_offset = (-1 * target_offset) + ICON_SIZE_ALL
	var/image/overlay = edge_data[OVERLAY_DATA]
	while(current_offset != target_offset)
		var/obj/effect/overlay/vis/field/edge_effect = new()
		edge_effect.alpha = 0
		edge_effect.icon = overlay.icon
		edge_effect.icon_state = overlay.icon_state

		if(edge_data[CHANGING_OFFSET] == "x_offset")
			edge_effect.pixel_y = starting_offset
			edge_effect.pixel_x = current_offset
		else
			edge_effect.pixel_x = starting_offset
			edge_effect.pixel_y = current_offset
		add_effect_to_host(edge_effect)
		current_offset += ICON_SIZE_ALL

///handles adding the visual effect's data
/datum/proximity_monitor/advanced/bubble/proc/add_effect_to_host(obj/effect/overlay/vis/field/effect_to_add)
	my_movable.vis_contents += effect_to_add
	var/coordinate_x = effect_to_add.pixel_x / ICON_SIZE_ALL
	var/coordinate_y = effect_to_add.pixel_y / ICON_SIZE_ALL
	effect_to_add.transform = effect_to_add.transform.Scale(1 / current_range, 1 / current_range)
	edgeturf_effects["[coordinate_x],[coordinate_y]"] = effect_to_add
	effect_to_add.set_wobbly(wobble_duration = ANIMATE_DAMPENER_TIME)
	animate(effect_to_add, alpha = 255, time = ANIMATE_DAMPENER_TIME, flags = ANIMATION_PARALLEL)

/datum/proximity_monitor/advanced/bubble/proc/on_projector_del(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/obj/effect/overlay/vis/field
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	vis_flags = parent_type::vis_flags | VIS_INHERIT_PLANE
	///are we currently WOBBLING
	var/wobbling_effect = FALSE

/obj/effect/overlay/vis/field/proc/set_wobbly(wobble_duration)
	if(wobbling_effect)
		return
	wobbling_effect = TRUE
	apply_wibbly_filters(src)
	addtimer(CALLBACK(src, PROC_REF(remove_wobbly)), wobble_duration)

/obj/effect/overlay/vis/field/proc/remove_wobbly()
	if(QDELETED(src))
		return
	remove_wibbly_filters(src, remove_duration = 0.25 SECONDS)
	addtimer(VARSET_CALLBACK(src, wobbling_effect, FALSE), 0.25 SECONDS)

/atom/movable/field_effect_holder
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = PIXEL_SCALE|LONG_GLIDE
	plane = ABOVE_GAME_PLANE

#undef CHANGING_OFFSET
#undef OVERLAY_DATA
#undef STARTING_POSITION
#undef ANIMATE_DAMPENER_TIME
