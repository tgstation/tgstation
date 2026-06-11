/// Area component that makes all movement inside get tracked by motion sensitive cameras
/datum/component/monitored_area
	dupe_mode = COMPONENT_DUPE_UNIQUE // Only one area will ever exist, so only one component will ever exist

	/// This actually handles updating cameras and whatnot.
	var/datum/motion_group/motion_group

/datum/component/monitored_area/Initialize()
	// By the way, this component should be added in LateInitialize().
	if(!isarea(parent))
		return COMPONENT_INCOMPATIBLE
	motion_group = new()

/datum/component/monitored_area/RegisterWithParent()
	RegisterSignal(parent, COMSIG_AREA_ENTERED, PROC_REF(on_entered))
	RegisterSignal(parent, COMSIG_AREA_EXITED, PROC_REF(on_exited))
	// FIXME: cameras will never be updated after registration
	for(var/obj/machinery/camera/camera in parent)
		motion_group.track_camera(camera)

/datum/component/monitored_area/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_AREA_ENTERED, COMSIG_AREA_EXITED))
	for(var/obj/machinery/camera/camera as anything in motion_group.motion_cameras)
		motion_group.untrack_camera(camera)

/datum/component/monitored_area/proc/on_entered(area/_source, atom/movable/gain, area/_old_area)
	SIGNAL_HANDLER
	motion_group.track_mob(gain)

/datum/component/monitored_area/proc/on_exited(area/_source, atom/movable/lost, _direction)
	SIGNAL_HANDLER
	motion_group.untrack_mob(lost)

/// Handler for motion groups. Motion-sensitive cameras can optionally associate with one of these groups.
/// This doesn't do anything by itself. Something needs to drive it (like a [component][/datum/component/monitored_area]).
/datum/motion_group
	/// The cameras in this area that we are tracking. Lazy.
	var/list/obj/machinery/camera/motion_cameras
	/// Our motion targets. This gets referenced by cameras.
	var/list/datum/weakref/motion_targets = list()

/datum/motion_group/proc/track_camera(obj/machinery/camera/gain_camera)
	if(!gain_camera.isMotion())
		return

	RegisterSignal(gain_camera, COMSIG_QDELETING, PROC_REF(untrack_camera))
	gain_camera.set_area_motion(src)
	LAZYOR(motion_cameras, gain_camera)

/datum/motion_group/proc/untrack_camera(obj/machinery/camera/lost_camera)
	SIGNAL_HANDLER

	LAZYREMOVE(motion_cameras, lost_camera)
	UnregisterSignal(lost_camera, COMSIG_QDELETING)
	if(!LAZYLEN(motion_cameras))
		// clear targets if we don't have any cameras so we don't have hanging references
		// (they're weakrefs but still we should be doing this)
		LAZYNULL(motion_targets)

/datum/motion_group/proc/track_mob(mob/gain_mob)
	if(!ismob(gain_mob) || !LAZYLEN(motion_cameras))
		return

	for(var/obj/machinery/camera/camera as anything in motion_cameras)
		camera.new_target(gain_mob)
		return //??

/datum/motion_group/proc/untrack_mob(mob/lost_mob)
	if(!ismob(lost_mob) || !LAZYLEN(motion_cameras))
		return

	for(var/obj/machinery/camera/camera as anything in motion_cameras)
		camera.lost_target(lost_mob)
		return //??
