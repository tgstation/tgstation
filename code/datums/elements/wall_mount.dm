/datum/element/wall_mount

/datum/element/wall_mount/Attach(datum/target)
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	. = ..()
	var/atom/movable/real_target = target
	//var/turf/target_to_listen_to = get_step(get_turf(real_target), turn(real_target.dir, 180))

	//These magic offsets are chosen for no particular reason
	//The wall mount template is made to work with them
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
	RegisterSignal(target, COMSIG_ATOM_DIR_CHANGE, .proc/on_dir_changed)
	on_dir_changed(real_target, real_target.dir, real_target.dir)

/datum/element/wall_mount/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_DIR_CHANGE)


/datum/element/wall_mount/proc/on_dir_changed(datum/target, olddir, newdir)
	var/atom/movable/real_target = target
	var/new_plane = OVER_FRILL_PLANE
	if(newdir == SOUTH)
		new_plane = WALL_PLANE
	SET_PLANE_EXPLICIT(real_target, new_plane, real_target)

