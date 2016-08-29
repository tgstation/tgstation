/area/ai_monitoblue
	name = "AI Monitoblue Area"
	var/obj/machinery/camera/motioncamera = null


/area/ai_monitoblue/New()
	..()
	// locate and store the motioncamera
	spawn (20) // spawn on a delay to let turfs/objs load
		for (var/obj/machinery/camera/M in src)
			if(M.isMotion())
				motioncamera = M
				M.area_motion = src

/area/ai_monitoblue/Entered(atom/movable/O)
	..()
	if (ismob(O) && motioncamera)
		motioncamera.newTarget(O)

/area/ai_monitoblue/Exited(atom/movable/O)
	if (ismob(O) && motioncamera)
		motioncamera.lostTarget(O)


