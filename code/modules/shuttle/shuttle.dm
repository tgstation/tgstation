//use this define to highlight docking port bounding boxes (ONLY FOR DEBUG USE)
#ifdef TESTING
#define DOCKING_PORT_HIGHLIGHT
#endif

//NORTH default dir
/obj/docking_port
	invisibility = INVISIBILITY_ABSTRACT
	icon = 'icons/obj/device.dmi'
	//icon = 'icons/dirsquare.dmi'
	icon_state = "pinonfar"

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = 1

	var/id
	// this should point -away- from the dockingport door, ie towards the ship
	dir = NORTH
	var/width = 0	//size of covered area, perpendicular to dir
	var/height = 0	//size of covered area, parallel to dir
	var/dwidth = 0	//position relative to covered area, perpendicular to dir
	var/dheight = 0	//position relative to covered area, parallel to dir

	//these objects are indestructible
/obj/docking_port/Destroy(force)
	// unless you assert that you know what you're doing. Horrible things
	// may result.
	if(force)
		..()
		. = QDEL_HINT_HARDDEL_NOW
	else
		return QDEL_HINT_LETMELIVE

/obj/docking_port/take_damage()
	return

/obj/docking_port/singularity_pull()
	return
/obj/docking_port/singularity_act()
	return 0
/obj/docking_port/shuttleRotate()
	return //we don't rotate with shuttles via this code.

//returns a list(x0,y0, x1,y1) where points 0 and 1 are bounding corners of the projected rectangle
/obj/docking_port/proc/return_coords(_x, _y, _dir)
	if(_dir == null)
		_dir = dir
	if(_x == null)
		_x = x
	if(_y == null)
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
		LAZYINITLIST(T.atom_colours)
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
	var/last_dock_time

/obj/docking_port/stationary/Initialize()
	. = ..()
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

/obj/docking_port/stationary/transit
	name = "In Transit"
	turf_type = /turf/open/space/transit
	var/list/turf/assigned_turfs = list()
	var/area/shuttle/transit/assigned_area
	var/obj/docking_port/mobile/owner

/obj/docking_port/stationary/transit/Initialize()
	. = ..()
	SSshuttle.transit += src

/obj/docking_port/stationary/transit/proc/dezone()
	for(var/i in assigned_turfs)
		var/turf/T = i
		if(T.type == turf_type)
			T.ChangeTurf(/turf/open/space)
			T.flags |= UNUSED_TRANSIT_TURF

/obj/docking_port/stationary/transit/Destroy(force=FALSE)
	if(force)
		SSshuttle.transit -= src
		if(owner)
			owner = null
		if(assigned_turfs)
			dezone()
			assigned_turfs.Cut()
		assigned_turfs = null
	. = ..()


/obj/docking_port/mobile
	name = "shuttle"
	icon_state = "pinonclose"

	var/area/shuttle/areaInstance

	var/timer						//used as a timer (if you want time left to complete move, use timeLeft proc)
	var/last_timer_length

	var/mode = SHUTTLE_IDLE			//current shuttle mode
	var/callTime = 100				//time spent in transit (deciseconds). Should not be lower then 10 seconds without editing the animation of the hyperspace ripples.
	var/ignitionTime = 55			// time spent "starting the engines". Also rate limits how often we try to reserve transit space if its ever full of transiting shuttles.
	var/roundstart_move				//id of port to send shuttle to at roundstart

	// The direction the shuttle prefers to travel in
	var/preferred_direction = NORTH
	// And the angle from the front of the shuttle to the port
	var/port_angle = 0 // used to be travelDir

	var/obj/docking_port/stationary/destination
	var/obj/docking_port/stationary/previous

	var/obj/docking_port/stationary/transit/assigned_transit

	var/launch_status = NOLAUNCH

	var/knockdown = TRUE //Will it knock down mobs when it docks?

	// A timid shuttle will not register itself with the shuttle subsystem
	// All shuttle templates are timid
	var/timid = FALSE

	var/list/ripples = list()

/obj/docking_port/mobile/Initialize()
	. = ..()
	if(!timid)
		register()

/obj/docking_port/mobile/proc/register()
	SSshuttle.mobile += src

/obj/docking_port/mobile/Destroy(force)
	if(force)
		SSshuttle.mobile -= src
		destination = null
		previous = null
		assigned_transit = null
		areaInstance = null
	. = ..()

/obj/docking_port/mobile/Initialize(mapload)
	. = ..()

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
	return TRUE

