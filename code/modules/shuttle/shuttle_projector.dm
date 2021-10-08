/// Projects a shuttle with visual juice while it docks/launches with vis_contents
/obj/effect/abstract/shuttle_projector
	plane = LOWER_SHUTTLE_MOVEMENT_PLANE
	appearance_flags = KEEP_TOGETHER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "transparent"
	anchored = TRUE

	/// The mobile port we're projecting
	var/obj/docking_port/mobile/shuttle_port
	/// The bottom left turf of the bounding box where the shuttle will dock in the stationary port
	var/turf/bottom_left

/obj/effect/abstract/shuttle_projector/Initialize(mapload, obj/docking_port/mobile/shuttle_port, obj/docking_port/stationary/stationary_port, inbound, total_animate_time = null)
	. = ..()

	if (!istype(shuttle_port))
		stack_trace("Invalid shuttle_port for shuttle_projector!")
		return INITIALIZE_HINT_QDEL
	if (!istype(stationary_port))
		stack_trace("Invalid stationary_port for shuttle_projector!")
		return INITIALIZE_HINT_QDEL
	src.shuttle_port = shuttle_port

	// Get the mobile ports turfs to project
	var/list/projected_turfs = shuttle_port.return_ordered_turfs(shuttle_port.x, shuttle_port.y, shuttle_port.z, shuttle_port.dir)

	// If we're projecting on lavaland the shuttle goes above instead of below the game view
	var/turf/open/space/stationary_turf = get_turf(stationary_port)
	var/above_layer = !istype(stationary_turf) || stationary_turf.planetary_atmos

	var/docking_alpha
	var/scale_factor
	var/translate_factor
	if (above_layer)
		scale_factor = 1.6
		translate_factor = scale_factor - 2

		// make it slightly invisible so we don't obstruct the full game view
		docking_alpha = 80
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

	// tearing my hair out over fucking shuttle dirs
	// docking_port/dir is the direction that points AWAY from station doors
	// mobile/preferred_direction is the direction the shuttle moves and is angled in transit space
	// mobile/port_direction is the direction FROM the from front of the shuttle that points towards the station
	// we only care about the two below, these are SANE and are where the FRONT of the shuttle will point
	var/direction_shuttle_will_move = shuttle_port.preferred_direction
	// IMPORTANT TO REMEMBR turn() goes retardedly counter clockwise
	var/direction_shuttle_will_dock = turn(turn(stationary_port.dir, 180), dir2angle(shuttle_port.port_direction))

	var/matrix/move_transform = matrix()
	var/direction_from_dock_to_map_edge_that_we_animate = direction_shuttle_will_move
	if (inbound)
		// invert
		direction_from_dock_to_map_edge_that_we_animate = turn(direction_from_dock_to_map_edge_that_we_animate, 180)

	// move from/to offscreen in the appropriate direction
	// I don't understand shuttle coords, do this the easy way
	var/list/shuttle_coords = shuttle_port.return_coords()
	var/port_width = abs(shuttle_coords[3] - shuttle_coords[1])
	var/port_height = abs(shuttle_coords[4] - shuttle_coords[2])
	switch (direction_from_dock_to_map_edge_that_we_animate)
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

	var/matrix/docked_transform = matrix()
	if (direction_shuttle_will_move != direction_shuttle_will_dock)
		var/a_rotation = dir2angle(direction_shuttle_will_move) - dir2angle(direction_shuttle_will_dock)
		var/b_rotation = dir2angle(direction_shuttle_will_dock) - dir2angle(direction_shuttle_will_move)

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

		// apply the reverse to the docked_transform because the shuttle is already turned while we project it
		docked_transform.Translate(-rotate_width_factor, -rotate_height_factor)
		docked_transform.Turn(-rotate_degrees_actual)
		docked_transform.Translate(rotate_width_factor, rotate_height_factor)

		dock_animation_time += (abs(rotate_degrees_actual) == 180 ? 2 : 1) SECONDS

	// stay centered after scaling/turning
	undock_transform.Translate(port_width * translate_factor, port_height * translate_factor)

	if (!total_animate_time)
		total_animate_time = 10 SECONDS

	var/move_animation_time = total_animate_time - dock_animation_time

	// Get the bottom left turf of the bounding box where the shuttle will dock in the stationary port. Origin point of all transforms
	// Hack hacks hacks! Shuttles are hard okay?
	var/minx = INFINITY
	var/miny = INFINITY
	for (var/I in shuttle_port.ripple_area(stationary_port))
		var/turf/T = I
		minx = min(T.x, minx)
		miny = min(T.y, miny)

	bottom_left = locate(minx, miny, stationary_port.z)

	undock_transform = docked_transform * undock_transform
	var/matrix/combined_transform = undock_transform * move_transform

	if (inbound)
		// make sure we turn correctly while docked
		// start at the end position
		transform = combined_transform
		alpha = 0
	else
		transform = docked_transform

	vis_contents = projected_turfs
	forceMove(bottom_left)

	if (inbound)
		animate(src, transform = undock_transform, easing = CIRCULAR_EASING | EASE_OUT, alpha = docking_alpha, time = move_animation_time)
		animate(transform = docked_transform, alpha = 255, time = dock_animation_time)
	else
		animate(src, transform = undock_transform, alpha = docking_alpha, time = dock_animation_time)
		animate(transform = combined_transform, easing = CIRCULAR_EASING | EASE_IN, alpha = 0, time = move_animation_time)

	if(!inbound)
		// rely on remove_ripples to delete us otherwise
		addtimer(CALLBACK(src, .proc/on_initialization_end), total_animate_time, TIMER_CLIENT_TIME)


/// Handles the aftermath of initializing, after all the deeds are done.
/obj/effect/abstract/shuttle_projector/proc/on_initialization_end()
	qdel(src)
/obj/effect/abstract/shuttle_projector/Destroy(force)
	shuttle_port = null
	return ..()
