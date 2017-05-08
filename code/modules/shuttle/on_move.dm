// Called before shuttle starts moving atoms.
/atom/movable/proc/beforeShuttleMove(turf/T1, rotation)
	return

// Called when shuttle attempts to move an atom.
/atom/movable/proc/onShuttleMove(turf/T1, rotation, knockdown = TRUE)
	if(rotation)
		shuttleRotate(rotation)
	loc = T1
	if (length(client_mobs_in_contents))
		update_parallax_contents()
	return 1

// Called after all of the atoms on shuttle are moved.
/atom/movable/proc/afterShuttleMove()
	return


/obj/onShuttleMove()
	if(invisibility >= INVISIBILITY_ABSTRACT)
		return 0
	. = ..()


/atom/movable/light/onShuttleMove()
	return 0

/obj/machinery/door/airlock/onShuttleMove()
	shuttledocked = 0
	for(var/obj/machinery/door/airlock/A in range(1, src))
		A.shuttledocked = 0
		A.air_tight = TRUE
		INVOKE_ASYNC(A, /obj/machinery/door/.proc/close)
	. = ..()
	shuttledocked =  1
	for(var/obj/machinery/door/airlock/A in range(1, src))
		A.shuttledocked = 1
/mob/onShuttleMove()
	if(!move_on_shuttle)
		return 0
	. = ..()
	if(!.)
		return
	if(client)
		if(buckled)
			shake_camera(src, 2, 1) // turn it down a bit come on
		else
			shake_camera(src, 7, 1)

/mob/living/carbon/onShuttleMove(turf/T1, rotation, knockdown = TRUE)
	. = ..()
	if(!.)
		return
	if(!buckled && knockdown)
		Weaken(3)

/obj/effect/abstract/proximity_checker/onShuttleMove()
	//timer so it only happens once
	addtimer(CALLBACK(monitor, /datum/proximity_monitor/proc/SetRange, monitor.current_range, TRUE), 0, TIMER_UNIQUE)

// Shuttle Rotation //

/atom/proc/shuttleRotate(rotation)
	//rotate our direction
	setDir(angle2dir(rotation+dir2angle(dir)))

	//resmooth if need be.
	if(smooth)
		queue_smooth(src)

	//rotate the pixel offsets too.
	if (pixel_x || pixel_y)
		if (rotation < 0)
			rotation += 360
		for (var/turntimes=rotation/90;turntimes>0;turntimes--)
			var/oldPX = pixel_x
			var/oldPY = pixel_y
			pixel_x = oldPY
			pixel_y = (oldPX*(-1))