//this is to check if this shuttle can physically dock at dock S
/obj/docking_port/mobile/proc/canDock(obj/docking_port/stationary/S)
	if(!istype(S))
		return SHUTTLE_NOT_A_DOCKING_PORT

	if(istype(S, /obj/docking_port/stationary/transit))
		return SHUTTLE_CAN_DOCK

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

	return SHUTTLE_CAN_DOCK

/obj/docking_port/mobile/proc/check_dock(obj/docking_port/stationary/S)
	var/status = canDock(S)
	if(status == SHUTTLE_CAN_DOCK)
		return TRUE
	else if(status == SHUTTLE_ALREADY_DOCKED)
		// We're already docked there, don't need to do anything.
		// Triggering shuttle movement code in place is weird
		return FALSE
	else
		var/msg = "Shuttle [src] cannot dock at [S], error: [status]"
		message_admins(msg)
		return FALSE

/obj/docking_port/mobile/proc/transit_failure()
	message_admins("Shuttle [src] repeatedly failed to create transit zone.")

//call the shuttle to destination S
/obj/docking_port/mobile/proc/request(obj/docking_port/stationary/S)
	if(!check_dock(S))
		testing("check_dock failed on request for [src]")
		return

	if(mode == SHUTTLE_IGNITING && destination == S)
		return

	switch(mode)
		if(SHUTTLE_CALL)
			if(S == destination)
				if(timeLeft(1) < callTime)
					setTimer(callTime)
			else
				destination = S
				setTimer(callTime)
		if(SHUTTLE_RECALL)
			if(S == destination)
				setTimer(callTime - timeLeft(1))
			else
				destination = S
				setTimer(callTime)
			mode = SHUTTLE_CALL
		if(SHUTTLE_IDLE, SHUTTLE_IGNITING)
			destination = S
			mode = SHUTTLE_IGNITING
			setTimer(ignitionTime)

//recall the shuttle to where it was previously
/obj/docking_port/mobile/proc/cancel()
	if(mode != SHUTTLE_CALL)
		return

	remove_ripples()

	invertTimer()
	mode = SHUTTLE_RECALL

/obj/docking_port/mobile/proc/enterTransit()
	if(SSshuttle.lockdown && z == ZLEVEL_STATION)	//emp went off, no escape
		return
	previous = null
//		if(!destination)
//			return
	var/obj/docking_port/stationary/S0 = get_docked()
	var/obj/docking_port/stationary/S1 = assigned_transit
	if(S1)
		if(dock(S1))
			WARNING("shuttle \"[id]\" could not enter transit space. Docked at [S0 ? S0.id : "null"]. Transit dock [S1 ? S1.id : "null"].")
		else
			previous = S0
	else
		WARNING("shuttle \"[id]\" could not enter transit space. S0=[S0 ? S0.id : "null"] S1=[S1 ? S1.id : "null"]")


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

/obj/docking_port/mobile/proc/create_ripples(obj/docking_port/stationary/S1, animate_time)
	var/list/turfs = ripple_area(S1)
	for(var/t in turfs)
		ripples += new /obj/effect/temp_visual/ripple(t, animate_time)

/obj/docking_port/mobile/proc/remove_ripples()
	for(var/R in ripples)
		qdel(R)
	ripples.Cut()

/obj/docking_port/mobile/proc/ripple_area(obj/docking_port/stationary/S1)
	var/list/L0 = return_ordered_turfs(x, y, z, dir, areaInstance)
	var/list/L1 = return_ordered_turfs(S1.x, S1.y, S1.z, S1.dir)

	var/list/ripple_turfs = list()

	for(var/i in 1 to L0.len)
		var/turf/T0 = L0[i]
		if(!T0)
			continue
		var/turf/T1 = L1[i]
		if(!T1)
			continue
		if(T0.type != T0.baseturf)
			ripple_turfs += T1

	return ripple_turfs

/obj/docking_port/mobile/proc/check_poddoors()
	for(var/obj/machinery/door/poddoor/shuttledock/pod in GLOB.airlocks)
		pod.check()

