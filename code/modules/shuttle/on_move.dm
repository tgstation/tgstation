/atom/movable/proc/onShuttleMove(turf/T1, rotation)
	if(rotation)
		shuttleRotate(rotation)
	loc = T1
	if (length(client_mobs_in_contents))
		update_parallax_contents()
	return 1

/obj/onShuttleMove()
	if(invisibility >= INVISIBILITY_ABSTRACT)
		return 0
	. = ..()

/atom/movable/light/onShuttleMove()
	return 0

/obj/machinery/door/onShuttleMove()
	. = ..()
	if(!.)
		return
	addtimer(CALLBACK(src, .proc/close), 0, TIMER_UNIQUE)
	// Close any attached airlocks as well
	for(var/obj/machinery/door/D in orange(1, src))
		addtimer(CALLBACK(src, .proc/close), 0, TIMER_UNIQUE)

/obj/machinery/door/airlock/onShuttleMove()
	shuttledocked = 0
	for(var/obj/machinery/door/airlock/A in orange(1, src))
		A.shuttledocked = 0
	. = ..()
	shuttledocked =  1
	for(var/obj/machinery/door/airlock/A in orange(1, src))
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

/mob/living/carbon/onShuttleMove()
	. = ..()
	if(!.)
		return
	if(!buckled)
		Weaken(3)

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
