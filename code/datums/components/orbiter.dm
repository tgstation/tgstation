/datum/component/orbiter
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/list/orbiters
	var/datum/callback/orbiter_spy

//radius: range to orbit at, radius of the circle formed by orbiting (in pixels)
//clockwise: whether you orbit clockwise or anti clockwise
//rotation_speed: how fast to rotate (how many ds should it take for a rotation to complete)
//rotation_segments: the resolution of the orbit circle, less = a more block circle, this can be used to produce hexagons (6 segments) triangles (3 segments), and so on, 36 is the best default.
//pre_rotation: Chooses to rotate src 90 degress towards the orbit dir (clockwise/anticlockwise), useful for things to go "head first" like ghosts
//lockinorbit: Forces src to always be on A's turf, otherwise the orbit cancels when src gets too far away (eg: ghosts)
/datum/component/orbiter/Initialize(atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lockinorbit)
	if(!istype(orbiter) || !isatom(parent))
		return COMPONENT_INCOMPATIBLE

	orbiters = list()
	orbiter_spy = CALLBACK(src, .proc/orbiter_move_react)

	var/atom/master = parent
	master.orbiters = src

	begin_orbit(orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lockinorbit)

/datum/component/orbiter/RegisterWithParent()
	if(ismovableatom(parent))
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/move_react)

/datum/component/orbiter/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)

/datum/component/orbiter/Destroy()
	var/atom/master = parent
	master.orbiters = src
	orbiters = null
	orbiter_spy = null
	return ..()

/datum/component/orbiter/InheritComponent(datum/component/orbiter/newcomp, original, list/arguments)
	if(arguments)
		begin_orbit(arglist(arguments))
		return
	// The following only happens on component transfers
	var/atom/master = parent
	var/atom/other_master = newcomp.parent
	newcomp.move_react(other_master.loc, master.loc) // We're moving the orbiters to where we are first
	orbiters += newcomp.orbiters

/datum/component/orbiter/proc/begin_orbit(atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lockinorbit)
	orbiters[orbiter] = lockinorbit
	orbiter.orbiting = src
	RegisterSignal(orbiter, list(COMSIG_MOVABLE_MOVED), orbiter_spy)
	var/matrix/initial_transform = matrix(orbiter.transform)

	// Head first!
	if(pre_rotation)
		var/matrix/M = matrix(orbiter.transform)
		var/pre_rot = 90
		if(!clockwise)
			pre_rot = -90
		M.Turn(pre_rot)
		orbiter.transform = M

	var/matrix/shift = matrix(orbiter.transform)
	shift.Translate(0, radius)
	orbiter.transform = shift

	orbiter.SpinAnimation(rotation_speed, -1, clockwise, rotation_segments)

	//we stack the orbits up client side, so we can assign this back to normal server side without it breaking the orbit
	orbiter.transform = initial_transform
	orbiter.forceMove(get_turf(parent))
	to_chat(orbiter, "<span class='notice'>Now orbiting [parent].</span>")

/datum/component/orbiter/proc/end_orbit(atom/movable/orbiter)
	if(isnull(orbiters[orbiter]))
		return
	orbiter.SpinAnimation(0, 0)
	orbiters -= orbiter
	orbiter.stop_orbit(src)
	if(!length(orbiters))
		qdel(src)

/datum/component/orbiter/proc/move_react(atom/orbited, atom/oldloc, direction)
	var/turf/oldturf = get_turf(oldloc)
	var/turf/newturf = get_turf(parent)
	for(var/i in orbiters)
		var/atom/movable/thing = i
		if(!newturf || (!orbiters[thing] && thing.loc != oldturf && thing.loc != newturf))
			end_orbit(thing)
			continue
		thing.forceMove(newturf)
		CHECK_TICK

/datum/component/orbiter/proc/orbiter_move_react(atom/movable/orbiter, atom/oldloc, direction)
	if(orbiter.loc == get_turf(parent))
		return
	end_orbit(orbiter)

/////////////////////

/atom/movable/proc/orbit(atom/A, radius = 10, clockwise = FALSE, rotation_speed = 20, rotation_segments = 36, pre_rotation = TRUE, lockinorbit = FALSE)
	if(!istype(A))
		return

	return A.AddComponent(/datum/component/orbiter, src, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lockinorbit)

/atom/movable/proc/stop_orbit(datum/component/orbiter/orbits)
	return // We're just a simple hook

/atom/proc/transfer_observers_to(atom/target)
	var/datum/component/orbiter/orbits = GetComponent(/datum/component/orbiter)
	target.TakeComponent(orbits)