//this is the main proc. It instantly moves our mobile port to stationary port S1
//it handles all the generic behaviour, such as sanity checks, closing doors on the shuttle, stunning mobs, etc
/obj/docking_port/mobile/proc/dock(obj/docking_port/stationary/S1, force=FALSE)
	if(S1.get_docked() == src)
		remove_ripples()
		return
	// Crashing this ship with NO SURVIVORS
	if(!force)
		if(!check_dock(S1))
			return -1
		if(!canMove())
			return -1

	var/obj/docking_port/stationary/S0 = get_docked()
	var/turf_type = /turf/open/space
	var/area_type = /area/space
	if(S0)
		if(S0.turf_type)
			turf_type = S0.turf_type
		if(S0.area_type)
			area_type = S0.area_type

	var/destination_turf_type = S1.turf_type

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
			var/area/old = T0.loc
			A0.contents += T0
			T0.change_area(old, A0)
	if (istype(S1, /obj/docking_port/stationary/transit))
		areaInstance.parallax_movedir = preferred_direction
	else
		areaInstance.parallax_movedir = FALSE
	remove_ripples()

	//move or squish anything in the way ship at destination
	roadkill(L0, L1, S1.dir)


	for(var/i in 1 to L0.len)
		var/turf/T0 = L0[i]
		if(!T0)
			continue
		var/turf/T1 = L1[i]
		if(!T1)
			continue
		if(T0.type == T0.baseturf)
			continue
		for(var/atom/movable/AM in T0)
			AM.beforeShuttleMove(T1, rotation)

	var/list/moved_atoms = list()

	for(var/i in 1 to L0.len)
		var/turf/T0 = L0[i]
		if(!T0)
			continue
		var/turf/T1 = L1[i]
		if(!T1)
			continue
		if(T0.type != T0.baseturf) //So if there is a hole in the shuttle we don't drag along the space/asteroid/etc to wherever we are going next
			T0.copyTurf(T1)
			T1.baseturf = destination_turf_type
			var/area/old = T1.loc
			areaInstance.contents += T1
			T1.change_area(old, areaInstance)

			//copy over air
			if(isopenturf(T1))
				var/turf/open/Ts1 = T1
				Ts1.copy_air_with_tile(T0)

			//move mobile to new location
			for(var/atom/movable/AM in T0)
				if(AM.onShuttleMove(T1, rotation, knockdown))
					moved_atoms += AM

		if(rotation)
			T1.shuttleRotate(rotation)

		SSair.remove_from_active(T1)
		T1.CalculateAdjacentTurfs()
		SSair.add_to_active(T1,1)

		T0.ChangeTurf(turf_type)

		SSair.remove_from_active(T0)
		T0.CalculateAdjacentTurfs()
		SSair.add_to_active(T0,1)

	for(var/am in moved_atoms)
		var/atom/movable/AM = am
		AM.afterShuttleMove()

	check_poddoors()
	S1.last_dock_time = world.time

	loc = S1.loc
	setDir(S1.dir)

/obj/docking_port/mobile/proc/findRoundstartDock()
	return SSshuttle.getDock(roundstart_move)

/obj/docking_port/mobile/proc/dockRoundstart()
	. = dock_id(roundstart_move)

/obj/docking_port/mobile/proc/dock_id(id)
	var/port = SSshuttle.getDock(id)
	if(port)
		. = dock(port)
	else
		. = null

/obj/effect/landmark/shuttle_import
	name = "Shuttle Import"

/obj/docking_port/mobile/proc/roadkill(list/L0, list/L1, dir)
	for(var/i in 1 to L0.len)
		var/turf/T0 = L0[i]
		var/turf/T1 = L1[i]
		if(!T0 || !T1)
			continue
		if(T0.type == T0.baseturf)
			continue
		// The corresponding tile will not be changed, so no roadkill

		for(var/atom/movable/AM in T1)
			if(ismob(AM))
				if(isliving(AM))
					var/mob/living/M = AM
					if(M.buckled)
						M.buckled.unbuckle_mob(M, 1)
					if(M.pulledby)
						M.pulledby.stop_pulling()
					M.stop_pulling()
					M.visible_message("<span class='warning'>[src] slams into [M]!</span>")
					if(M.key || M.get_ghost(TRUE))
						SSblackbox.add_details("shuttle_gib", "[type]")
					else
						SSblackbox.add_details("shuttle_gib_unintelligent", "[type]")
					M.gib()

			else //non-living mobs shouldn't be affected by shuttles, which is why this is an else
				if(istype(AM, /obj/singularity) && !istype(AM, /obj/singularity/narsie)) //it's a singularity but not a god, ignore it.
					continue
				if(!AM.anchored)
					step(AM, dir)
				else
					qdel(AM)

