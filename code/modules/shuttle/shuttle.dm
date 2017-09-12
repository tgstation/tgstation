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
	anchored = TRUE
//
	var/id
	// this should point -away- from the dockingport door, ie towards the ship
	dir = NORTH
	var/width = 0	//size of covered area, perpendicular to dir
	var/height = 0	//size of covered area, parallel to dir
	var/dwidth = 0	//position relative to covered area, perpendicular to dir
	var/dheight = 0	//position relative to covered area, parallel to dir

	var/area_type
	var/turf_type
	var/baseturf_type

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

//returns turfs within our projected rectangle in no particular order
/obj/docking_port/proc/return_turfs()
	var/list/L = return_coords()
	var/turf/T0 = locate(L[1],L[2],z)
	var/turf/T1 = locate(L[3],L[4],z)
	return block(T0,T1)

//returns turfs within our projected rectangle in a specific order.
//this ensures that turfs are copied over in the same order, regardless of any rotation
/obj/docking_port/proc/return_ordered_turfs(_x, _y, _z, _dir, area_type)
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
			if(area_type)
				if(istype(get_area(T), area_type))
					. += T
				else
					. += null
			else
				. += T

/obj/docking_port/proc/return_ordered_assoc_turfs(_x, _y, _z, _dir)
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
			.[T] = NONE

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

	turf_type = /turf/open/space
	baseturf_type = /turf/open/space
	area_type = /area/space

	var/list/baseturf_cache

	var/last_dock_time

/obj/docking_port/stationary/Initialize()
	. = ..()
	SSshuttle.stationary += src
	if(!id)
		id = "[SSshuttle.stationary.len]"
	if(name == "dock")
		name = "dock[SSshuttle.stationary.len]"
	baseturf_cache = typecacheof(baseturf_type)

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
	for(var/i in 1 to assigned_turfs.len)
		var/turf/T = assigned_turfs[i]
		if(T.type == turf_type)
			T.ChangeTurf(/turf/open/space,/turf/open/space)
			T.flags_1 |= UNUSED_TRANSIT_TURF_1

/obj/docking_port/stationary/transit/Destroy(force=FALSE)
	if(force)
		if(get_docked())
			to_chat("A transit dock was destroyed while something was docked to it.")
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

	area_type = /area/shuttle

	var/list/area/shuttle/shuttle_areas

	var/timer						//used as a timer (if you want time left to complete move, use timeLeft proc)
	var/last_timer_length

	var/mode = SHUTTLE_IDLE			//current shuttle mode
	var/callTime = 100				//time spent in transit (deciseconds). Should not be lower then 10 seconds without editing the animation of the hyperspace ripples.
	var/ignitionTime = 55			// time spent "starting the engines". Also rate limits how often we try to reserve transit space if its ever full of transiting shuttles.
	var/roundstart_move				//id of port to send shuttle to at roundstart

	// The direction the shuttle prefers to travel in
	var/preferred_direction = NORTH
	// And the angle from the front of the shuttle to the port
	var/port_direction = NORTH

	var/obj/docking_port/stationary/destination
	var/obj/docking_port/stationary/previous

	var/obj/docking_port/stationary/transit/assigned_transit

	var/launch_status = NOLAUNCH

	var/list/movement_force = list("KNOCKDOWN" = 3, "THROW" = 0)

	// A timid shuttle will not register itself with the shuttle subsystem
	// All shuttle templates are timid
	var/timid = FALSE

	var/list/ripples = list()
	var/engine_coeff = 1 //current engine coeff
	var/current_engines = 0 //current engine power
	var/initial_engines = 0 //initial engine power

/obj/docking_port/mobile/proc/register()
	SSshuttle.mobile += src

/obj/docking_port/mobile/Destroy(force)
	if(force)
		SSshuttle.mobile -= src
		destination = null
		previous = null
		assigned_transit = null
		shuttle_areas = null
	. = ..()

