/area/station/ai_monitored
	name = "\improper AI Monitored Area"
	sound_environment = SOUND_ENVIRONMENT_ROOM
	var/list/obj/machinery/camera/motioncameras
	var/list/datum/weakref/motionTargets = list()

/area/station/ai_monitored/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	for (var/obj/machinery/camera/ai_camera in src)
		if(!ai_camera.isMotion())
			continue
		LAZYADD(motioncameras, ai_camera)
		ai_camera.set_area_motion(src)

/area/station/ai_monitored/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if (!ismob(arrived) || !LAZYLEN(motioncameras))
		return
	for(var/obj/machinery/camera/cam as anything in motioncameras)
		cam.newTarget(arrived)
		return

/area/station/ai_monitored/Exited(atom/movable/gone, atom/old_loc, list/atom/old_locs)
	. = ..()
	if (!ismob(gone) || !LAZYLEN(motioncameras))
		return
	for(var/obj/machinery/camera/cam as anything in motioncameras)
		cam.lostTargetRef(WEAKREF(gone))
		return
