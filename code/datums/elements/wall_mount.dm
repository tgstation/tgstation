/datum/element/wall_mount

/datum/element/wall_mount/Attach(datum/target)
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	var/atom/movable/real_target = target
	real_target.plane = OVER_FRILL_PLANE
	var/turf/target_to_listen_to
	switch(real_target.dir)
		if(NORTH)
			pixel_y = -8
		if(SOUTH)
			pixel_y = 35
		if(EAST)
			pixel_x = -16
			pixel_y = 16
		if(WEST)
			pixel_x = 16
			pixel_y = 16

	//target.RegisterSignal(target_to_listen_to, COMSIG_TURF_CHANGE, )
