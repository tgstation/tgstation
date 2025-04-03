#define CHANGING_OFFSET "changing_offset"
#define OVERLAY_DATA "overlay_data"
#define STARTING_POSITION "starting_position"
#define ANIMATE_DAMPENER_TIME 1.5 SECONDS

//Projectile dampening field that slows projectiles and lowers their damage for an energy cost deducted every 1/5 second.
//Only use square radius for this!
/datum/proximity_monitor/advanced/projectile_dampener
	edge_is_a_field = TRUE
	var/static/list/effect_direction_images = list(
		"[SOUTH]" = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_south"),
		"[NORTH]" = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_north"),
		"[WEST]" =  image('icons/effects/fields.dmi', icon_state = "projectile_dampen_west"),
		"[EAST]" = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_east"),
		"[NORTHWEST]" = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_northwest"),
		"[SOUTHWEST]" = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_southwest"),
		"[NORTHEAST]" = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_northeast"),
		"[SOUTHEAST]" = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_southeast"),
	)
	var/static/image/generic_edge = image('icons/effects/fields.dmi', icon_state = "projectile_dampen_generic")
	///overlay we apply to caught bullets
	var/static/image/new_bullet_overlay= image('icons/effects/fields.dmi', "projectile_dampen_effect")
	///list of all the visual effects we keep track of
	var/list/edgeturf_effects = list()
	///atom that contains all the fields in its vis_contents
	var/atom/movable/field_effect_holder/my_movable
	/// datum that holds the effects we apply on caught bullets
	var/datum/dampener_projectile_effects/bullet_effects

/datum/proximity_monitor/advanced/projectile_dampener/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, atom/projector, datum/dampener_projectile_effects/effects_typepath)
	..()
	RegisterSignal(projector, COMSIG_QDELETING, PROC_REF(on_projector_del))
	var/atom/movable/movable_host = _host
	my_movable = new(get_turf(_host))
	my_movable.transform = my_movable.transform.Scale(current_range, current_range)
	my_movable.set_glide_size(movable_host.glide_size)
	bullet_effects = effects_typepath ? new effects_typepath() : new
	draw_effect()

/datum/proximity_monitor/advanced/projectile_dampener/on_moved(atom/movable/source, atom/old_loc)
	. = ..()
	my_movable.Move(source.loc, get_dir(my_movable.loc, source.loc), source.glide_size)

/datum/proximity_monitor/advanced/projectile_dampener/on_z_change(datum/source)
	recalculate_field(full_recalc = TRUE)

/datum/proximity_monitor/advanced/projectile_dampener/field_edge_crossed(atom/movable/movable, turf/location, turf/old_location)
	. = ..()
	if(!isprojectile(movable))
		return
	determine_wobble(location)

/datum/proximity_monitor/advanced/projectile_dampener/field_edge_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	. = ..()
	if(!isprojectile(movable))
		return
	determine_wobble(old_location)

/datum/proximity_monitor/advanced/projectile_dampener/field_turf_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	if(!isprojectile(movable) || HAS_TRAIT_FROM(movable, TRAIT_GOT_DAMPENED, REF(src)))
		return
	catch_bullet_effect(movable)

/datum/proximity_monitor/advanced/projectile_dampener/field_turf_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	if(!isprojectile(movable) || get_dist(new_location, host) <= current_range)
		return
	release_bullet_effect(movable)

/datum/proximity_monitor/advanced/projectile_dampener/setup_field_turf(turf/target)
	for(var/atom/possible_projectile in target)
		if(isprojectile(possible_projectile))
			catch_bullet_effect(possible_projectile)

/datum/proximity_monitor/advanced/projectile_dampener/cleanup_field_turf(turf/target)
	for(var/atom/possible_projectile in target)
		if(isprojectile(possible_projectile) && HAS_TRAIT_FROM(possible_projectile, TRAIT_GOT_DAMPENED, REF(src)))
			release_bullet_effect(possible_projectile)

///proc that applies the wobbly effect on point of bullet entry
/datum/proximity_monitor/advanced/projectile_dampener/proc/determine_wobble(turf/location)
	var/coord_x = location.x - host.x
	var/coord_y = location.y - host.y
	var/obj/effect/overlay/vis/field/my_field = edgeturf_effects["[coord_x],[coord_y]"]
	my_field?.set_wobbly(0.15 SECONDS)

/datum/proximity_monitor/advanced/projectile_dampener/proc/projectile_overlay_updated(atom/source, list/overlays)
	SIGNAL_HANDLER

	if(!isnull(new_bullet_overlay) && HAS_TRAIT_FROM(source, TRAIT_GOT_DAMPENED, REF(src)))
		overlays += new_bullet_overlay