//used by shuttle subsystem to check timers
/obj/docking_port/mobile/proc/check()
	check_effects()

	if(mode == SHUTTLE_IGNITING)
		check_transit_zone()

	if(timeLeft(1) > 0)
		return
	// If we can't dock or we don't have a transit slot, wait for 20 ds,
	// then try again
	switch(mode)
		if(SHUTTLE_CALL)
			if(dock(destination))
				setTimer(20)
				return
		if(SHUTTLE_RECALL)
			if(dock(previous))
				setTimer(20)
				return
		if(SHUTTLE_IGNITING)
			if(check_transit_zone() != TRANSIT_READY)
				setTimer(20)
				return
			else
				mode = SHUTTLE_CALL
				setTimer(callTime)
				enterTransit()
				return

	mode = SHUTTLE_IDLE
	timer = 0
	destination = null

/obj/docking_port/mobile/proc/check_effects()
	if(!ripples.len)
		if((mode == SHUTTLE_CALL) || (mode == SHUTTLE_RECALL))
			var/tl = timeLeft(1)
			if(tl <= SHUTTLE_RIPPLE_TIME)
				create_ripples(destination, tl)

	var/obj/docking_port/stationary/S0 = get_docked()
	if(areaInstance.parallax_movedir && istype(S0, /obj/docking_port/stationary/transit) && timeLeft(1) <= PARALLAX_LOOP_TIME)
		parallax_slowdown()

/obj/docking_port/mobile/proc/parallax_slowdown()
	areaInstance.parallax_movedir = FALSE
	if(assigned_transit && assigned_transit.assigned_area)
		assigned_transit.assigned_area.parallax_movedir = FALSE
	var/list/L0 = return_ordered_turfs(x, y, z, dir, areaInstance)
	for (var/thing in L0)
		var/turf/T = thing
		for (var/thing2 in T)
			var/atom/movable/AM = thing2
			if (length(AM.client_mobs_in_contents))
				AM.update_parallax_contents()

/obj/docking_port/mobile/proc/check_transit_zone()
	if(assigned_transit)
		return TRANSIT_READY
	else
		SSshuttle.request_transit_dock(src)

/obj/docking_port/mobile/proc/setTimer(wait)
	timer = world.time + wait
	last_timer_length = wait

/obj/docking_port/mobile/proc/modTimer(multiple)
	var/time_remaining = timer - world.time
	if(time_remaining < 0 || !last_timer_length)
		return
	time_remaining *= multiple
	last_timer_length *= multiple
	setTimer(time_remaining)

/obj/docking_port/mobile/proc/invertTimer()
	if(!last_timer_length)
		return
	var/time_remaining = timer - world.time
	if(time_remaining > 0)
		var/time_passed = last_timer_length - time_remaining
		setTimer(time_passed)

//returns timeLeft
/obj/docking_port/mobile/proc/timeLeft(divisor)
	if(divisor <= 0)
		divisor = 10

	var/ds_remaining
	if(!timer)
		ds_remaining = callTime
	else
		ds_remaining = max(0, timer - world.time)

	. = round(ds_remaining / divisor, 1)

// returns 3-letter mode string, used by status screens and mob status panel
/obj/docking_port/mobile/proc/getModeStr()
	switch(mode)
		if(SHUTTLE_IGNITING)
			return "IGN"
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


// attempts to locate /obj/machinery/computer/shuttle with matching ID inside the shuttle
/obj/docking_port/mobile/proc/getControlConsole()
	for(var/obj/machinery/computer/shuttle/S in areaInstance)
		if(S.shuttleId == id)
			return S
	return null

/obj/docking_port/mobile/proc/hyperspace_sound(phase, list/areas)
	var/s
	switch(phase)
		if(HYPERSPACE_WARMUP)
			s = 'sound/effects/hyperspace_begin.ogg'
		if(HYPERSPACE_LAUNCH)
			s = 'sound/effects/hyperspace_progress.ogg'
		if(HYPERSPACE_END)
			s = 'sound/effects/hyperspace_end.ogg'
		else
			CRASH("Invalid hyperspace sound phase: [phase]")
	for(var/A in areas)
		for(var/obj/machinery/door/E in A)	//dumb, I know, but playing it on the engines doesn't do it justice
			playsound(E, s, 100, FALSE, max(width, height) - world.view)

/obj/docking_port/mobile/proc/is_in_shuttle_bounds(atom/A)
	var/turf/T = get_turf(A)
	if(T.z != z)
		return FALSE
	var/list/bounds= return_coords()
	var/turf/T0 = locate(bounds[1],bounds[2],z)
	var/turf/T1 = locate(bounds[3],bounds[4],z)
	if(T in block(T0,T1))
		return TRUE
	return FALSE


#undef DOCKING_PORT_HIGHLIGHT
