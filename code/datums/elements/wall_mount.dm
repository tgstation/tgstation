/datum/element/wall_mount

/datum/element/wall_mount/Attach(datum/target)
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	. = ..()
	var/atom/movable/real_target = target
	real_target.plane = OVER_FRILL_PLANE
	//var/turf/target_to_listen_to
	switch(real_target.dir)
		if(NORTH)
			real_target.pixel_y = -8
		if(SOUTH)
			real_target.pixel_y = 35
		if(EAST)
			real_target.pixel_x = -11
			real_target.pixel_y = 16
		if(WEST)
			real_target.pixel_x = 11
			real_target.pixel_y = 16

	//target.RegisterSignal(target_to_listen_to, COMSIG_TURF_CHANGE, )