///a bullet has entered our field, apply the dampening effects to it
/datum/proximity_monitor/advanced/projectile_dampener/proc/catch_bullet_effect(obj/projectile/bullet)
	ADD_TRAIT(bullet,TRAIT_GOT_DAMPENED, REF(src))
	RegisterSignal(bullet, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(projectile_overlay_updated))
	SEND_SIGNAL(src, COMSIG_DAMPENER_CAPTURE, bullet)
	bullet_effects.apply_effects(bullet)
	bullet.update_appearance()

///removing the effects after it has exited our field
/datum/proximity_monitor/advanced/projectile_dampener/proc/release_bullet_effect(obj/projectile/bullet)
	REMOVE_TRAIT(bullet, TRAIT_GOT_DAMPENED, REF(src))
	SEND_SIGNAL(src, COMSIG_DAMPENER_RELEASE, bullet)
	bullet_effects.remove_effects(bullet)
	bullet.update_appearance()
	UnregisterSignal(bullet, COMSIG_ATOM_UPDATE_OVERLAYS)

///rendering all the field visuals. first we render the corners, then we connect them
/datum/proximity_monitor/advanced/projectile_dampener/proc/draw_effect()
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
/datum/proximity_monitor/advanced/projectile_dampener/proc/draw_corner(list/corner_data)
	var/obj/effect/overlay/vis/field/corner_effect = new()
	var/image/image_overlay = corner_data[1]
	corner_effect.icon = image_overlay.icon
	corner_effect.icon_state = image_overlay.icon_state
	corner_effect.alpha = 0
	corner_effect.pixel_x = corner_data[2]
	corner_effect.pixel_y = corner_data[3]
	add_effect_to_host(corner_effect)

///connecting the corners to one another
/datum/proximity_monitor/advanced/projectile_dampener/proc/draw_edge(list/edge_data, target_offset)
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
/datum/proximity_monitor/advanced/projectile_dampener/proc/add_effect_to_host(obj/effect/overlay/vis/field/effect_to_add)
	my_movable.vis_contents += effect_to_add
	var/coordinate_x = effect_to_add.pixel_x / ICON_SIZE_ALL
	var/coordinate_y = effect_to_add.pixel_y / ICON_SIZE_ALL
	effect_to_add.transform = effect_to_add.transform.Scale(1 / current_range, 1 / current_range)
	edgeturf_effects["[coordinate_x],[coordinate_y]"] = effect_to_add
	effect_to_add.set_wobbly(wobble_duration = ANIMATE_DAMPENER_TIME)
	animate(effect_to_add, alpha = 255, time = ANIMATE_DAMPENER_TIME, flags = ANIMATION_PARALLEL)

/datum/proximity_monitor/advanced/projectile_dampener/proc/on_projector_del(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/proximity_monitor/advanced/projectile_dampener/Destroy()
	for(var/coordinates in edgeturf_effects)
		var/obj/effect/overlay/vis/field/effect_to_remove = edgeturf_effects[coordinates]
		edgeturf_effects -= coordinates
		effect_to_remove.set_wobbly(wobble_duration = ANIMATE_DAMPENER_TIME)
		animate(effect_to_remove, alpha = 0, time = ANIMATE_DAMPENER_TIME, flags = ANIMATION_PARALLEL)
	QDEL_IN(my_movable, ANIMATE_DAMPENER_TIME)
	my_movable = null
	bullet_effects = null
	return ..()

/datum/proximity_monitor/advanced/projectile_dampener/peaceborg

/datum/proximity_monitor/advanced/projectile_dampener/peaceborg/field_turf_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	. = ..()
	if(!iscyborg(movable) || !HAS_TRAIT_FROM(movable, TRAIT_GOT_DAMPENED, REF(src)))
		ADD_TRAIT(movable, TRAIT_GOT_DAMPENED, REF(src))

/datum/proximity_monitor/advanced/projectile_dampener/peaceborg/field_turf_uncrossed(atom/movable/movable, turf/old_location, turf/new_location)
	if(!iscyborg(movable) || get_dist(new_location, host) <= current_range)
		return
	REMOVE_TRAIT(movable, TRAIT_GOT_DAMPENED, REF(src))

/datum/proximity_monitor/advanced/projectile_dampener/peaceborg/setup_field_turf(turf/target)
	for(var/atom/interesting_atom as anything in target)
		if(iscyborg(interesting_atom))
			ADD_TRAIT(interesting_atom, TRAIT_GOT_DAMPENED, REF(src))
		if(isprojectile(interesting_atom))
			catch_bullet_effect(interesting_atom)

/datum/proximity_monitor/advanced/projectile_dampener/peaceborg/cleanup_field_turf(turf/target)
	for(var/atom/interesting_atom as anything in target)
		if(iscyborg(interesting_atom))
			REMOVE_TRAIT(interesting_atom, TRAIT_GOT_DAMPENED, REF(src))
		if(isprojectile(interesting_atom))
			release_bullet_effect(interesting_atom)

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
