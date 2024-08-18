/datum/element/wall_mount
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// What layer the object should be on when wall-mounted
	var/wall_layer

/datum/element/wall_mount/Attach(datum/target, wall_layer)
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	. = ..()
	var/atom/movable/real_target = target
	src.wall_layer = wall_layer
	RegisterSignal(target, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_changed))
	on_dir_changed(real_target, null, real_target.dir)

/datum/element/wall_mount/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_DIR_CHANGE)

/datum/element/wall_mount/proc/on_dir_changed(datum/target, olddir, newdir)
	SIGNAL_HANDLER

	if(olddir == newdir)
		return

	var/atom/movable/real_target = target
	var/new_plane = OVER_FRILL_PLANE
	if(real_target.wall_mount_common_plane(newdir))
		new_plane = initial(real_target.plane)
	SET_PLANE_EXPLICIT(real_target, new_plane, real_target)
	real_target.layer = wall_layer || ON_WALL_LAYER
	real_target.wall_mount_offset(newdir)
	real_target.update_appearance()