/obj/docking_port/mobile/Initialize(mapload)
	. = ..()
	if(!timid)
		register()

	if(!id)
		id = "[SSshuttle.mobile.len]"
	if(name == "shuttle")
		name = "shuttle[SSshuttle.mobile.len]"

	shuttle_areas = list()
	var/list/all_turfs = return_ordered_turfs(x, y, z, dir)
	for(var/i in 1 to all_turfs.len)
		var/turf/curT = all_turfs[i]
		var/area/cur_area = curT.loc
		if(istype(cur_area, area_type))
			shuttle_areas[cur_area] = TRUE

	initial_engines = count_engines()
	current_engines = initial_engines

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
				if(timeLeft(1) < callTime * engine_coeff)
					setTimer(callTime * engine_coeff)
			else
				destination = S
				setTimer(callTime * engine_coeff)
		if(SHUTTLE_RECALL)
			if(S == destination)
				setTimer(callTime * engine_coeff - timeLeft(1))
			else
				destination = S
				setTimer(callTime * engine_coeff)
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
	if(SSshuttle.lockdown && (z in GLOB.station_z_levels))	//emp went off, no escape
		return
	previous = null
//		if(!destination)
//			return
	var/obj/docking_port/stationary/S0 = get_docked()
	var/obj/docking_port/stationary/S1 = assigned_transit
	if(S1)
		if(dock(S1) != DOCKING_SUCCESS)
			WARNING("shuttle \"[id]\" could not enter transit space. Docked at [S0 ? S0.id : "null"]. Transit dock [S1 ? S1.id : "null"].")
		else
			previous = S0
	else
		WARNING("shuttle \"[id]\" could not enter transit space. S0=[S0 ? S0.id : "null"] S1=[S1 ? S1.id : "null"]")


/obj/docking_port/mobile/proc/jumpToNullSpace()
	// Destroys the docking port and the shuttle contents.
	// Not in a fancy way, it just ceases.
	var/obj/docking_port/stationary/current_dock = get_docked()

	var/turf_type = /turf/open/space
	var/baseturf_type = /turf/open/space
	var/underlying_area_type = /area/space
	// If the shuttle is docked to a stationary port, restore its normal
	// "empty" area and turf
	if(current_dock)
		if(current_dock.turf_type)
			turf_type = current_dock.turf_type
		if(current_dock.baseturf_type)
			baseturf_type = current_dock.baseturf_type
		if(current_dock.area_type)
			underlying_area_type = current_dock.area_type

	var/list/old_turfs = return_ordered_turfs(x, y, z, dir, area_type)
	var/area/underlying_area = locate(underlying_area_type) in GLOB.sortedAreas
	if(!underlying_area)
		underlying_area = new underlying_area_type(null)

	for(var/i in 1 to old_turfs.len)
		var/turf/oldT = old_turfs[i]
		if(!oldT)
			continue
		var/area/old_area = oldT.loc
		underlying_area.contents += oldT
		oldT.change_area(old_area, underlying_area)
		oldT.empty(turf_type, baseturf_type)

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
	var/list/L0 = return_ordered_turfs(x, y, z, dir, area_type)
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

