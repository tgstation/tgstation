/datum/element/wall_mount

/datum/element/wall_mount/Attach(datum/target)
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	. = ..()
	var/atom/movable/real_target = target
	RegisterSignal(target, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_changed))
	on_dir_changed(real_target, real_target.dir, real_target.dir)

/datum/element/wall_mount/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, COMSIG_ATOM_DIR_CHANGE)

/datum/element/wall_mount/proc/on_dir_changed(datum/target, olddir, newdir)
	var/atom/movable/real_target = target
	var/new_plane = OVER_FRILL_PLANE
	if(real_target.wall_mount_common_plane(newdir))
		new_plane = initial(real_target.plane)
	SET_PLANE_EXPLICIT(real_target, new_plane, real_target)
	real_target.layer = ON_WALL_LAYER
	real_target.wall_mount_offset(newdir)
	real_target.update_appearance()

/**
 *	Checks object direction and then verifies if there's a wall in that direction. Finally, applies a turf_mounted component to the object.
 *
 * 	@param directional If TRUE, will use the direction of the object to determine the wall to attach to. If FALSE, will use the object's loc.
 *	@param custom_drop_callback If set, will use this callback instead of the default deconstruct callback.
 */
/obj/proc/find_and_hang_on_wall(directional = TRUE, custom_drop_callback)
	AddElement(/datum/element/wall_mount)
	if(istype(get_area(src), /area/shuttle))
		return FALSE //For now, we're going to keep the component off of shuttles to avoid the turf changing issue. We'll hit that later really;
	var/turf/attachable_wall
	if(directional)
		attachable_wall = get_step(src, REVERSE_DIR(dir))
	else
		attachable_wall = loc ///Pull from the curent object loc
	if(!iswallturf(attachable_wall))
		return FALSE//Nothing to latch onto, or not the right thing.
	src.AddComponent(/datum/component/turf_mounted, attachable_wall, custom_drop_callback)
	return TRUE
