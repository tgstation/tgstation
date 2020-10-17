/// Projects a shuttle with visual juice while it docks/launches with vis_contents
/obj/shuttle_projector
	layer = SHUTTLE_MOVEMENT_LAYER
	plane = SHUTTLE_MOVEMENT_PLANE
	appearance_flags = KEEP_TOGETHER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = null

	/// The mobile port we're projecting
	var/obj/docking_port/mobile/shuttle_port
	/// The bottom left turf of the bounding box where the shuttle will dock in the stationary port
	var/turf/bottom_left

/obj/shuttle_projector/Initialize(mapload, obj/docking_port/mobile/shuttle_port, obj/docking_port/stationary/stationary_port, inbound, total_animate_time = null)
	. = ..()

	// If we're projecting on lavaland the shuttle goes above instead of below the game view
	var/turf/open/stationary_turf = get_turf(stationary_port)
	var/above_layer = !istype(stationary_turf) || stationary_turf.planetary_atmos
	if(above_layer)
		// doesn't work currently: https://cdn.discordapp.com/attachments/484280891158560778/767044613558370364/zsZapWE9jz.mp4
		// objs on the shuttle don't get projected for some reason and some other overlay (lighting?) goes completely wack
		return INITIALIZE_HINT_QDEL

	if (!istype(shuttle_port))
		stack_trace("Invalid shuttle_port for shuttle_projector!")
		return INITIALIZE_HINT_QDEL
	if (!istype(stationary_port))
		stack_trace("Invalid stationary_port for shuttle_projector!")
		return INITIALIZE_HINT_QDEL
	src.shuttle_port = shuttle_port

	// Get the mobile ports turfs to project
	var/list/all_transit_turfs = shuttle_port.return_ordered_turfs(shuttle_port.x, shuttle_port.y, shuttle_port.z, shuttle_port.dir)

	var/list/initial_shuttle_turfs = list()
	for (var/T in all_transit_turfs)
		var/turf/transit_turf = T
		RegisterSignal(transit_turf, COMSIG_TURF_CHANGE, .proc/TurfUpdated)
		// We don't want to project any empty space turfs
		if(istype(transit_turf.loc, /area/shuttle))
			initial_shuttle_turfs += transit_turf

	var/docking_alpha
	var/scale_factor
	var/translate_factor
	if (above_layer)
		scale_factor = 1.6
		translate_factor = scale_factor - 2

		// make it slightly invisible so we don't obstruct the full game view
		docking_alpha = 100
		layer = ABOVE_LIGHTING_LAYER
		plane = ABOVE_LIGHTING_PLANE
	else
		scale_factor = 0.4
		translate_factor = 1 - scale_factor
		docking_alpha = 255

	// pixel factor, half the width/height of the shuttle
	translate_factor *= TURF_PIXEL_DIAMETER / 2

	// shrink / grow
	var/matrix/undock_transform = matrix()
	undock_transform.Scale(scale_factor, scale_factor)

	var/matrix/move_transform = matrix()
	var/dir_from_dock_to_edge = shuttle_port.preferred_direction
	if (inbound)
		// invert
		switch (dir_from_dock_to_edge)
			if (WEST)
				dir_from_dock_to_edge = EAST
			if (EAST)
				dir_from_dock_to_edge = WEST
			if (SOUTH)
				dir_from_dock_to_edge = NORTH
			if (NORTH)
				dir_from_dock_to_edge = SOUTH

	// move from/to offscreen in the appropriate direction
	// I don't understand shuttle coords, do this the easy way
	var/list/shuttle_coords = shuttle_port.return_coords()
	var/port_width = abs(shuttle_coords[3] - shuttle_coords[1])
	var/port_height = abs(shuttle_coords[4] - shuttle_coords[2])
	switch (dir_from_dock_to_edge)
		if (WEST)
			move_transform.Translate((-stationary_port.x - port_width) * TURF_PIXEL_DIAMETER, 0)
		if (EAST)
			move_transform.Translate((world.maxx - port_height) * TURF_PIXEL_DIAMETER, 0)
		if (SOUTH)
			move_transform.Translate(0, (-stationary_port.y - port_width) * TURF_PIXEL_DIAMETER)
		if (NORTH)
			move_transform.Translate(0, (world.maxy - port_height) * TURF_PIXEL_DIAMETER)

	// rotate to/from the movement direction
	var/dock_animation_time = 1.4 SECONDS
	var/rotate_degrees = 0
	var/rotate_width_factor = port_width * TURF_PIXEL_DIAMETER / 2
	var/rotate_height_factor = port_height * TURF_PIXEL_DIAMETER / 2
	if (shuttle_port.dir != stationary_port.dir)
		var/a_rotation = dir2angle(shuttle_port.dir) - dir2angle(stationary_port.dir)
		var/b_rotation = dir2angle(stationary_port.dir) - dir2angle(shuttle_port.dir)

		rotate_degrees = abs(b_rotation) > abs(a_rotation) ? a_rotation : b_rotation

		var/rotate_degrees_actual = rotate_degrees
		if (abs(rotate_degrees_actual) == 180)
			// BYOND DON'T FLIP SO GOOD
			// I'M SORRY MY FELLOW OCD GAMERS BUT 180 DOES NOT FUCKING WORK
			rotate_degrees_actual /= 180
			move_transform.Turn(rotate_degrees_actual)
			rotate_degrees_actual *= 179

		// little weird but, we need to "center" the vis_contents before rotating so it works properly instead of going around the shuttle_projector obj
		undock_transform.Translate(-rotate_width_factor, -rotate_height_factor)
		undock_transform.Turn(rotate_degrees_actual)
		undock_transform.Translate(rotate_width_factor, rotate_height_factor)

		dock_animation_time += (abs(rotate_degrees_actual) == 180 ? 2 : 1) SECONDS

	// stay centered after scaling/turning
	undock_transform.Translate(port_width * translate_factor, port_height * translate_factor)

	if (!total_animate_time)
		total_animate_time = 10 SECONDS

	var/move_animation_time = total_animate_time - dock_animation_time

	// Get the bottom left turf of the bounding box where the shuttle will dock in the stationary port
	// Hack hacks hacks! Shuttles are hard okay?
	var/minx = INFINITY
	var/miny = INFINITY
	for (var/I in shuttle_port.ripple_area(stationary_port))
		var/turf/T = I
		if(T.x <= minx)
			minx = T.x
		if(T.y <= miny)
			miny = T.y

	bottom_left = locate(minx, miny, stationary_port.z)

	var/matrix/combined_transform = undock_transform * move_transform

	if (inbound)
		// make sure we turn correctly while docked
		// start at the end position
		transform = combined_transform
		alpha = 0

	forceMove(bottom_left)
	vis_contents = initial_shuttle_turfs

	if (inbound)
		animate(src, transform = undock_transform, easing = CIRCULAR_EASING | EASE_OUT, alpha = docking_alpha, time = move_animation_time)
		animate(transform = matrix(), alpha = 255, time = dock_animation_time)
	else
		animate(src, transform = undock_transform, alpha = docking_alpha, time = dock_animation_time)
		animate(transform = combined_transform, easing = CIRCULAR_EASING | EASE_IN, alpha = 0, time = move_animation_time)

	//TODO: Remove
	to_chat(world, "Shuttle projector: [ADMIN_JMP(src)]")

	if(!inbound)
		// rely on remove_ripples to delete us otherwise
		addtimer(CALLBACK(GLOBAL_PROC, /proc/qdel, src), total_animate_time, TIMER_CLIENT_TIME)

/obj/shuttle_projector/Destroy(force)
	shuttle_port = null
	return ..()

/// Adds or removes turfs in vis_contents based on changes in the shuttle
/obj/shuttle_projector/proc/TurfUpdated(turf/sender, new_path, ...)
	// This won't add a turf if someone builds a grill but who cares
	if (istype(sender, /turf/open/space))
		vis_contents -= sender
		return

	vis_contents += sender
