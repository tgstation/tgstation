/datum/component/orbiter
	can_transfer = TRUE
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Assoc list of all orbiters -> their initial matrix
	var/list/orbiter_list
	/// Assoc list of orbiters -> their orbiting parameters
	var/list/orbiter_params
	/// Movement tracker used to check when our owner moves
	var/datum/movement_detector/tracker

//radius: range to orbit at, radius of the circle formed by orbiting (in pixels)
//clockwise: whether you orbit clockwise or anti clockwise
//rotation_speed: how fast to rotate (how many ds should it take for a rotation to complete)
//rotation_segments: the resolution of the orbit circle, less = a more block circle, this can be used to produce hexagons (6 segments) triangles (3 segments), and so on, 36 is the best default.
//pre_rotation: Chooses to rotate src 90 degress towards the orbit dir (clockwise/anticlockwise), useful for things to go "head first" like ghosts
/datum/component/orbiter/Initialize(atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)
	if(!istype(orbiter) || !isatom(parent) || isarea(parent))
		return COMPONENT_INCOMPATIBLE

	orbiter_list = list()
	orbiter_params = list()

	begin_orbit(orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)

/datum/component/orbiter/RegisterWithParent()
	var/atom/target = parent

	target.orbiters = src
	if(ismovable(target))
		tracker = new(target, CALLBACK(src, PROC_REF(move_react)))

	RegisterSignal(parent, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, PROC_REF(orbiter_glide_size_update))

/datum/component/orbiter/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE)
	var/atom/target = parent
	target.orbiters = null
	QDEL_NULL(tracker)

/datum/component/orbiter/Destroy()
	var/atom/master = parent
	if(master.orbiters == src)
		master.orbiters = null
	for(var/i in orbiter_list)
		end_orbit(i)
	orbiter_list = null
	orbiter_params = null
	return ..()

/datum/component/orbiter/InheritComponent(datum/component/orbiter/newcomp, original, atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)
	if(!newcomp)
		begin_orbit(arglist(args.Copy(3)))
		return
	// The following only happens on component transfers
	for(var/o in newcomp.orbiter_list)
		var/atom/movable/incoming_orbiter = o
		incoming_orbiter.orbiting = src
		// It is important to transfer the signals so we don't get locked to the new orbiter component for all time
		newcomp.UnregisterSignal(incoming_orbiter, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_BEFORE_SHUTTLE_MOVE, COMSIG_ATOM_AFTER_SHUTTLE_MOVE))
		RegisterSignal(incoming_orbiter, COMSIG_MOVABLE_MOVED, PROC_REF(orbiter_move_react))
		RegisterSignal(incoming_orbiter, COMSIG_ATOM_BEFORE_SHUTTLE_MOVE, PROC_REF(orbiter_before_shuttle_move))

	orbiter_list += newcomp.orbiter_list
	orbiter_params += newcomp.orbiter_params
	newcomp.orbiter_list = null
	newcomp.orbiter_params = null

/datum/component/orbiter/PostTransfer(datum/new_parent)
	if(!isatom(new_parent) || isarea(new_parent) || !get_turf(new_parent))
		return COMPONENT_INCOMPATIBLE
	move_react(new_parent)

/datum/component/orbiter/proc/begin_orbit(atom/movable/orbiter, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)
	if(orbiter.orbiting)
		if(orbiter.orbiting == src)
			orbiter.orbiting.end_orbit(orbiter, TRUE)
		else
			orbiter.orbiting.end_orbit(orbiter)

	orbiter_params[orbiter] = args.Copy(2)
	orbiter_list[orbiter] = TRUE
	orbiter.orbiting = src

	ADD_TRAIT(orbiter, TRAIT_NO_FLOATING_ANIM, ORBITING_TRAIT)
	RegisterSignal(orbiter, COMSIG_MOVABLE_MOVED, PROC_REF(orbiter_move_react))
	RegisterSignal(orbiter, COMSIG_ATOM_BEFORE_SHUTTLE_MOVE, PROC_REF(orbiter_before_shuttle_move))

	SEND_SIGNAL(parent, COMSIG_ATOM_ORBIT_BEGIN, orbiter)

	var/matrix/initial_transform = matrix(orbiter.transform)
	orbiter_list[orbiter] = initial_transform

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

	orbiter.SpinAnimation(rotation_speed, -1, clockwise, rotation_segments, parallel = FALSE)

	if(ismob(orbiter))
		var/mob/orbiter_mob = orbiter
		orbiter_mob.updating_glide_size = FALSE
	if(ismovable(parent))
		var/atom/movable/movable_parent = parent
		orbiter.glide_size = movable_parent.glide_size

	orbiter.abstract_move(get_turf(parent))
	to_chat(orbiter, span_notice("Now orbiting [parent]."))

