//use this define to highlight docking port bounding boxes (ONLY FOR DEBUG USE)
#ifdef TESTING
#define DOCKING_PORT_HIGHLIGHT
#endif

//NORTH default dir
/obj/docking_port
	invisibility = INVISIBILITY_ABSTRACT
	icon = 'icons/obj/device.dmi'
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
	var/hidden = FALSE //are we invisible to shuttle navigation computers?

	//these objects are indestructible
/obj/docking_port/Destroy(force)
	// unless you assert that you know what you're doing. Horrible things
	// may result.
	if(force)
		..()
		. = QDEL_HINT_QUEUE
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
/obj/docking_port/proc/return_ordered_turfs(_x, _y, _z, _dir)
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

	for(var/dx in 0 to width-1)
		var/compX = dx-dwidth
		for(var/dy in 0 to height-1)
			var/compY = dy-dheight
			// realX = _x + compX*cos - compY*sin
			// realY = _y + compY*cos - compX*sin
			// locate(realX, realY, _z)
			var/turf/T = locate(_x + compX*cos - compY*sin, _y + compY*cos + compX*sin, _z)
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
	if(P)
		return P.id

/obj/docking_port/proc/is_in_shuttle_bounds(atom/A)
	var/turf/T = get_turf(A)
	if(T.z != z)
		return FALSE
	var/list/bounds = return_coords()
	var/x0 = bounds[1]
	var/y0 = bounds[2]
	var/x1 = bounds[3]
	var/y1 = bounds[4]
	if(!ISINRANGE(T.x, min(x0, x1), max(x0, x1)))
		return FALSE
	if(!ISINRANGE(T.y, min(y0, y1), max(y0, y1)))
		return FALSE
	return TRUE

/obj/docking_port/stationary
	name = "dock"

	area_type = SHUTTLE_DEFAULT_UNDERLYING_AREA

	var/last_dock_time

	var/datum/map_template/shuttle/roundstart_template
	var/json_key

/obj/docking_port/stationary/Initialize(mapload)
	. = ..()
	SSshuttle.stationary += src
	if(!id)
		id = "[SSshuttle.stationary.len]"
	if(name == "dock")
		name = "dock[SSshuttle.stationary.len]"

	if(mapload)
		for(var/turf/T in return_turfs())
			T.flags_1 |= NO_RUINS_1

	#ifdef DOCKING_PORT_HIGHLIGHT
	highlight("#f00")
	#endif

/obj/docking_port/stationary/Destroy(force)
	if(force)
		SSshuttle.stationary -= src
	. = ..()

/obj/docking_port/stationary/proc/load_roundstart()
	if(json_key)
		var/sid = SSmapping.config.shuttles[json_key]
		roundstart_template = SSmapping.shuttle_templates[sid]
		if(!roundstart_template)
			CRASH("json_key:[json_key] value \[[sid]\] resulted in a null shuttle template for [src]")
	else if(roundstart_template) // passed a PATH
		var/sid = "[initial(roundstart_template.port_id)]_[initial(roundstart_template.suffix)]"

		roundstart_template = SSmapping.shuttle_templates[sid]
		if(!roundstart_template)
			CRASH("Invalid path ([roundstart_template]) passed to docking port.")

	if(roundstart_template)
		SSshuttle.manipulator.action_load(roundstart_template, src)

//returns first-found touching shuttleport
/obj/docking_port/stationary/get_docked()
	. = locate(/obj/docking_port/mobile) in loc

/obj/docking_port/stationary/transit
	name = "In Transit"
	var/datum/turf_reservation/reserved_area
	var/area/shuttle/transit/assigned_area
	var/obj/docking_port/mobile/owner

/obj/docking_port/stationary/transit/Initialize()
	. = ..()
	SSshuttle.transit += src

/obj/docking_port/stationary/transit/Destroy(force=FALSE)
	if(force)
		if(get_docked())
			log_world("A transit dock was destroyed while something was docked to it.")
		SSshuttle.transit -= src
		if(owner)
			if(owner.assigned_transit == src)
				owner.assigned_transit = null
			owner = null
		if(!QDELETED(reserved_area))
			qdel(reserved_area)
		reserved_area = null
	return ..()

/obj/docking_port/mobile
	name = "shuttle"
	icon_state = "pinonclose"

	area_type = SHUTTLE_DEFAULT_SHUTTLE_AREA_TYPE

	var/list/shuttle_areas

	var/timer						//used as a timer (if you want time left to complete move, use timeLeft proc)
	var/last_timer_length

	var/mode = SHUTTLE_IDLE			//current shuttle mode
	var/callTime = 100				//time spent in transit (deciseconds). Should not be lower then 10 seconds without editing the animation of the hyperspace ripples.
	var/ignitionTime = 55			// time spent "starting the engines". Also rate limits how often we try to reserve transit space if its ever full of transiting shuttles.

	// The direction the shuttle prefers to travel in
	var/preferred_direction = NORTH
	// And the angle from the front of the shuttle to the port
	var/port_direction = NORTH

	var/obj/docking_port/stationary/destination
	var/obj/docking_port/stationary/previous

	var/obj/docking_port/stationary/transit/assigned_transit

	var/launch_status = NOLAUNCH

	var/list/movement_force = list("KNOCKDOWN" = 3, "THROW" = 2)

	var/list/ripples = list()
	var/engine_coeff = 1 //current engine coeff
	var/current_engines = 0 //current engine power
	var/initial_engines = 0 //initial engine power
	var/can_move_docking_ports = FALSE //if this shuttle can move docking ports other than the one it is docked at
	var/list/hidden_turfs = list()

