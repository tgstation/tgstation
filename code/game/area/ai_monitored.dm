/area/ai_monitored
	name = "AI Monitored Area"
	var/obj/machinery/camera/motioncamera = null


/area/ai_monitored/New()
	..()
	// locate and store the motioncamera
	spawn (20) // spawn on a delay to let turfs/objs load
		for (var/obj/machinery/camera/motion/M in src)
			motioncamera = M
			return
	return

/area/ai_monitored/Entered(atom/movable/O)
	..()
	if (istype(O, /mob) && motioncamera)
		motioncamera.newTarget(O)

/area/ai_monitored/Exited(atom/movable/O)
	if (istype(O, /mob) && motioncamera)
		motioncamera.lostTarget(O)