/datum/component/orbiter/proc/orbiter_before_shuttle_move(atom/source)
	SIGNAL_HANDLER
	// We need to detach ourselves before the shuttle moves and reattach afterwards
	end_orbit(source, TRUE)
	RegisterSignal(source, COMSIG_ATOM_AFTER_SHUTTLE_MOVE, PROC_REF(orbiter_after_shuttle_move))

/datum/component/orbiter/proc/orbiter_after_shuttle_move(atom/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_ATOM_AFTER_SHUTTLE_MOVE)
	begin_orbit(arglist(list(source) + orbiter_params[source]))

/datum/component/orbiter/proc/end_orbit(atom/movable/orbiter, refreshing=FALSE)
	if(!orbiter_list[orbiter])
		return
	UnregisterSignal(orbiter, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_BEFORE_SHUTTLE_MOVE, COMSIG_ATOM_AFTER_SHUTTLE_MOVE))
	SEND_SIGNAL(parent, COMSIG_ATOM_ORBIT_STOP, orbiter)
	orbiter.SpinAnimation(0, 0)
	if(istype(orbiter_list[orbiter],/matrix)) //This is ugly.
		orbiter.transform = orbiter_list[orbiter]
	orbiter_list -= orbiter
	if(!refreshing)
		orbiter_params -= orbiter
	orbiter.stop_orbit(src)
	orbiter.orbiting = null

	if(ismob(orbiter))
		var/mob/orbiter_mob = orbiter
		orbiter_mob.updating_glide_size = TRUE
		orbiter_mob.glide_size = 8

		if(isobserver(orbiter))
			var/mob/dead/observer/ghostie = orbiter
			ghostie.orbiting_ref = null

	REMOVE_TRAIT(orbiter, TRAIT_NO_FLOATING_ANIM, ORBITING_TRAIT)

	if(!refreshing && !length(orbiter_list) && !QDELING(src))
		qdel(src)

// This proc can receive signals by either the thing being directly orbited or anything holding it
/datum/component/orbiter/proc/move_react(atom/movable/master, atom/mover, atom/oldloc, direction)
	set waitfor = FALSE // Transfer calls this directly and it doesnt care if the ghosts arent done moving

	if(master.loc == oldloc)
		return

	var/turf/newturf = get_turf(master)
	if(!newturf)
		qdel(src)

	var/atom/curloc = master.loc
	for(var/atom/movable/movable_orbiter as anything in orbiter_list)
		if(QDELETED(movable_orbiter) || movable_orbiter.loc == newturf)
			continue
		movable_orbiter.abstract_move(newturf)
		if(CHECK_TICK && master.loc != curloc)
			// We moved again during the checktick, cancel current operation
			break


/datum/component/orbiter/proc/orbiter_move_react(atom/movable/orbiter, atom/oldloc, direction)
	SIGNAL_HANDLER

	if(orbiter.loc == get_turf(parent))
		return
	end_orbit(orbiter)

/datum/component/orbiter/proc/orbiter_glide_size_update(datum/source, target)
	SIGNAL_HANDLER
	for(var/orbiter in orbiter_list)
		var/atom/movable/movable_orbiter = orbiter
		movable_orbiter.glide_size = target

/////////////////////

/atom/movable/proc/orbit(atom/A, radius = 10, clockwise = FALSE, rotation_speed = 20, rotation_segments = 36, pre_rotation = TRUE)
	if(!istype(A) || !get_turf(A) || A == src)
		return
	if (HAS_TRAIT(A, TRAIT_ORBITING_FORBIDDEN))
		// Stealth-mins have an empty name, don't want "You cannot orbit   at this time."
		to_chat(src, span_notice("You cannot orbit ["[A]" || "them"] at this time."))
		return
	orbit_target = A
	return A.AddComponent(/datum/component/orbiter, src, radius, clockwise, rotation_speed, rotation_segments, pre_rotation)

/atom/movable/proc/stop_orbit(datum/component/orbiter/orbits)
	orbit_target = null
	return // We're just a simple hook

/atom/proc/transfer_observers_to(atom/target)
	if(!orbiters || !istype(target) || !get_turf(target) || target == src)
		return
	target.TakeComponent(orbiters)
