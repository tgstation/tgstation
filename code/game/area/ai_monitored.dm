/area/ai_monitored
	name = "\improper AI Monitored Area"
	icon = 'icons/area/areas_station.dmi'
	var/list/obj/machinery/camera/motioncameras = list()
	var/list/datum/weakref/motionTargets = list()
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/ai_monitored/Initialize(mapload)
	. = ..()
	if(mapload)
		for (var/obj/machinery/camera/M in src)
			if(M.isMotion())
				motioncameras.Add(M)
				M.set_area_motion(src)

//Only need to use one camera

/area/ai_monitored/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if (ismob(arrived) && motioncameras.len)
		for(var/X in motioncameras)
			var/obj/machinery/camera/cam = X
			cam.newTarget(arrived)
			return

/area/ai_monitored/Exited(atom/movable/gone, atom/old_loc, list/atom/old_locs)
	..()
	if (ismob(gone) && motioncameras.len)
		for(var/X in motioncameras)
			var/obj/machinery/camera/cam = X
			cam.lostTargetRef(WEAKREF(gone))
			return

/area/ai_monitored/turret_protected/ai/Initialize(mapload)
	. = ..()
	src.area_flags |= ABDUCTOR_PROOF