//this is the main proc. It instantly moves our mobile port to stationary port new_dock
/obj/docking_port/mobile/proc/dock(obj/docking_port/stationary/new_dock, movement_direction, force=FALSE)
	// Crashing this ship with NO SURVIVORS

	if(new_dock.get_docked() == src)
		remove_ripples()
		return DOCKING_SUCCESS

	if(!force)
		if(!check_dock(new_dock))
			return DOCKING_BLOCKED
		if(!canMove())
			return DOCKING_IMMOBILIZED

	var/obj/docking_port/stationary/old_dock = get_docked()
	var/underlying_turf_type = /turf/open/space //The turf that gets placed under where the shuttle moved from
	var/underlying_baseturf_type = /turf/open/space //The baseturf that the gets assigned to the turf_type above
	var/underlying_area_type = /area/space //The area that gets placed under where the shuttle moved from
	var/list/baseturf_cache
	if(old_dock) //Dock overwrites
		if(old_dock.turf_type)
			underlying_turf_type = old_dock.turf_type
		if(old_dock.baseturf_type)
			underlying_baseturf_type = old_dock.baseturf_type
		if(old_dock.area_type)
			underlying_area_type = old_dock.area_type
		if(old_dock.baseturf_cache)
			baseturf_cache = old_dock.baseturf_cache
	if(!baseturf_cache)
		//Don't want to call this needlessly
		baseturf_cache = typecacheof(underlying_baseturf_type)

	/**************************************************************************************************************
		old_turfs is an associative list with a turf:bitflag structure
		new_turfs is a standard list composed of turf instances
		The bitflag contains the data for what inhabitants of that coordinate should be moved to the new location
		The bitflags can be found in __DEFINES/shuttles.dm
	*/
	var/list/old_turfs = return_ordered_assoc_turfs(x, y, z, dir)
	var/list/new_turfs = return_ordered_turfs(new_dock.x, new_dock.y, new_dock.z, new_dock.dir)
	/**************************************************************************************************************/

	var/area/underlying_old_area = locate("[underlying_area_type]")
	if(!underlying_old_area)
		underlying_old_area = new underlying_area_type(null)

	var/rotation = 0
	if(new_dock.dir != dir) //Even when the dirs are the same rotation is coming out as not 0 for some reason
		rotation = dir2angle(new_dock.dir)-dir2angle(dir)
		if ((rotation % 90) != 0)
			rotation += (rotation % 90) //diagonal rotations not allowed, round up
		rotation = SimplifyDegrees(rotation)

	if(!movement_direction)
		movement_direction = turn(preferred_direction, 180)

	remove_ripples()

	var/list/moved_atoms = list() //Everything not a turf that gets moved in the shuttle
	var/list/areas_to_move = list() //unique assoc list of areas on turfs being moved

	/****************************************All beforeShuttleMove procs*****************************************/
	var/index = 0
	for(var/place in old_turfs)
		index++
		var/turf/oldT = place
		var/turf/newT = new_turfs[index]
		if(!newT || !oldT)
			continue

		var/area/old_area = oldT.loc
		var/move_mode = old_area.beforeShuttleMove(shuttle_areas)											//areas

		for(var/i in 1 to oldT.contents.len)
			var/atom/movable/moving_atom = oldT.contents[i]
			move_mode = moving_atom.beforeShuttleMove(newT, rotation, move_mode)							//atoms

		move_mode = oldT.fromShuttleMove(newT, underlying_turf_type, baseturf_cache, move_mode)	//turfs
		move_mode = newT.toShuttleMove(oldT, move_mode , src)												//turfs

		if(move_mode & MOVE_AREA)
			areas_to_move[old_area] = TRUE

		old_turfs[place] = move_mode

	/*******************************************All onShuttleMove procs******************************************/

	index = 0
	for(var/place in old_turfs)
		index++
		var/turf/oldT = place
		var/turf/newT = new_turfs[index]
		var/move_mode = old_turfs[place]
		if(move_mode & MOVE_CONTENTS)
			for(var/thing in oldT)
				var/atom/movable/moving_atom = thing
				moving_atom.onShuttleMove(newT, oldT, rotation, movement_force, movement_direction, old_dock)//atoms
				moved_atoms += moving_atom
		if(move_mode & MOVE_TURF)
			oldT.onShuttleMove(newT, underlying_turf_type, underlying_baseturf_type, rotation, movement_force, movement_direction)//turfs
		if(move_mode & MOVE_AREA)
			var/area/shuttle_area = oldT.loc
			shuttle_area.onShuttleMove(oldT, newT, underlying_old_area)										//areas

	/******************************************All afterShuttleMove procs****************************************/

	index = 0
	for(var/thing in old_turfs)
		index++
		var/turf/oldT = thing
		var/turf/newT = new_turfs[index]
		newT.afterShuttleMove(oldT)																			//turfs

	for(var/i in 1 to moved_atoms.len)
		var/atom/movable/moved_object = moved_atoms[i]
		moved_object.afterShuttleMove(movement_force, dir, preferred_direction, movement_direction)			//atoms

	underlying_old_area.afterShuttleMove()

	for(var/thing in areas_to_move)
		var/area/internal_area = thing
		internal_area.afterShuttleMove()																	//areas

	check_poddoors()
	new_dock.last_dock_time = world.time
	setDir(new_dock.dir)

	return DOCKING_SUCCESS

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
			if(dock(destination, preferred_direction) != DOCKING_SUCCESS)
				setTimer(20)
				return
		if(SHUTTLE_RECALL)
			if(dock(previous) != DOCKING_SUCCESS)
				setTimer(20)
				return
		if(SHUTTLE_IGNITING)
			if(check_transit_zone() != TRANSIT_READY)
				setTimer(20)
				return
			else
				mode = SHUTTLE_CALL
				setTimer(callTime * engine_coeff)
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
	if(istype(S0, /obj/docking_port/stationary/transit) && timeLeft(1) <= PARALLAX_LOOP_TIME)
		for(var/place in shuttle_areas)
			var/area/shuttle/shuttle_area = place
			if(shuttle_area.parallax_movedir)
				parallax_slowdown()

