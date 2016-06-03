//use this define to highlight docking port bounding boxes (ONLY FOR DEBUG USE)
// #define DOCKING_PORT_HIGHLIGHT

//NORTH default dir
/obj/docking_port
	invisibility = INVISIBILITY_ABSTRACT
	icon = 'icons/obj/device.dmi'
	//icon = 'icons/dirsquare.dmi'
	icon_state = "pinonfar"

	unacidable = 1
	anchored = 1

	var/id
	dir = NORTH		//this should point -away- from the dockingport door, ie towards the ship
	var/width = 0	//size of covered area, perpendicular to dir
	var/height = 0	//size of covered area, paralell to dir
	var/dwidth = 0	//position relative to covered area, perpendicular to dir
	var/dheight = 0	//position relative to covered area, parallel to dir

	//these objects are indestructable
/obj/docking_port/Destroy(force)
	// unless you assert that you know what you're doing. Horrible things
	// may result.
	if(force)
		..()
		. = QDEL_HINT_HARDDEL_NOW
	else
		return QDEL_HINT_LETMELIVE

/obj/docking_port/singularity_pull()
	return
/obj/docking_port/singularity_act()
	return 0
/obj/docking_port/shuttleRotate()
	return //we don't rotate with shuttles via this code.
//returns a list(x0,y0, x1,y1) where points 0 and 1 are bounding corners of the projected rectangle
/obj/docking_port/proc/return_coords(_x, _y, _dir)
	if(!_dir)
		_dir = dir
	if(!_x)
		_x = x
	if(!_y)
		_y = y

	//byond's sin and cos functions are inaccurate. This is faster and perfectly accurate
	var/cos = 1
	var/sin = 0
	switch(_dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1

	return list(
		_x + (-dwidth*cos) - (-dheight*sin),
		_y + (-dwidth*sin) + (-dheight*cos),
		_x + (-dwidth+width-1)*cos - (-dheight+height-1)*sin,
		_y + (-dwidth+width-1)*sin + (-dheight+height-1)*cos
		)


//returns turfs within our projected rectangle in a specific order.
//this ensures that turfs are copied over in the same order, regardless of any rotation
/obj/docking_port/proc/return_ordered_turfs(_x, _y, _z, _dir, area/A)
	if(!_dir)
		_dir = dir
	if(!_x)
		_x = x
	if(!_y)
		_y = y
	if(!_z)
		_z = z
	var/cos = 1
	var/sin = 0
	switch(_dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1

	. = list()

	var/xi
	var/yi
	for(var/dx=0, dx<width, ++dx)
		for(var/dy=0, dy<height, ++dy)
			xi = _x + (dx-dwidth)*cos - (dy-dheight)*sin
			yi = _y + (dy-dheight)*cos + (dx-dwidth)*sin
			var/turf/T = locate(xi, yi, _z)
			if(A)
				if(get_area(T) == A)
					. += T
				else
					. += null
			else
				. += T

#ifdef DOCKING_PORT_HIGHLIGHT
//Debug proc used to highlight bounding area
/obj/docking_port/proc/highlight(_color)
	var/list/L = return_coords()
	var/turf/T0 = locate(L[1],L[2],z)
	var/turf/T1 = locate(L[3],L[4],z)
	for(var/turf/T in block(T0,T1))
		T.color = _color
		T.maptext = null
	if(_color)
		var/turf/T = locate(L[1], L[2], z)
		T.color = "#0f0"
		T = locate(L[3], L[4], z)
		T.color = "#00f"
#endif

//return first-found touching dockingport
/obj/docking_port/proc/get_docked()
	return locate(/obj/docking_port/stationary) in loc

/obj/docking_port/proc/getDockedId()
	var/obj/docking_port/P = get_docked()
	if(P) return P.id

/obj/docking_port/stationary
	name = "dock"

	var/turf_type = /turf/open/space
	var/area_type = /area/space

/obj/docking_port/stationary/New()
	..()
	SSshuttle.stationary += src
	if(!id)
		id = "[SSshuttle.stationary.len]"
	if(name == "dock")
		name = "dock[SSshuttle.stationary.len]"

	#ifdef DOCKING_PORT_HIGHLIGHT
	highlight("#f00")
	#endif

//returns first-found touching shuttleport
/obj/docking_port/stationary/get_docked()
	. = locate(/obj/docking_port/mobile) in loc
	/*
	for(var/turf/T in return_ordered_turfs())
		. = locate(/obj/docking_port/mobile) in loc
		if(.)
			return .
	*/

/obj/docking_port/stationary/transit
	name = "In Transit"
	turf_type = /turf/open/space/transit

/obj/docking_port/stationary/transit/New()
	..()
	SSshuttle.transit += src


/obj/docking_port/mobile
	icon_state = "mobile"
	name = "shuttle"
	icon_state = "pinonclose"

	var/area/shuttle/areaInstance

	var/timer						//used as a timer (if you want time left to complete move, use timeLeft proc)
	var/mode = SHUTTLE_IDLE			//current shuttle mode (see /__DEFINES/stat.dm)
	var/callTime = 50				//time spent in transit (deciseconds)
	var/roundstart_move				//id of port to send shuttle to at roundstart
	var/travelDir = 0				//direction the shuttle would travel in

	var/obj/docking_port/stationary/destination
	var/obj/docking_port/stationary/previous

	var/launch_status = NOLAUNCH

	// A timid shuttle will not register itself with the shuttle subsystem
	// All shuttle templates are timid
	var/timid = FALSE

/obj/docking_port/mobile/New()
	..()
	if(!timid)
		register()

/obj/docking_port/mobile/proc/register()
	SSshuttle.mobile += src

/obj/docking_port/mobile/Destroy(force)
	if(force)
		SSshuttle.mobile -= src
	. = ..()

/obj/docking_port/mobile/initialize()
	var/area/A = get_area(src)
	if(istype(A, /area/shuttle))
		areaInstance = A

	if(!id)
		id = "[SSshuttle.mobile.len]"
	if(name == "shuttle")
		name = "shuttle[SSshuttle.mobile.len]"

	if(!areaInstance)
		areaInstance = new()
		areaInstance.name = name
		areaInstance.contents += return_ordered_turfs()

	#ifdef DOCKING_PORT_HIGHLIGHT
	highlight("#0f0")
	#endif

//this is a hook for custom behaviour. Maybe at some point we could add checks to see if engines are intact
/obj/docking_port/mobile/proc/canMove()
	return 0	//0 means we can move

//this is to check if this shuttle can physically dock at dock S
/obj/docking_port/mobile/proc/canDock(obj/docking_port/stationary/S)
	if(!istype(S))
		return SHUTTLE_NOT_A_DOCKING_PORT

	if(istype(S, /obj/docking_port/stationary/transit))
		return FALSE

	if(dwidth > S.dwidth)
		return SHUTTLE_DWIDTH_TOO_LARGE

	if(width-dwidth > S.width-S.dwidth)
		return SHUTTLE_WIDTH_TOO_LARGE

	if(dheight > S.dheight)
		return SHUTTLE_DHEIGHT_TOO_LARGE

	if(height-dheight > S.height-S.dheight)
		return SHUTTLE_HEIGHT_TOO_LARGE

	//check the dock isn't occupied
	var/currently_docked = S.get_docked()
	if(currently_docked)
		// by someone other than us
		if(currently_docked != src)
			return SHUTTLE_SOMEONE_ELSE_DOCKED
		else
		// This isn't an error, per se, but we can't let the shuttle code
		// attempt to move us where we currently are, it will get weird.
			return SHUTTLE_ALREADY_DOCKED

	return FALSE

//call the shuttle to destination S
/obj/docking_port/mobile/proc/request(obj/docking_port/stationary/S)
	var/status = canDock(S)
	if(status == SHUTTLE_ALREADY_DOCKED)
		// We're already docked there, don't need to do anything.
		// Triggering shuttle movement code in place is weird
		return
	else if(status)
		var/msg = "request(): shuttle [src] cannot dock at [S], \
			error: [status]"
		message_admins(msg)
		throw EXCEPTION(msg)

	switch(mode)
		if(SHUTTLE_CALL)
			if(S == destination)
				if(world.time <= timer)
					timer = world.time
			else
				destination = S
				timer = world.time
		if(SHUTTLE_RECALL)
			if(S == destination)
				timer = world.time - timeLeft(1)
			else
				destination = S
				timer = world.time
			mode = SHUTTLE_CALL
		else
			destination = S
			mode = SHUTTLE_CALL
			timer = world.time
			enterTransit()		//hyperspace

//recall the shuttle to where it was previously
/obj/docking_port/mobile/proc/cancel()
	if(mode != SHUTTLE_CALL)
		return

	timer = world.time - timeLeft(1)
	mode = SHUTTLE_RECALL

/obj/docking_port/mobile/proc/enterTransit()
	previous = null
//		if(!destination)
//			return
	var/obj/docking_port/stationary/S0 = get_docked()
	var/obj/docking_port/stationary/S1 = findTransitDock()
	if(S1)
		if(dock(S1))
			WARNING("shuttle \"[id]\" could not enter transit space. Docked at [S0 ? S0.id : "null"]. Transit dock [S1 ? S1.id : "null"].")
		else
			previous = S0
	else
		WARNING("shuttle \"[id]\" could not enter transit space. S0=[S0 ? S0.id : "null"] S1=[S1 ? S1.id : "null"]")

//default shuttleRotate
/atom/proc/shuttleRotate(rotation)
	//rotate our direction
	dir = angle2dir(rotation+dir2angle(dir))

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

/obj/docking_port/mobile/proc/jumpToNullSpace()
	// Destroys the docking port and the shuttle contents.
	// Not in a fancy way, it just ceases.
	var/obj/docking_port/stationary/S0 = get_docked()
	var/turf_type = /turf/open/space
	var/area_type = /area/space
	// If the shuttle is docked to a stationary port, restore its normal
	// "empty" area and turf
	if(S0)
		if(S0.turf_type)
			turf_type = S0.turf_type
		if(S0.area_type)
			area_type = S0.area_type

	var/list/L0 = return_ordered_turfs(x, y, z, dir, areaInstance)

	//remove area surrounding docking port
	if(areaInstance.contents.len)
		var/area/A0 = locate("[area_type]")
		if(!A0)
			A0 = new area_type(null)
		for(var/turf/T0 in L0)
			A0.contents += T0

	for(var/i in L0)
		var/turf/T0 =i
		if(!T0)
			continue
		T0.empty(turf_type)

	qdel(src, force=TRUE)

//this is the main proc. It instantly moves our mobile port to stationary port S1
//it handles all the generic behaviour, such as sanity checks, closing doors on the shuttle, stunning mobs, etc
/obj/docking_port/mobile/proc/dock(obj/docking_port/stationary/S1, force=FALSE)
	// Crashing this ship with NO SURVIVORS
	if(!force)
		var/status = canDock(S1)
		if(status == SHUTTLE_ALREADY_DOCKED)
			return status
		else if(status)
			spawn(0)
				var/msg = "dock(): shuttle [src] cannot dock at [S1], \
					error: [status]"
				message_admins(msg)
				throw EXCEPTION(msg)
			return status

		if(canMove())
			return -1

	closePortDoors()

//		//rotate transit docking ports, so we don't need zillions of variants
//		if(istype(S1, /obj/docking_port/stationary/transit))
//			S1.dir = turn(NORTH, -travelDir)

	var/obj/docking_port/stationary/S0 = get_docked()
	var/turf_type = /turf/open/space
	var/area_type = /area/space
	if(S0)
		if(S0.turf_type)
			turf_type = S0.turf_type
		if(S0.area_type)
			area_type = S0.area_type

	var/list/L0 = return_ordered_turfs(x, y, z, dir, areaInstance)
	var/list/L1 = return_ordered_turfs(S1.x, S1.y, S1.z, S1.dir)

	var/rotation = dir2angle(S1.dir)-dir2angle(dir)
	if ((rotation % 90) != 0)
		rotation += (rotation % 90) //diagonal rotations not allowed, round up
	rotation = SimplifyDegrees(rotation)

	//remove area surrounding docking port
	if(areaInstance.contents.len)
		var/area/A0 = locate("[area_type]")
		if(!A0)
			A0 = new area_type(null)
		for(var/turf/T0 in L0)
			A0.contents += T0

	//move or squish anything in the way ship at destination
	roadkill(L1, S1.dir)

	for(var/i=1, i<=L0.len, ++i)
		var/turf/T0 = L0[i]
		if(!T0)
			continue
		var/turf/T1 = L1[i]
		if(!T1)
			continue
		if(T0.type != T0.baseturf) //So if there is a hole in the shuttle we don't drag along the space/asteroid/etc to wherever we are going next
			T0.copyTurf(T1)
			areaInstance.contents += T1

			//copy over air
			if(istype(T1, /turf/open))
				var/turf/open/Ts1 = T1
				Ts1.copy_air_with_tile(T0)

			//move mobile to new location
			for(var/atom/movable/AM in T0)
				AM.onShuttleMove(T1, rotation)

		if(rotation)
			T1.shuttleRotate(rotation)

		//lighting stuff
		T1.redraw_lighting()
		SSair.remove_from_active(T1)
		T1.CalculateAdjacentTurfs()
		SSair.add_to_active(T1,1)

		T0.ChangeTurf(turf_type)

		T0.redraw_lighting()
		SSair.remove_from_active(T0)
		T0.CalculateAdjacentTurfs()
		SSair.add_to_active(T0,1)

	loc = S1.loc
	dir = S1.dir

/atom/movable/proc/onShuttleMove(turf/T1, rotation)
	if(rotation)
		shuttleRotate(rotation)
	loc = T1
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
	spawn(0)
		close()

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

/*
	if(istype(S1, /obj/docking_port/stationary/transit))
		var/d = turn(dir, 180 + travelDir)
		for(var/turf/open/space/transit/T in S1.return_ordered_turfs())
			T.pushdirection = d
			T.update_icon()
*/



/obj/docking_port/mobile/proc/findTransitDock()
	var/obj/docking_port/stationary/transit/T = SSshuttle.getDock("[id]_transit")
	if(T && !canDock(T))
		return T

/obj/docking_port/mobile/proc/findRoundstartDock()
	var/obj/docking_port/stationary/D
	D = SSshuttle.getDock(roundstart_move)

	if(D)
		return D

/obj/docking_port/mobile/proc/dockRoundstart()
	// Instead of spending a lot of time trying to work out where to place
	// our shuttle, just create it somewhere empty and send it to where
	// it should go
	var/obj/docking_port/stationary/D = findRoundstartDock()
	return dock(D)

/obj/effect/landmark/shuttle_import
	name = "Shuttle Import"

/*	commented out due to issues with rotation
	for(var/obj/docking_port/stationary/transit/S in SSshuttle.transit)
		if(S.id)
			continue
		if(!canDock(S))
			return S
*/


//shuttle-door closing is handled in the dock() proc whilst looping through turfs
//this one closes the door where we are docked at, if there is one there.
/obj/docking_port/mobile/proc/closePortDoors()
	var/turf/T = get_step(loc, turn(dir,180))
	if(T)
		var/obj/machinery/door/Door = locate() in T
		if(Door)
			spawn(0)
				Door.close()

/obj/docking_port/mobile/proc/roadkill(list/L, dir, x, y)
	var/list/hurt_mobs = list()
	for(var/turf/T in L)
		for(var/atom/movable/AM in T)
			if(isliving(AM) && (!(AM in hurt_mobs)))
				hurt_mobs |= AM
				var/mob/living/M = AM
				if(M.buckled)
					M.buckled.unbuckle_mob(M, 1)
				if(M.pulledby)
					M.pulledby.stop_pulling()
				M.stop_pulling()
				M.visible_message("<span class='warning'>[M] is hit by \
						a bluespace ripple[M.anchored ? "":" and is thrown clear"]!</span>",
						"<span class='userdanger'>You feel an immense \
						crushing pressure as the space around you ripples.</span>")
				if(M.anchored)
					M.gib()
				else
					M.Paralyse(10)
					M.ex_act(2)
					step(M, dir)
				continue

			if(!AM.anchored)
				step(AM, dir)
			else
				qdel(AM)
/*
//used to check if atom/A is within the shuttle's bounding box
/obj/docking_port/mobile/proc/onShuttleCheck(atom/A)
	var/turf/T = get_turf(A)
	if(!T)
		return 0

	var/list/L = return_coords()
	if(L[1] > L[3])
		L.Swap(1,3)
	if(L[2] > L[4])
		L.Swap(2,4)

	if(L[1] <= T.x && T.x <= L[3])
		if(L[2] <= T.y && T.y <= L[4])
			return 1
	return 0
*/
//used by shuttle subsystem to check timers
/obj/docking_port/mobile/proc/check()
	var/timeLeft = timeLeft(1)
	if(timeLeft <= 0)
		switch(mode)
			if(SHUTTLE_CALL)
				if(dock(destination))
					setTimer(20)	//can't dock for some reason, try again in 2 seconds
					return
			if(SHUTTLE_RECALL)
				if(dock(previous))
					setTimer(20)	//can't dock for some reason, try again in 2 seconds
					return
		mode = SHUTTLE_IDLE
		timer = 0
		destination = null


/obj/docking_port/mobile/proc/setTimer(wait)
	if(timer <= 0)
		timer = world.time
	timer += wait - timeLeft(1)

//returns timeLeft
/obj/docking_port/mobile/proc/timeLeft(divisor)
	if(divisor <= 0)
		divisor = 10
	if(!timer)
		return round(callTime/divisor, 1)
	return max( round((timer+callTime-world.time)/divisor,1), 0 )

// returns 3-letter mode string, used by status screens and mob status panel
/obj/docking_port/mobile/proc/getModeStr()
	switch(mode)
		if(SHUTTLE_RECALL)
			return "RCL"
		if(SHUTTLE_CALL)
			return "ETA"
		if(SHUTTLE_DOCKED)
			return "ETD"
		if(SHUTTLE_ESCAPE)
			return "ESC"
		if(SHUTTLE_STRANDED)
			return "ERR"
	return ""

// returns 5-letter timer string, used by status screens and mob status panel
/obj/docking_port/mobile/proc/getTimerStr()
	if(mode == SHUTTLE_STRANDED)
		return "--:--"

	var/timeleft = timeLeft()
	if(timeleft > 0)
		return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"
	else
		return "00:00"


/obj/docking_port/mobile/proc/getStatusText()
	var/obj/docking_port/stationary/dockedAt = get_docked()
	. = (dockedAt && dockedAt.name) ? dockedAt.name : "unknown"
	if(istype(dockedAt, /obj/docking_port/stationary/transit))
		var/obj/docking_port/stationary/dst
		if(mode == SHUTTLE_RECALL)
			dst = previous
		else
			dst = destination
		. += " towards [dst ? dst.name : "unknown location"] ([timeLeft(600)] minutes)"
#undef DOCKING_PORT_HIGHLIGHT


/turf/proc/copyTurf(turf/T)
	if(T.type != type)
		var/obj/O
		if(underlays.len)	//we have underlays, which implies some sort of transparency, so we want to a snapshot of the previous turf as an underlay
			O = new()
			O.underlays.Add(T)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = O.underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(T.color != color)
		T.color = color
	if(T.dir != dir)
		T.dir = dir
	return T