/obj/docking_port/mobile/proc/register()
	SSshuttle.mobile += src

/obj/docking_port/mobile/Destroy(force)
	if(force)
		SSshuttle.mobile -= src
		destination = null
		previous = null
		QDEL_NULL(assigned_transit)		//don't need it where we're goin'!
		shuttle_areas = null
		remove_ripples()
	. = ..()

/obj/docking_port/mobile/Initialize(mapload)
	. = ..()

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

// Called after the shuttle is loaded from template
/obj/docking_port/mobile/proc/linkup(datum/map_template/shuttle/template, obj/docking_port/stationary/dock)
	var/list/static/shuttle_id = list()
	var/idnum = ++shuttle_id[template]
	if(idnum > 1)
		if(id == initial(id))
			id = "[id][idnum]"
		if(name == initial(name))
			name = "[name] [idnum]"
	for(var/i in shuttle_areas)
		var/area/place = i
		for(var/obj/machinery/computer/shuttle/comp in place)
			comp.connect_to_shuttle(src, dock, idnum)
		for(var/obj/machinery/computer/camera_advanced/shuttle_docker/comp in place)
			comp.connect_to_shuttle(src, dock, idnum)
		for(var/obj/machinery/status_display/shuttle/sd in place)
			sd.connect_to_shuttle(src, dock, idnum)


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

/obj/docking_port/mobile/proc/check_dock(obj/docking_port/stationary/S, silent=FALSE)
	var/status = canDock(S)
	if(status == SHUTTLE_CAN_DOCK)
		return TRUE
	else
		if(status != SHUTTLE_ALREADY_DOCKED && !silent) // SHUTTLE_ALREADY_DOCKED is no cause for error
			var/msg = "Shuttle [src] cannot dock at [S], error: [status]"
			message_admins(msg)
		// We're already docked there, don't need to do anything.
		// Triggering shuttle movement code in place is weird
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
	if((SSshuttle.lockdown && is_station_level(z)) || !canMove())	//emp went off, no escape
		mode = SHUTTLE_IDLE
		return
	previous = null
	if(!destination)
		// sent to transit with no destination -> unlimited timer
		timer = INFINITY
	var/obj/docking_port/stationary/S0 = get_docked()
	var/obj/docking_port/stationary/S1 = assigned_transit
	if(S1)
		if(initiate_docking(S1) != DOCKING_SUCCESS)
			WARNING("shuttle \"[id]\" could not enter transit space. Docked at [S0 ? S0.id : "null"]. Transit dock [S1 ? S1.id : "null"].")
		else
			previous = S0
	else
		WARNING("shuttle \"[id]\" could not enter transit space. S0=[S0 ? S0.id : "null"] S1=[S1 ? S1.id : "null"]")


/obj/docking_port/mobile/proc/jumpToNullSpace()
	// Destroys the docking port and the shuttle contents.
	// Not in a fancy way, it just ceases.
	var/obj/docking_port/stationary/current_dock = get_docked()

	var/underlying_area_type = SHUTTLE_DEFAULT_UNDERLYING_AREA
	// If the shuttle is docked to a stationary port, restore its normal
	// "empty" area and turf
	if(current_dock && current_dock.area_type)
		underlying_area_type = current_dock.area_type

	var/list/old_turfs = return_ordered_turfs(x, y, z, dir)

	var/area/underlying_area = GLOB.areas_by_type[underlying_area_type]
	if(!underlying_area)
		underlying_area = new underlying_area_type(null)

	for(var/i in 1 to old_turfs.len)
		var/turf/oldT = old_turfs[i]
		if(!oldT || !istype(oldT.loc, area_type))
			continue
		var/area/old_area = oldT.loc
		underlying_area.contents += oldT
		oldT.change_area(old_area, underlying_area)
		oldT.empty(FALSE)

		// Here we locate the bottomost shuttle boundary and remove all turfs above it
		var/list/baseturf_cache = oldT.baseturfs
		for(var/k in 1 to length(baseturf_cache))
			if(ispath(baseturf_cache[k], /turf/baseturf_skipover/shuttle))
				oldT.ScrapeAway(baseturf_cache.len - k + 1)
				break

	qdel(src, force=TRUE)

