/area/ai_monitored
	name = "AI Monitored Area"
	var/list/obj/machinery/camera/motioncameras = list()
	var/list/motionTargets = list()

/area/ai_monitored/initialize()
	..()
	for (var/obj/machinery/camera/M in src)
		if(M.isMotion())
			motioncameras.Add(M)
			M.area_motion = src

//Only need to use one camera

/area/ai_monitored/Entered(atom/movable/O)
	..()
	if (ismob(O) && motioncameras.len)
		for(var/X in motioncameras)
			var/obj/machinery/camera/cam = X
			cam.newTarget(O)
			return

/area/ai_monitored/Exited(atom/movable/O)
	..()
	if (ismob(O) && motioncameras.len)
		for(var/X in motioncameras)
			var/obj/machinery/camera/cam = X
			cam.lostTarget(O)
			return