/obj/docking_port/mobile/proc/parallax_slowdown()
	for(var/place in shuttle_areas)
		var/area/shuttle/shuttle_area = place
		shuttle_area.parallax_movedir = FALSE
	if(assigned_transit && assigned_transit.assigned_area)
		assigned_transit.assigned_area.parallax_movedir = FALSE
	var/list/L0 = return_ordered_turfs(x, y, z, dir, area_type)
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
		ds_remaining = callTime * engine_coeff
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
	for(var/place in shuttle_areas)
		var/area/shuttle/shuttle_area = place
		for(var/obj/machinery/computer/shuttle/S in shuttle_area)
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

// Losing all initial engines should get you 2
// Adding another set of engines at 0.5 time
/obj/docking_port/mobile/proc/alter_engines(mod)
	if(mod == 0)
		return
	var/old_coeff = engine_coeff
	engine_coeff = get_engine_coeff(current_engines,mod)
	current_engines = max(0,current_engines + mod)
	if(in_flight())
		var/delta_coeff = engine_coeff / old_coeff
		modTimer(delta_coeff)

/obj/docking_port/mobile/proc/count_engines()
	. = 0
	for(var/thing in shuttle_areas)
		var/area/shuttle/areaInstance = thing
		for(var/obj/structure/shuttle/engine/E in areaInstance.contents)
			if(!QDELETED(E))
				. += E.engine_power

// Double initial engines to get to 0.5 minimum
// Lose all initial engines to get to 2
//For 0 engine shuttles like BYOS 5 engines to get to doublespeed
/obj/docking_port/mobile/proc/get_engine_coeff(current,engine_mod)
	var/new_value = max(0,current + engine_mod)
	if(new_value == initial_engines)
		return 1
	if(new_value > initial_engines)
		var/delta = new_value - initial_engines
		var/change_per_engine = (1 - ENGINE_COEFF_MIN) / ENGINE_DEFAULT_MAXSPEED_ENGINES // 5 by default
		if(initial_engines > 0)
			change_per_engine = (1 - ENGINE_COEFF_MIN) / initial_engines // or however many it had
		return Clamp(1 - delta * change_per_engine,ENGINE_COEFF_MIN,ENGINE_COEFF_MAX)
	if(new_value < initial_engines)
		var/delta = initial_engines - new_value
		var/change_per_engine = 1 //doesn't really matter should not be happening for 0 engine shuttles
		if(initial_engines > 0)
			change_per_engine = (ENGINE_COEFF_MAX -  1) / initial_engines //just linear drop to max delay
		return Clamp(1 + delta * change_per_engine,ENGINE_COEFF_MIN,ENGINE_COEFF_MAX)


/obj/docking_port/mobile/proc/in_flight()
	switch(mode)
		if(SHUTTLE_CALL,SHUTTLE_RECALL)
			return TRUE
		if(SHUTTLE_IDLE,SHUTTLE_IGNITING)
			return FALSE
		else
			return FALSE // hmm

/obj/docking_port/mobile/emergency/in_flight()
	switch(mode)
		if(SHUTTLE_ESCAPE)
			return TRUE
		if(SHUTTLE_STRANDED,SHUTTLE_ENDGAME)
			return FALSE
		else
			return ..()


//Called when emergency shuttle leaves the station
/obj/docking_port/mobile/proc/on_emergency_launch()
	if(launch_status == UNLAUNCHED) //Pods will not launch from the mine/planet, and other ships won't launch unless we tell them to.
		launch_status = ENDGAME_LAUNCHED
		enterTransit()

/obj/docking_port/mobile/emergency/on_emergency_launch()
	return

//Called when emergency shuttle docks at centcom
/obj/docking_port/mobile/proc/on_emergency_dock()
	//Mapping a new docking point for each ship mappers could potentially want docking with centcom would take up lots of space, just let them keep flying off into the sunset for their greentext
	if(launch_status == ENDGAME_LAUNCHED)
		launch_status = ENDGAME_TRANSIT

/obj/docking_port/mobile/pod/on_emergency_dock()
	if(launch_status == ENDGAME_LAUNCHED)
		dock(SSshuttle.getDock("[id]_away")) //Escape pods dock at centcom
		mode = SHUTTLE_ENDGAME

/obj/docking_port/mobile/emergency/on_emergency_dock()
	return

#undef DOCKING_PORT_HIGHLIGHT
