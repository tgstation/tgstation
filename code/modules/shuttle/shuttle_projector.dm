/// Projects a shuttle while it docks/launches with vis_contents
/obj/shuttle_projector
	layer = SPACE_LAYER

	var/obj/docking_port/stationary/transit_port
	var/turf/bottom_left

/obj/shuttle_projector/Initialize(mapload, obj/docking_port/stationary/transit_port, obj/docking_port/stationary/stationary_port, inbound, total_animate_time = null)
	. = ..()
	if(!istype(transit_port))
		stack_trace("Invalid transit_port for shuttle_projector!")
		return INITIALIZE_HINT_QDEL
	if(!istype(stationary_port))
		stack_trace("Invalid stationary_port for shuttle_projector!")
		return INITIALIZE_HINT_QDEL
	src.transit_port = transit_port

	var/list/all_dest_turfs = transit_port.return_ordered_turfs(transit_port.x, transit_port.y, transit_port.z, transit_port.dir)
	var/list/initial_shuttle_turfs = list()
	for(var/T in all_dest_turfs)
		var/turf/dest_turf = T
		RegisterSignal(dest_turf, COMSIG_TURF_CHANGE, .proc/TurfUpdated)
		if(!istype(dest_turf, /turf/open/space/transit))
			initial_shuttle_turfs += dest_turf
			if(!bottom_left || bottom_left.x >= dest_turf.x || bottom_left.y >= dest_turf.y)
				bottom_left = dest_turf

	var/turf/open/stationary_turf = stationary_port.loc
	var/above_layer = !istype(stationary_turf) || stationary_turf.planetary_atmos
	var/matrix/undock_transform = matrix()
	var/docking_alpha
	if(above_layer)
		undock_transform.Scale(1.6, 1.6)
		docking_alpha = 100
		layer = ABOVE_LIGHTING_LAYER
	else
		undock_transform.Scale(0.4, 0.4)
		docking_alpha = 255

	var/matrix/move_transform = matrix()
	var/launch_dir = transit_port.dir
	if (inbound)
		switch (launch_dir)
			if (WEST)
				launch_dir = EAST
			if (EAST)
				launch_dir = WEST
			if (SOUTH)
				launch_dir = NORTH
			if (NORTH)
				launch_dir = SOUTH

	switch(launch_dir)
		if(WEST)
			move_transform.Translate((-stationary_port.x - stationary_port.dwidth) * 256, 0)
		if(EAST)
			move_transform.Translate((512 - (stationary_port.x + stationary_port.dwidth)) * 256, 0)
		if(SOUTH)
			move_transform.Translate(0, (-stationary_port.y - stationary_port.dheight) * 256)
		if(NORTH)
			move_transform.Translate(0, (512 - (stationary_port.y + stationary_port.dheight)) * 256)

	var/dock_animation_time = 2 SECONDS
	if (launch_dir != stationary_port.dir)
		var/a_rotation = dir2angle(launch_dir) - dir2angle(stationary_port.dir)
		var/b_rotation = dir2angle(stationary_port.dir) - dir2angle(launch_dir)

		var/rotate_degrees = abs(b_rotation) > abs(a_rotation) ? a_rotation : b_rotation
		undock_transform.Turn(rotate_degrees)

		dock_animation_time += (abs(rotate_degrees) == 180 ? 2 : 1) SECONDS

	loc = bottom_left
	vis_contents = initial_shuttle_turfs

	if (!total_animate_time)
		total_animate_time = 10 SECONDS

	var/move_animation_time = total_animate_time - dock_animation_time
	if (inbound)
		transform = move_transform * undock_transform
		move_transform *= -1
		undock_transform *= -1
		alpha = 0
		animate(src, transform = move_transform, easing = CIRCULAR_EASING | EASE_OUT, alpha = docking_alpha, time = move_animation_time)
		animate(transform = undock_transform, alpha = 255, time = dock_animation_time)
	else
		animate(src, transform = undock_transform, alpha = docking_alpha, time = dock_animation_time)
		animate(transform = move_transform, easing = CIRCULAR_EASING | EASE_IN, alpha = 0, time = move_animation_time)

	addtimer(CALLBACK(/proc/qdel, src), total_animate_time, TIMER_CLIENT_TIME)

/obj/shuttle_projector/Destroy(force)
	transit_port = null
	return ..()

/obj/shuttle_projector/proc/TurfUpdated(turf/sender, new_path, ...)
	if (ispath(new_path, /turf/open/space/transit))
		vis_contents -= sender
		if (sender != loc)
			return

		bottom_left = null
		for (var/I in vis_contents)
			var/turf/T = I
			if (!bottom_left || bottom_left.x >= T.x || bottom_left.y >= T.y)
				bottom_left = T

		loc = bottom_left
		return

	if (!istype(src, /turf/open/space))
		return

	vis_contents += sender
	if (bottom_left.x >= sender.x || bottom_left.y >= sender.y)
		bottom_left = sender
		loc = sender