/obj/docking_port/mobile/proc/intoTheSunset()
	// Loop over mobs
	for(var/t in return_turfs())
		var/turf/T = t
		for(var/mob/living/M in T.GetAllContents())
			// If they have a mind and they're not in the brig, they escaped
			if(M.mind && !istype(t, /turf/open/floor/plasteel/shuttle/red) && !istype(t, /turf/open/floor/mineral/plastitanium/red/brig))
				M.mind.force_escaped = TRUE
			// Ghostize them and put them in nullspace stasis (for stat & possession checks)
			M.notransform = TRUE
			M.ghostize(FALSE)
			M.moveToNullspace()

	// Now that mobs are stowed, delete the shuttle
	jumpToNullSpace()

/obj/docking_port/mobile/proc/create_ripples(obj/docking_port/stationary/S1, animate_time)
	var/list/turfs = ripple_area(S1)
	for(var/t in turfs)
		ripples += new /obj/effect/abstract/ripple(t, animate_time)

/obj/docking_port/mobile/proc/remove_ripples()
	QDEL_LIST(ripples)

/obj/docking_port/mobile/proc/ripple_area(obj/docking_port/stationary/S1)
	var/list/L0 = return_ordered_turfs(x, y, z, dir)
	var/list/L1 = return_ordered_turfs(S1.x, S1.y, S1.z, S1.dir)

	var/list/ripple_turfs = list()

	for(var/i in 1 to L0.len)
		var/turf/T0 = L0[i]
		var/turf/T1 = L1[i]
		if(!T0 || !T1)
			continue  // out of bounds
		if(T0.type == T0.baseturfs)
			continue  // indestructible
		if(!istype(T0.loc, area_type) || istype(T0.loc, /area/shuttle/transit))
			continue  // not part of the shuttle
		ripple_turfs += T1

	return ripple_turfs

/obj/docking_port/mobile/proc/check_poddoors()
	for(var/obj/machinery/door/poddoor/shuttledock/pod in GLOB.airlocks)
		pod.check()

/obj/docking_port/mobile/proc/dock_id(id)
	var/port = SSshuttle.getDock(id)
	if(port)
		. = initiate_docking(port)
	else
		. = null

/obj/effect/landmark/shuttle_import
	name = "Shuttle Import"

// Never move the shuttle import landmark, otherwise things get WEIRD
/obj/effect/landmark/shuttle_import/onShuttleMove()
	return FALSE

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
			var/error = initiate_docking(destination, preferred_direction)
			if(error && error & (DOCKING_NULL_DESTINATION | DOCKING_NULL_SOURCE))
				var/msg = "A mobile dock in transit exited initiate_docking() with an error. This is most likely a mapping problem: Error: [error],  ([src]) ([previous][ADMIN_JMP(previous)] -> [destination][ADMIN_JMP(destination)])"
				WARNING(msg)
				message_admins(msg)
				mode = SHUTTLE_IDLE
				return
			else if(error)
				setTimer(20)
				return
		if(SHUTTLE_RECALL)
			if(initiate_docking(previous) != DOCKING_SUCCESS)
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
	var/list/L0 = return_ordered_turfs(x, y, z, dir)
	for (var/thing in L0)
		var/turf/T = thing
		if(!T || !istype(T.loc, area_type))
			continue
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
	if(timeleft > 1 HOURS)
		return "--:--"
	else if(timeleft > 0)
		return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"
	else
		return "00:00"


/obj/docking_port/mobile/proc/getStatusText()
	var/obj/docking_port/stationary/dockedAt = get_docked()

	if(istype(dockedAt, /obj/docking_port/stationary/transit))
		if (timeLeft() > 1 HOURS)
			return "hyperspace"
		else
			var/obj/docking_port/stationary/dst
			if(mode == SHUTTLE_RECALL)
				dst = previous
			else
				dst = destination
			. = "transit towards [dst?.name || "unknown location"] ([getTimerStr()])"
	else
		return dockedAt?.name || "unknown"


/obj/docking_port/mobile/proc/getDbgStatusText()
	var/obj/docking_port/stationary/dockedAt = get_docked()
	. = (dockedAt && dockedAt.name) ? dockedAt.name : "unknown"
	if(istype(dockedAt, /obj/docking_port/stationary/transit))
		var/obj/docking_port/stationary/dst
		if(mode == SHUTTLE_RECALL)
			dst = previous
		else
			dst = destination
		if(dst)
			. = "(transit to) [dst.name || dst.id]"
		else
			. = "(transit to) nowhere"
	else if(dockedAt)
		. = dockedAt.name || dockedAt.id
	else
		. = "unknown"


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
		return CLAMP(1 - delta * change_per_engine,ENGINE_COEFF_MIN,ENGINE_COEFF_MAX)
	if(new_value < initial_engines)
		var/delta = initial_engines - new_value
		var/change_per_engine = 1 //doesn't really matter should not be happening for 0 engine shuttles
		if(initial_engines > 0)
			change_per_engine = (ENGINE_COEFF_MAX -  1) / initial_engines //just linear drop to max delay
		return CLAMP(1 + delta * change_per_engine,ENGINE_COEFF_MIN,ENGINE_COEFF_MAX)


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
		initiate_docking(SSshuttle.getDock("[id]_away")) //Escape pods dock at centcom
		mode = SHUTTLE_ENDGAME

/obj/docking_port/mobile/emergency/on_emergency_dock()
	return
