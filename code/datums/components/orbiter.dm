/datum/component/orbiter
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	var/list/orbiters
	var/datum/callback/orbiter_spy
	var/datum/callback/orbited_spy

//radius: range to orbit at, radius of the circle formed by orbiting (in pixels)
//clockwise: whether you orbit clockwise or anti clockwise
//rotation_speed: how fast to rotate (how many ds should it take for a rotation to complete)
//rotation_segments: the resolution of the orbit circle, less = a more block circle, this can be used to produce hexagons (6 segments) triangles (3 segments), and so on, 36 is the best default.
//pre_rotation: Chooses to rotate src 90 degress towards the orbit dir (clockwise/anticlockwise), useful for things to go "head first" like ghosts
/datum/component/orbiter/Initialize(atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)
	if(!istype(orbiter) || !isatom(parent) || isarea(parent))
		return COMPONENT_INCOMPATIBLE

	orbiters = list()
	orbiter_spy = CALLBACK(src, .proc/orbiter_move_react)
	orbited_spy = CALLBACK(src, .proc/move_react)

	var/atom/master = parent
	master.orbiters = src

	begin_orbit(orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)

/datum/component/orbiter/RegisterWithParent()
	var/atom/target = parent
	while(ismovableatom(target))
		RegisterSignal(target, COMSIG_MOVABLE_MOVED, orbited_spy)
		target = target.loc

/datum/component/orbiter/UnregisterFromParent()
	var/atom/target = parent
	while(ismovableatom(target))
		UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
		target = target.loc

/datum/component/orbiter/Destroy()
	var/atom/master = parent
	master.orbiters = null
	for(var/i in orbiters)
		end_orbit(i)
	orbiters = null
	QDEL_NULL(orbiter_spy)
	QDEL_NULL(orbited_spy)
	return ..()

/datum/component/orbiter/InheritComponent(datum/component/orbiter/newcomp, original, list/arguments)
	if(arguments)
		begin_orbit(arglist(arguments))
		return
	// The following only happens on component transfers
	orbiters += newcomp.orbiters

/datum/component/orbiter/PostTransfer()
	if(!isatom(parent) || isarea(parent) || !get_turf(parent))
		return COMPONENT_INCOMPATIBLE
	move_react()

/datum/component/orbiter/proc/begin_orbit(atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)
	if(orbiter.orbiting)
		if(orbiter.orbiting == src)
			orbiter.orbiting.end_orbit(orbiter, TRUE)
		else
			orbiter.orbiting.end_orbit(orbiter)
	orbiters[orbiter] = TRUE
	orbiter.orbiting = src
	RegisterSignal(orbiter, COMSIG_MOVABLE_MOVED, orbiter_spy)
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

/datum/component/orbiter/proc/end_orbit(atom/movable/orbiter, refreshing=FALSE)
	if(!orbiters[orbiter])
		return
	UnregisterSignal(orbiter, COMSIG_MOVABLE_MOVED)
	orbiter.SpinAnimation(0, 0)
	orbiters -= orbiter
	orbiter.stop_orbit(src)
	orbiter.orbiting = null
	if(!refreshing && !length(orbiters) && !QDELING(src))
		qdel(src)

// This proc can receive signals by either the thing being directly orbited or anything holding it
/datum/component/orbiter/proc/move_react(atom/orbited, atom/oldloc, direction)
	set waitfor = FALSE // Transfer calls this directly and it doesnt care if the ghosts arent done moving

	var/atom/movable/master = parent
	if(master.loc == oldloc)
		return

	var/turf/newturf = get_turf(master)
	if(!newturf)
		qdel(src)

	// Handling the signals of stuff holding us (or not anymore)
	// These are prety rarely activated, how often are you following something in a bag?
	if(oldloc && !isturf(oldloc)) // We used to be registered to it, probably
		var/atom/target = oldloc
		while(ismovableatom(target))
			UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
			target = target.loc
	if(orbited?.loc && orbited.loc != newturf) // We want to know when anything holding us moves too
		var/atom/target = orbited.loc
		while(ismovableatom(target))
			RegisterSignal(target, COMSIG_MOVABLE_MOVED, orbited_spy, TRUE)
			target = target.loc

	var/atom/curloc = master.loc
	for(var/i in orbiters)
		var/atom/movable/thing = i
		if(QDELETED(thing) || thing.loc == newturf)
			continue
		thing.forceMove(newturf)
		if(CHECK_TICK && master.loc != curloc)
			// We moved again during the checktick, cancel current operation
			break


/datum/component/orbiter/proc/orbiter_move_react(atom/movable/orbiter, atom/oldloc, direction)
	if(orbiter.loc == get_turf(parent))
		return
	end_orbit(orbiter)

/////////////////////

/atom/movable/proc/orbit(atom/A, radius = 10, clockwise = FALSE, rotation_speed = 20, rotation_segments = 36, pre_rotation = TRUE)
	if(!istype(A) || !get_turf(A) || A == src)
		return

	return A.AddComponent(/datum/component/orbiter, src, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)

/atom/movable/proc/stop_orbit(datum/component/orbiter/orbits)
	return // We're just a simple hook

/atom/proc/transfer_observers_to(atom/target)
	if(!orbiters || !istype(target) || !get_turf(target) || target == src)
		return
	target.TakeComponent(orbiters)