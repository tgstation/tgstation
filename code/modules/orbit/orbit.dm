/datum/orbit
	var/atom/movable/orbiter
	var/atom/orbiting
	var/lock = TRUE
	var/turf/lastloc
	var/lastprocess

/datum/orbit/New(_orbiter, _orbiting, _lock)
	orbiter = _orbiter
	orbiting = _orbiting
	SSorbit.processing += src
	if (!orbiting.orbiters)
		orbiting.orbiters = list()
	orbiting.orbiters += src

	if (orbiter.orbiting)
		orbiter.stop_orbit()
	orbiter.orbiting = src
	Check()
	lock = _lock

//do not qdel directly, use stop_orbit on the orbiter. (This way the orbiter can bind to the orbit stopping)
/datum/orbit/Destroy(force = FALSE)
	SSorbit.processing -= src
	if (orbiter)
		orbiter.orbiting = null
		orbiter = null
	if (orbiting)
		if (orbiting.orbiters)
			orbiting.orbiters -= src
			if (!orbiting.orbiters.len)//we are the last orbit, delete the list
				orbiting.orbiters = null
		orbiting = null
	return ..()

/datum/orbit/proc/Check(turf/targetloc, list/checked_already = list())
	//Avoid infinite loops for people who end up orbiting themself through another orbiter
	checked_already[src] = TRUE
	if (!orbiter)
		qdel(src)
		return
	if (!orbiting)
		orbiter.stop_orbit()
		return
	if (!orbiter.orbiting) //admin wants to stop the orbit.
		orbiter.orbiting = src //set it back to us first
		orbiter.stop_orbit()
	var/atom/movable/AM = orbiting
	if(istype(AM) && AM.orbiting && AM.orbiting.orbiting == orbiter)
		orbiter.stop_orbit()
		return
	lastprocess = world.time
	if (!targetloc)
		targetloc = get_turf(orbiting)
	if (!targetloc || (!lock && orbiter.loc != lastloc && orbiter.loc != targetloc))
		orbiter.stop_orbit()
		return
	var/turf/old_turf = get_turf(orbiter)
	var/turf/new_turf = get_turf(targetloc)
	if (old_turf?.z != new_turf?.z)
		orbiter.onTransitZ(old_turf?.z, new_turf?.z)
	// DO NOT PORT TO FORCEMOVE - MEMECODE WILL KILL MC
	orbiter.loc = targetloc
	orbiter.update_parallax_contents()
	orbiter.update_light()
	lastloc = orbiter.loc
	for(var/other_orbit in orbiter.orbiters)
		var/datum/orbit/OO = other_orbit
		//Skip if checked already
		if(checked_already[OO])
			continue
		OO.Check(targetloc, checked_already)

/atom/movable/var/datum/orbit/orbiting = null
/atom/var/list/orbiters = null

//A: atom to orbit
//radius: range to orbit at, radius of the circle formed by orbiting (in pixels)
//clockwise: whether you orbit clockwise or anti clockwise
//rotation_speed: how fast to rotate (how many ds should it take for a rotation to complete)
//rotation_segments: the resolution of the orbit circle, less = a more block circle, this can be used to produce hexagons (6 segments) triangles (3 segments), and so on, 36 is the best default.
//pre_rotation: Chooses to rotate src 90 degress towards the orbit dir (clockwise/anticlockwise), useful for things to go "head first" like ghosts
//lockinorbit: Forces src to always be on A's turf, otherwise the orbit cancels when src gets too far away (eg: ghosts)

/atom/movable/proc/orbit(atom/A, radius = 10, clockwise = FALSE, rotation_speed = 20, rotation_segments = 36, pre_rotation = TRUE, lockinorbit = FALSE)
	if (!istype(A))
		return

	new/datum/orbit(src, A, lockinorbit)
	if (!orbiting) //something failed, and our orbit datum deleted itself
		return
	var/matrix/initial_transform = matrix(transform)

	//Head first!
	if (pre_rotation)
		var/matrix/M = matrix(transform)
		var/pre_rot = 90
		if(!clockwise)
			pre_rot = -90
		M.Turn(pre_rot)
		transform = M

	var/matrix/shift = matrix(transform)
	shift.Translate(0,radius)
	transform = shift

	SpinAnimation(rotation_speed, -1, clockwise, rotation_segments)

	//we stack the orbits up client side, so we can assign this back to normal server side without it breaking the orbit
	transform = initial_transform

/atom/movable/proc/stop_orbit()
	SpinAnimation(0,0)
	qdel(orbiting)

/atom/Destroy(force = FALSE)
	. = ..()
	if (orbiters)
		for (var/thing in orbiters)
			var/datum/orbit/O = thing
			if (O.orbiter)
				O.orbiter.stop_orbit()

/atom/movable/Destroy(force = FALSE)
	. = ..()
	if (orbiting)
		stop_orbit()

/atom/movable/proc/transfer_observers_to(atom/movable/target)
	if(orbiters)
		for(var/thing in orbiters)
			var/datum/orbit/O = thing
			if(O.orbiter && isobserver(O.orbiter))
				var/mob/dead/observer/D = O.orbiter
				D.ManualFollow(target)
