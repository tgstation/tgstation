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

/obj/machinery/atmospherics/onShuttleMove()
	. = ..()
	for(DEVICE_TYPE_LOOP)
		if(get_area(nodes[I]) != get_area(src))
			nullifyNode(I)

#define DIR_CHECK_TURF_AREA(X) (get_area(get_ranged_target_turf(src, X, 1)) != A)
/obj/structure/cable/onShuttleMove()
	. = ..()
	var/A = get_area(src)
	//cut cables on the edge
	if(DIR_CHECK_TURF_AREA(NORTH) || DIR_CHECK_TURF_AREA(SOUTH) || DIR_CHECK_TURF_AREA(EAST) || DIR_CHECK_TURF_AREA(WEST))
		cut_cable_from_powernet()
#undef DIR_CHECK_TURF_AREA

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
