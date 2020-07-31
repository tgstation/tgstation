/atom/movable
	layer = OBJ_LAYER
	appearance_flags = PIXEL_SCALE
	// Movement related vars
	step_size = 8
	//PIXEL MOVEMENT VARS
	/// stores fractional pixel movement in the x
	var/fx
	/// stores fractional pixel movement in the y
	var/fy
	var/walking = NONE
	var/move_resist = MOVE_RESIST_DEFAULT
	var/move_force = MOVE_FORCE_DEFAULT
	var/pull_force = PULL_FORCE_DEFAULT
	///whether we are already sidestepping or not
	var/sidestep = FALSE

	//Misc
	var/last_move = null
	var/last_move_time = 0
	var/anchored = FALSE
	var/datum/thrownthing/throwing = null
	var/throw_speed = 2 //How many tiles to move per ds when being thrown. Float values are fully supported
	var/throw_range = 7
	var/mob/pulledby = null
	var/initial_language_holder = /datum/language_holder
	var/datum/language_holder/language_holder	// Mindless mobs and objects need language too, some times. Mind holder takes prescedence.
	var/verb_say = "says"
	var/verb_ask = "asks"
	var/verb_exclaim = "exclaims"
	var/verb_whisper = "whispers"
	var/verb_sing = "sings"
	var/verb_yell = "yells"
	var/speech_span
	var/inertia_dir = 0
	var/atom/inertia_last_loc
	var/inertia_moving = FALSE
	var/pass_flags = NONE
	/// If false makes [CanPass][/atom/proc/CanPass] call [CanPassThrough][/atom/movable/proc/CanPassThrough] on this type instead of using default behaviour
	var/generic_canpass = TRUE
	var/atom/movable/moving_from_pull		//attempt to resume grab after moving instead of before.
	var/list/client_mobs_in_contents // This contains all the client mobs within this container
	var/list/acted_explosions	//for explosion dodging
	var/datum/forced_movement/force_moving = null	//handled soley by forced_movement.dm
	var/movement_type = GROUND		//Incase you have multiple types, you automatically use the most useful one. IE: Skating on ice, flippers on water, flying over chasm/space, etc.
	var/atom/movable/pulling
	var/grab_state = 0
	var/throwforce = 0
	var/datum/component/orbiter/orbiting
	var/can_be_z_moved = TRUE

	var/zfalling = FALSE

	///Last location of the atom for demo recording purposes
	var/atom/demo_last_loc

	/// Either FALSE, [EMISSIVE_BLOCK_GENERIC], or [EMISSIVE_BLOCK_UNIQUE]
	var/blocks_emissive = FALSE
	///Internal holder for emissive blocker object, do not use directly use blocks_emissive
	var/atom/movable/emissive_blocker/em_block
	///how bounds handle rotation
	var/brotation = BOUNDS_SIMPLE_ROTATE

	///Used for the calculate_adjacencies proc for icon smoothing.
	var/can_be_unanchored = FALSE

/atom/movable/Initialize(mapload)
	. = ..()
	update_bounds(olddir=NORTH, newdir=dir) // bounds assume north but some things arent north by default for some god knows reason
	switch(blocks_emissive)
		if(EMISSIVE_BLOCK_GENERIC)
			update_emissive_block()
		if(EMISSIVE_BLOCK_UNIQUE)
			render_target = ref(src)
			em_block = new(src, render_target)
			vis_contents += em_block


/atom/movable/Destroy(force)
	QDEL_NULL(proximity_monitor)
	QDEL_NULL(language_holder)
	QDEL_NULL(em_block)

	unbuckle_all_mobs(force = TRUE)

	if(loc)
		//Restore air flow if we were blocking it (movables with ATMOS_PASS_PROC will need to do this manually if necessary)
		if(((CanAtmosPass == ATMOS_PASS_DENSITY && density) || CanAtmosPass == ATMOS_PASS_NO) && isturf(loc))
			CanAtmosPass = ATMOS_PASS_YES
			air_update_turf(TRUE)
		loc.handle_atom_del(src)

		// If we have opacity, make sure to tell (potentially) affected light sources.
		if(opacity && isturf(loc))
			var/turf/turf_loc = loc
			var/old_has_opaque_atom = turf_loc.has_opaque_atom
			turf_loc.recalc_atom_opacity()
			if(old_has_opaque_atom != turf_loc.has_opaque_atom)
				turf_loc.reconsider_lights()

	invisibility = INVISIBILITY_ABSTRACT

	if(pulledby)
		pulledby.stop_pulling()

	if(orbiting)
		orbiting.end_orbit(src)
		orbiting = null

	. = ..()

	for(var/movable_content in contents)
		qdel(movable_content)

	LAZYCLEARLIST(client_mobs_in_contents)

	moveToNullspace()


/atom/movable/proc/update_emissive_block()
	if(blocks_emissive != EMISSIVE_BLOCK_GENERIC)
		return
	if(length(managed_vis_overlays))
		for(var/a in managed_vis_overlays)
			var/obj/effect/overlay/vis/vs
			if(vs.plane == EMISSIVE_BLOCKER_PLANE)
				SSvis_overlays.remove_vis_overlay(src, list(vs))
				break
	SSvis_overlays.add_vis_overlay(src, icon, icon_state, EMISSIVE_BLOCKER_LAYER, EMISSIVE_BLOCKER_PLANE, dir)

/atom/movable/proc/can_zFall(turf/source, levels = 1, turf/target, direction)
	if(!direction)
		direction = DOWN
	if(!source)
		source = get_turf(src)
		if(!source)
			return FALSE
	if(!target)
		target = get_step_multiz(source, direction)
		if(!target)
			return FALSE
	return !(movement_type & FLYING) && has_gravity(source) && !throwing

/atom/movable/proc/onZImpact(turf/T, levels)
	var/atom/highest = T
	for(var/i in T.contents)
		var/atom/A = i
		if(!A.density)
			continue
		if(isobj(A) || ismob(A))
			if(A.layer > highest.layer)
				highest = A
	INVOKE_ASYNC(src, .proc/SpinAnimation, 5, 2)
	return TRUE

//For physical constraints to travelling up/down.
/atom/movable/proc/can_zTravel(turf/destination, direction)
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	if(!direction)
		if(!destination)
			return FALSE
		direction = get_dir(T, destination)
	if(direction != UP && direction != DOWN)
		return FALSE
	if(!destination)
		destination = get_step_multiz(src, direction)
		if(!destination)
			return FALSE
	return T.zPassOut(src, direction, destination) && destination.zPassIn(src, direction, T)

/atom/movable/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, anchored))
			set_anchored(var_value)
			return TRUE
		if(NAMEOF(src, x))
			var/turf/T = locate(var_value, y, z)
			if(T)
				forceMove(T)
				return TRUE
			return FALSE
		if(NAMEOF(src, y))
			var/turf/T = locate(x, var_value, z)
			if(T)
				forceMove(T)
				return TRUE
			return FALSE
		if(NAMEOF(src, z))
			var/turf/T = locate(x, y, var_value)
			if(T)
				forceMove(T)
				return TRUE
			return FALSE
		if(NAMEOF(src, loc))
			if(istype(var_value, /atom))
				forceMove(var_value)
				return TRUE
			else if(isnull(var_value))
				moveToNullspace()
				return TRUE
			return FALSE
	return ..()

/atom/movable/proc/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	if(QDELETED(AM))
		return FALSE
	if(!(AM.can_be_pulled(src, state, force)))
		return FALSE

	// If we're pulling something then drop what we're currently pulling and pull this instead.
	if(pulling)
		if(state == 0)
			stop_pulling()
			return FALSE
		// Are we trying to pull something we are already pulling? Then enter grab cycle and end.
		if(AM == pulling)
			setGrabState(state)
			if(istype(AM,/mob/living))
				var/mob/living/AMob = AM
				AMob.grabbedby(src)
			return TRUE
		stop_pulling()

	SEND_SIGNAL(src, COMSIG_ATOM_START_PULL, AM, state, force)

	if(AM.pulledby)
		log_combat(AM, AM.pulledby, "pulled from", src)
		AM.pulledby.stop_pulling() //an object can't be pulled by two mobs at once.
	pulling = AM
	AM.pulledby = src
	setGrabState(state)
	AM.step_size = step_size
	if(ismob(AM))
		var/mob/M = AM
		M.update_movespeed() // set the proper step_size
		log_combat(src, M, "grabbed", addition="passive grab")
		if(!supress_message)
			M.visible_message("<span class='warning'>[src] grabs [M] passively.</span>", \
				"<span class='danger'>[src] grabs you passively.</span>")
	return TRUE

/atom/movable/proc/stop_pulling()
	if(!pulling)
		return
	pulling.pulledby = null
	var/atom/movable/ex_pulled = pulling
	pulling = null
	setGrabState(0)
	ex_pulled.step_size = initial(ex_pulled.step_size)
	if(isliving(ex_pulled))
		var/mob/living/L = ex_pulled
		L.update_mobility()// mob gets up if it was lyng down in a chokehold
		L.update_movespeed() // set their movespeed to the usual

/atom/movable/proc/Move_Pulled(atom/A, params)
	if(!check_pulling())
		return
	if(!Adjacent(A))
		to_chat(src, "<span class='warning'>You can't move [pulling] that far!</span>")
		return
	pulling.Move(get_turf(A), get_dir(pulling.loc, A))
	return TRUE

/mob/living/Move_Pulled(atom/A, params)
	. = ..()
	if(!. || !isliving(A))
		return
	var/mob/living/L = A
	set_pull_offsets(L, grab_state)

/atom/movable/proc/check_pulling()
	. = FALSE
	if(!pulling)
		if(pulledby && bounds_dist(src, pulledby) > 32)
			pulledby.stop_pulling()
		return
	if(bounds_dist(src, pulling) > 32)
		stop_pulling()
		return
	if(!isturf(loc))
		stop_pulling()
		return
	if(pulling.anchored || pulling.move_resist > move_force)
		stop_pulling()
		return
	if(isliving(pulling))
		var/mob/living/liv = pulling
		if(liv.buckled?.buckle_prevents_pull) //if they're buckled to something that disallows pulling, prevent it
			stop_pulling()
			return
	return TRUE

#define ANGLE_ADJUST 10
/**
  * Handles the movement of the object src is pulling
  *
  * Tries to correct the pulled object if it's stuck
  * uses degstep to move the pulled object at an angle
  */
/atom/movable/proc/handle_pulled_movement()
	if(!pulling)
		return FALSE
	if(pulling.anchored)
		return FALSE
	if(pulling.move_resist > move_force)
		return FALSE
	var/distance = bounds_dist(src, pulling)
	if(distance < 6)
		return FALSE
	var/angle = GET_DEG(pulling, src)
	if((angle % 45) > 1) // We arent directly on a cardinal from the thing
		var/tempA = WRAP(angle, 0, 45)
		if(tempA >= 22.5)
			angle += min(ANGLE_ADJUST, 45-tempA)
		else
			angle -= min(ANGLE_ADJUST, tempA)
	angle = SIMPLIFY_DEGREES(angle)
	var/direct = angle2dir(angle)
	if(!degstep(pulling, angle, distance-6))
		for(var/i in GLOB.cardinals)
			if(direct & i)
				if(step(pulling, i))
					return TRUE
	return FALSE

#undef ANGLE_ADJUST
/**
  * Checks the distance between the object we're pulling before moving
  *
  * Returns FALSE and prevents movement if the object we're pulling is too far and the direction
  * src is moving isn't towards the pulled object.
  * Returns TRUE and allows movement if the object we're pulling is in range.
  */
/atom/movable/proc/handle_pulled_premove(atom/newloc, direct, _step_x, _step_y)
	if((bounds_dist(src, pulling) > 16 + step_size) && !(direct & GET_PIXELDIR(src, pulling)))
		return FALSE
	return TRUE

/atom/movable/Move(atom/newloc, direct, _step_x, _step_y)
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, newloc, direct, _step_x, _step_y) & COMPONENT_MOVABLE_BLOCK_PRE_MOVE)
		return FALSE

	if(pulling && !handle_pulled_premove(newloc, direct, _step_x, _step_y))
		handle_pulled_movement()
		return FALSE

	var/atom/oldloc = loc

	. = ..()

	last_move = direct
	setDir(direct)
	if(.)
		Moved(oldloc, direct)
		if(pulling) //we were pulling a thing and didn't lose it during our move.
			handle_pulled_movement()
			check_pulling()
		if(has_buckled_mobs() && !handle_buckled_mob_movement(loc, direct, step_x, step_y))
			return FALSE
	else
		walk(src, NONE)

/// Called after a successful Move(). By this point, we've already moved
/atom/movable/proc/Moved(atom/OldLoc, Dir, Forced = FALSE)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, OldLoc, Dir, Forced)
	if(OldLoc != loc)
		SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED_TURF, OldLoc, Dir)
	if (!inertia_moving)
		newtonian_move(Dir)
	if (length(client_mobs_in_contents))
		update_parallax_contents()

	return TRUE


// Make sure you know what you're doing if you call this, this is intended to only be called by byond directly.
// You probably want CanPass()
/atom/movable/Cross(atom/movable/AM)
	SEND_SIGNAL(src, COMSIG_MOVABLE_CROSS, AM)
	return CanPass(AM, AM.loc)

//oldloc = old location on atom, inserted when forceMove is called and ONLY when forceMove is called!
/atom/movable/Crossed(atom/movable/AM, oldloc)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	SEND_SIGNAL(src, COMSIG_MOVABLE_CROSSED, AM)

/atom/movable/Uncross(atom/movable/AM, atom/newloc)
	. = ..()
	if(SEND_SIGNAL(src, COMSIG_MOVABLE_UNCROSS, AM) & COMPONENT_MOVABLE_BLOCK_UNCROSS)
		return FALSE
	if(isturf(newloc) && !CheckExit(AM, newloc))
		return FALSE

/atom/movable/Uncrossed(atom/movable/AM)
	SEND_SIGNAL(src, COMSIG_MOVABLE_UNCROSSED, AM)

/atom/movable/Bump(atom/A)
	SEND_SIGNAL(src, COMSIG_MOVABLE_BUMP, A)
	handle_sidestep(A)
	. = ..()
	if(!QDELETED(throwing))
		throwing.hit_atom(A)
		. = TRUE
		if(QDELETED(A))
			return
	A.Bumped(src)

/**
  * Moves the movable to the side of an obstacle
  *
  * Called by Bump
  * Uses bounds to check for an opening on the left or right
  * Shifts the object over accordingly, isn't applied to players.
  * Only applies to clientless mobs and doesn't kick in on unanchored movables or other mobs.
  * Arguments:
  * * A - atom that we're going to try and sidestep
  */
/atom/movable/proc/handle_sidestep(atom/A)
	if(sidestep || ismob(A) || (length(client_mobs_in_contents) && !ismecha(src))) // already sidestepping or bumped into a mob or a player
		return
	if(ismovable(A)) // additional checks for movables
		var/atom/movable/AM = A
		if(AM.sidestep) // is the thing we bumped sidestepping?
			return
	sidestep = TRUE
	var/slide_dist = 8
	if(pulledby && pulledby.step_size > slide_dist) // we're getting pulled by someone so let's slide over at their speed
		slide_dist = pulledby.step_size
	if(check_left(slide_dist)) // There is an opening on the left side of src
		slide_left(slide_dist)
	else if(check_right(slide_dist))
		slide_right(slide_dist)
	sidestep = FALSE


///checks if the left side of src is clear
/atom/movable/proc/check_left(slide_dist)
	var/list/atoms

	if(dir == EAST)
		atoms = obounds(src, 1, slide_dist)
	else if(dir == WEST)
		atoms = obounds(src, -1, -slide_dist)
	else if(dir == NORTH)
		atoms = obounds(src, -slide_dist, 1)
	else if(dir == SOUTH)
		atoms = obounds(src, slide_dist, -1)

	for(var/atom/A in atoms)
		if(!A.CanPass(src))
			return FALSE

	return TRUE

///slides src to the left
/atom/movable/proc/slide_left(slide_dist)
	if(dir == EAST)
		step(src, NORTH, slide_dist)
	else if(dir == WEST)
		step(src, SOUTH, slide_dist)
	else if(dir == NORTH)
		step(src, WEST, slide_dist)
	else if(dir == SOUTH)
		step(src, EAST, slide_dist)

///checks if the right side of src is clear
/atom/movable/proc/check_right(slide_dist)
	var/list/atoms

	if(dir == EAST)
		atoms = obounds(src, 1, -slide_dist)
	else if(dir == WEST)
		atoms = obounds(src, -1, slide_dist)
	else if(dir == NORTH)
		atoms = obounds(src, slide_dist, 1)
	else if(dir == SOUTH)
		atoms = obounds(src, -slide_dist, -1)

	for(var/atom/A in atoms)
		if(!A.CanPass(src))
			return FALSE

	return TRUE

///slides src to the right
/atom/movable/proc/slide_right(slide_dist)
	if(dir == EAST)
		step(src, SOUTH, slide_dist)
	else if(dir == WEST)
		step(src, NORTH, slide_dist)
	else if(dir == NORTH)
		step(src, EAST, slide_dist)
	else if(dir == SOUTH)
		step(src, WEST, slide_dist)


/atom/movable/setDir(direct)
	var/old_dir = dir
	. = ..()
	update_bounds(olddir=old_dir, newdir=direct)

/atom/movable/true_x()
	. = ..()
	. += step_x

/atom/movable/true_y()
	. = ..()
	. += step_y

/**
  * Updates bounds of the object depending on its brotation define
  *
  * Called on setDir and updates the bounds accordingly
  * Unless you have some really weird rotation try to implement a generic version of your rotation here and make a flag for it
  * Arguments:
  * * olddir - The old direction
  * * newdir - The new direction
  */
/atom/movable/proc/update_bounds(olddir, newdir)
	SEND_SIGNAL(src, COMSIG_MOVABLE_UPDATE_BOUNDS, args)

	if(newdir == olddir) // the direction hasn't changed
		return
	if(bound_width == bound_height && !bound_x && !bound_y) // We're a square and have no offset
		return

	if(brotation & BOUNDS_SIMPLE_ROTATE)
		var/rot = SIMPLIFY_DEGREES(dir2angle(newdir)-dir2angle(olddir))
		for(var/i in 90 to rot step 90)
			var/tempwidth = bound_width
			var/eastgap = CEILING(bound_width, 32) - bound_width - bound_x

			bound_width = bound_height
			bound_height = tempwidth

			bound_x = bound_y
			bound_y = eastgap

///Sets the anchored var and returns if it was sucessfully changed or not.
/atom/movable/proc/set_anchored(anchorvalue)
	SHOULD_CALL_PARENT(TRUE)
	if(anchored == anchorvalue)
		return
	. = anchored
	anchored = anchorvalue
	SEND_SIGNAL(src, COMSIG_MOVABLE_SET_ANCHORED, anchorvalue)

/atom/movable/proc/forceMove(atom/destination, _step_x=0, _step_y=0)
	. = FALSE
	if(islist(destination))
		if(length(destination) > 2)
			_step_x  = destination[2]
			_step_y = destination[3]
		destination = get_turf(destination[1])
	if(destination)
		. = doMove(destination, _step_x, _step_y)
	else
		CRASH("No valid destination passed into forceMove")

/// sets the step_ offsets to AM, or if AM is null sets the step_ values to the offsets
/**
  * sets the step_ offsets to that of AM, or if AM is null sets the step_ values to the offsets
  *
  * Pixel counterpart of forceMove
  * should be used when only wanting to set the step values
  * can either pass a movable you want to copy step values from
  * leave AM null and input step_ values manually
  * Arguments:
  * * AM - The movable we want to copy step_ values from
  * * _step_x - Alternative step_x value when AM is null
  * * _step_y - Alternative step_y value when AM is null
  */
/atom/movable/proc/forceStep(atom/movable/AM=null, _step_x=0, _step_y=0)
	if(!AM)
		step_x = _step_x
		step_y = _step_y
	else
		step_x = AM.step_x
		step_y = AM.step_y

/atom/movable/proc/moveToNullspace()
	return doMove(null)

/atom/movable/proc/doMove(atom/destination, _step_x=0, _step_y=0)
	. = FALSE

	if(destination == loc) // Force move in place?
		Moved(loc, NONE, TRUE)
		return TRUE

	var/atom/oldloc = loc
	var/area/oldarea = get_area(oldloc)
	var/area/destarea = get_area(destination)
	var/list/old_bounds = obounds()

	loc = destination
	step_x = _step_x
	step_y = _step_y

	if(oldloc && oldloc != loc)
		oldloc.Exited(src, destination)
		if(oldarea && oldarea != destarea)
			oldarea.Exited(src, destination)

	var/list/new_bounds = obounds()

	for(var/i in old_bounds)
		if(i in new_bounds)
			continue
		var/atom/thing = i
		thing.Uncrossed(src)

	if(!loc) // I hope you know what you're doing
		return TRUE

	var/turf/oldturf = get_turf(oldloc)
	var/turf/destturf = get_turf(destination)
	var/oldz = (oldturf ? oldturf.z : null)
	var/newz = (destturf ? destturf.z : null)
	if(oldz != newz)
		onTransitZ(oldz, newz)

	destination.Entered(src, oldloc)
	if(destarea && oldarea != destarea)
		destarea.Entered(src, oldloc)

	for(var/i in new_bounds)
		if(i in old_bounds)
			continue
		var/atom/thing = i
		thing.Crossed(src, oldloc)

	Moved(oldloc, NONE, TRUE)
	return TRUE


/atom/movable/proc/onTransitZ(old_z,new_z)
	SEND_SIGNAL(src, COMSIG_MOVABLE_Z_CHANGED, old_z, new_z)
	for (var/item in src) // Notify contents of Z-transition. This can be overridden IF we know the items contents do not care.
		var/atom/movable/AM = item
		AM.onTransitZ(old_z,new_z)

/atom/movable/proc/setMovetype(newval)
	movement_type = newval

/**
  * Called whenever an object moves and by mobs when they attempt to move themselves through space
  * And when an object or action applies a force on src, see [newtonian_move][/atom/movable/proc/newtonian_move]
  *
  * Return 0 to have src start/keep drifting in a no-grav area and 1 to stop/not start drifting
  *
  * Mobs should return 1 if they should be able to move of their own volition, see [/client/Move]
  *
  * Arguments:
  * * movement_dir - 0 when stopping or any dir when trying to move
  */
/atom/movable/proc/Process_Spacemove(movement_dir = 0)
	if(has_gravity(src))
		return 1

	if(pulledby)
		return 1

	if(throwing)
		return 1

	if(!isturf(loc))
		return 1

	if(locate(/obj/structure/lattice) in range(1, get_turf(src))) //Not realistic but makes pushing things in space easier
		return 1

	return 0


/// Only moves the object if it's under no gravity
/atom/movable/proc/newtonian_move(direction)
	if(!loc || Process_Spacemove(0))
		inertia_dir = 0
		return 0

	inertia_dir = direction
	if(!direction)
		return 1
	inertia_last_loc = loc
	SSspacedrift.processing[src] = src
	return 1

/atom/movable/proc/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	set waitfor = 0
	var/hitpush = TRUE
	var/impact_signal = SEND_SIGNAL(src, COMSIG_MOVABLE_IMPACT, hit_atom, throwingdatum)
	if(impact_signal & COMPONENT_MOVABLE_IMPACT_FLIP_HITPUSH)
		hitpush = FALSE // hacky, tie this to something else or a proper workaround later

	if(!(impact_signal && (impact_signal & COMPONENT_MOVABLE_IMPACT_NEVERMIND))) // in case a signal interceptor broke or deleted the thing before we could process our hit
		return hit_atom.hitby(src, throwingdatum=throwingdatum, hitpush=hitpush)

/atom/movable/hitby(atom/movable/AM, skipcatch, hitpush = TRUE, blocked, datum/thrownthing/throwingdatum)
	if(!anchored && hitpush && (!throwingdatum || (throwingdatum.force >= (move_resist * MOVE_FORCE_PUSH_RATIO))))
		step(src, AM.dir, 16)
	..()

/atom/movable/proc/safe_throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG, gentle = FALSE, params)
	if((force < (move_resist * MOVE_FORCE_THROW_RATIO)) || (move_resist == INFINITY))
		return
	return throw_at(target, range, speed, thrower, spin, diagonals_first, callback, force, gentle, TRUE, params)

///If this returns FALSE then callback will not be called.
/atom/movable/proc/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG, gentle = FALSE, quickstart = TRUE, params)
	. = FALSE

	if(QDELETED(src))
		CRASH("Qdeleted thing being thrown around.")

	if (!target || speed <= 0)
		return

	if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_THROW, args) & COMPONENT_CANCEL_THROW)
		return

	if (pulledby)
		pulledby.stop_pulling()

	//They are moving! Wouldn't it be cool if we calculated their momentum and added it to the throw?
	if (thrower && thrower.last_move && thrower.client && thrower.client.move_delay >= world.time + world.tick_lag*2)
		var/user_momentum = thrower.cached_multiplicative_slowdown
		if (!user_momentum) //no movement_delay, this means they move once per byond tick, lets calculate from that instead.
			user_momentum = world.tick_lag

		user_momentum = 1 / user_momentum // convert from ds to the tiles per ds that throw_at uses.

		if (get_dir(thrower, target) & last_move)
			user_momentum = user_momentum //basically a noop, but needed
		else if (get_dir(target, thrower) & last_move)
			user_momentum = -user_momentum //we are moving away from the target, lets slowdown the throw accordingly
		else
			user_momentum = 0


		if (user_momentum)
			//first lets add that momentum to range.
			range *= (user_momentum / speed) + 1
			//then lets add it to speed
			speed += user_momentum
			if (speed <= 0)
				return//no throw speed, the user was moving too fast.

	. = TRUE // No failure conditions past this point.

	var/target_zone
	if(QDELETED(thrower))
		thrower = null //Let's not pass a qdeleting reference if any.
	else
		target_zone = thrower.zone_selected

	var/datum/thrownthing/TT = new(src, target, get_turf(target), get_dir(src, target), range, speed, thrower, diagonals_first, force, gentle, callback, target_zone)
	if(thrower && params)
		var/list/calculated = calculate_projectile_angle_and_pixel_offsets(thrower, params)
		TT.angle = calculated[1]
	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)
	var/dx = (target.x > src.x) ? EAST : WEST
	var/dy = (target.y > src.y) ? NORTH : SOUTH

	if (dist_x == dist_y)
		TT.pure_diagonal = 1

	else if(dist_x <= dist_y)
		var/olddist_x = dist_x
		var/olddx = dx
		dist_x = dist_y
		dist_y = olddist_x
		dx = dy
		dy = olddx
	TT.dist_x = dist_x
	TT.dist_y = dist_y
	TT.dx = dx
	TT.dy = dy
	TT.diagonal_error = dist_x/2 - dist_y
	TT.start_time = world.time

	if(pulledby)
		pulledby.stop_pulling()

	throwing = TT
	for(var/atom/movable/A in obounds()) // check if we hit something
		if(A != thrower && A.density)
			Bump(A)
			return
	if(spin)
		SpinAnimation(5, 1)

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_THROW, TT, spin)
	SSthrowing.processing[src] = TT
	if (SSthrowing.state == SS_PAUSED && length(SSthrowing.currentrun))
		SSthrowing.currentrun[src] = TT
	if (quickstart)
		TT.tick()

/atom/movable/proc/handle_buckled_mob_movement(newloc,direct, _step_x, _step_y)
	for(var/m in buckled_mobs)
		var/mob/living/buckled_mob = m
		if(!buckled_mob.Move(newloc, direct, _step_x, _step_y))
			forceMove(buckled_mob.loc, buckled_mob.step_x, buckled_mob.step_y)
			last_move = buckled_mob.last_move
			inertia_dir = last_move
			buckled_mob.inertia_dir = last_move
			return 0
	return 1

/atom/movable/proc/force_pushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return FALSE

/atom/movable/proc/force_push(atom/movable/AM, force = move_force, direction, silent = FALSE)
	. = AM.force_pushed(src, force, direction)
	if(!silent && .)
		visible_message("<span class='warning'>[src] forcefully pushes against [AM]!</span>", "<span class='warning'>You forcefully push against [AM]!</span>")

/atom/movable/proc/move_crush(atom/movable/AM, force = move_force, direction, silent = FALSE)
	. = AM.move_crushed(src, force, direction)
	if(!silent && .)
		visible_message("<span class='danger'>[src] crushes past [AM]!</span>", "<span class='danger'>You crush [AM]!</span>")

/atom/movable/proc/move_crushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return FALSE

/atom/movable/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(mover in buckled_mobs)
		return TRUE

/// Returns true or false to allow src to move through the blocker, mover has final say
/atom/movable/proc/CanPassThrough(atom/blocker, turf/target, blocker_opinion)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)
	return blocker_opinion

/// called when this atom is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/atom/movable/proc/on_exit_storage(datum/component/storage/concrete/S)
	return

/// called when this atom is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/atom/movable/proc/on_enter_storage(datum/component/storage/concrete/S)
	return

/atom/movable/proc/get_spacemove_backup()
	for(var/A in obounds(src, 16))
		if(isarea(A))
			continue
		else if(isturf(A))
			var/turf/turf = A
			if(!turf.density)
				continue
			return turf
		else
			var/atom/movable/AM = A
			if(!AM.CanPass(src) || AM.density)
				if(AM.inertia_dir)
					continue
				return AM

///called when a mob resists while inside a container that is itself inside something.
/atom/movable/proc/relay_container_resist(mob/living/user, obj/O)
	return


/atom/movable/proc/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && (visual_effect_icon || used_item))
		do_item_attack_animation(A, visual_effect_icon, used_item)

	if(A == src)
		return //don't do an animation if attacking self
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0

	var/direction = get_dir(src, A)
	if(direction & NORTH)
		pixel_y_diff = 8
	else if(direction & SOUTH)
		pixel_y_diff = -8

	if(direction & EAST)
		pixel_x_diff = 8
	else if(direction & WEST)
		pixel_x_diff = -8

	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, time = 2)
	animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, time = 2)

/atom/movable/proc/do_item_attack_animation(atom/A, visual_effect_icon, obj/item/used_item)
	var/image/I
	if(visual_effect_icon)
		I = image('icons/effects/effects.dmi', A, visual_effect_icon, A.layer + 0.1)
	else if(used_item)
		I = image(icon = used_item, loc = A, layer = A.layer + 0.1)
		I.plane = GAME_PLANE

		// Scale the icon.
		I.transform *= 0.75
		// The icon should not rotate.
		I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA

		// Set the direction of the icon animation.
		var/direction = get_dir(src, A)
		if(direction & NORTH)
			I.pixel_y = -16
		else if(direction & SOUTH)
			I.pixel_y = 16

		if(direction & EAST)
			I.pixel_x = -16
		else if(direction & WEST)
			I.pixel_x = 16

		if(!direction) // Attacked self?!
			I.pixel_z = 16

	if(!I)
		return

	flick_overlay(I, GLOB.clients, 5) // 5 ticks/half a second

	// And animate the attack!
	animate(I, alpha = 175, pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 3)

/atom/movable/vv_get_dropdown()
	. = ..()
	. += "<option value='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(src)]'>Follow</option>"
	. += "<option value='?_src_=holder;[HrefToken()];admingetmovable=[REF(src)]'>Get</option>"

/atom/movable/proc/ex_check(ex_id)
	if(!ex_id)
		return TRUE
	LAZYINITLIST(acted_explosions)
	if(ex_id in acted_explosions)
		return FALSE
	acted_explosions += ex_id
	return TRUE

//TODO: Better floating
/atom/movable/proc/float(on)
	if(throwing)
		return
	if(on && !(movement_type & FLOATING))
		animate(src, pixel_y = pixel_y + 2, time = 10, loop = -1)
		sleep(10)
		animate(src, pixel_y = pixel_y - 2, time = 10, loop = -1)
		setMovetype(movement_type | FLOATING)
	else if (!on && (movement_type & FLOATING))
		animate(src, pixel_y = initial(pixel_y), time = 10)
		setMovetype(movement_type & ~FLOATING)


/* 	Language procs
*	Unless you are doing something very specific, these are the ones you want to use.
*/

/// Gets or creates the relevant language holder. For mindless atoms, gets the local one. For atom with mind, gets the mind one.
/atom/movable/proc/get_language_holder(get_minds = TRUE)
	if(!language_holder)
		language_holder = new initial_language_holder(src)
	return language_holder

/// Grants the supplied language and sets omnitongue true.
/atom/movable/proc/grant_language(language, understood = TRUE, spoken = TRUE, source = LANGUAGE_ATOM)
	var/datum/language_holder/LH = get_language_holder()
	return LH.grant_language(language, understood, spoken, source)

/// Grants every language.
/atom/movable/proc/grant_all_languages(understood = TRUE, spoken = TRUE, grant_omnitongue = TRUE, source = LANGUAGE_MIND)
	var/datum/language_holder/LH = get_language_holder()
	return LH.grant_all_languages(understood, spoken, grant_omnitongue, source)

/// Removes a single language.
/atom/movable/proc/remove_language(language, understood = TRUE, spoken = TRUE, source = LANGUAGE_ALL)
	var/datum/language_holder/LH = get_language_holder()
	return LH.remove_language(language, understood, spoken, source)

/// Removes every language and sets omnitongue false.
/atom/movable/proc/remove_all_languages(source = LANGUAGE_ALL, remove_omnitongue = FALSE)
	var/datum/language_holder/LH = get_language_holder()
	return LH.remove_all_languages(source, remove_omnitongue)

/// Adds a language to the blocked language list. Use this over remove_language in cases where you will give languages back later.
/atom/movable/proc/add_blocked_language(language, source = LANGUAGE_ATOM)
	var/datum/language_holder/LH = get_language_holder()
	return LH.add_blocked_language(language, source)

/// Removes a language from the blocked language list.
/atom/movable/proc/remove_blocked_language(language, source = LANGUAGE_ATOM)
	var/datum/language_holder/LH = get_language_holder()
	return LH.remove_blocked_language(language, source)

/// Checks if atom has the language. If spoken is true, only checks if atom can speak the language.
/atom/movable/proc/has_language(language, spoken = FALSE)
	var/datum/language_holder/LH = get_language_holder()
	return LH.has_language(language, spoken)

/// Checks if atom can speak the language.
/atom/movable/proc/can_speak_language(language)
	var/datum/language_holder/LH = get_language_holder()
	return LH.can_speak_language(language)

/// Returns the result of tongue specific limitations on spoken languages.
/atom/movable/proc/could_speak_language(language)
	return TRUE

/// Returns selected language, if it can be spoken, or finds, sets and returns a new selected language if possible.
/atom/movable/proc/get_selected_language()
	var/datum/language_holder/LH = get_language_holder()
	return LH.get_selected_language()

/// Gets a random understood language, useful for hallucinations and such.
/atom/movable/proc/get_random_understood_language()
	var/datum/language_holder/LH = get_language_holder()
	return LH.get_random_understood_language()

/// Gets a random spoken language, useful for forced speech and such.
/atom/movable/proc/get_random_spoken_language()
	var/datum/language_holder/LH = get_language_holder()
	return LH.get_random_spoken_language()

/// Copies all languages into the supplied atom/language holder. Source should be overridden when you
/// do not want the language overwritten by later atom updates or want to avoid blocked languages.
/atom/movable/proc/copy_languages(from_holder, source_override)
	if(isatom(from_holder))
		var/atom/movable/thing = from_holder
		from_holder = thing.get_language_holder()
	var/datum/language_holder/LH = get_language_holder()
	return LH.copy_languages(from_holder, source_override)

/// Empties out the atom specific languages and updates them according to the current atoms language holder.
/// As a side effect, it also creates missing language holders in the process.
/atom/movable/proc/update_atom_languages()
	var/datum/language_holder/LH = get_language_holder()
	return LH.update_atom_languages(src)

/* End language procs */


/atom/movable/proc/ConveyorMove(movedir)
	set waitfor = FALSE
	if(!anchored && has_gravity())
		var/old_dir = dir
		walk_for(src, movedir, 0, 7, until=1 SECONDS)
		dir = old_dir
		stoplag()

/atom/movable/drop_location()
	return list(get_turf(src), step_x, step_y)

//Returns an atom's power cell, if it has one. Overload for individual items.
/atom/movable/proc/get_cell()
	return

/atom/movable/proc/can_be_pulled(user, grab_state, force)
	if(src == user || !isturf(loc))
		return FALSE
	if(anchored || throwing)
		return FALSE
	if(force < (move_resist * MOVE_FORCE_PULL_RATIO))
		return FALSE
	return TRUE

/**
  * Updates the grab state of the movable
  *
  * This exists to act as a hook for behaviour
  */
/atom/movable/proc/setGrabState(newstate)
	grab_state = newstate

/obj/item/proc/do_pickup_animation(atom/target)
	set waitfor = FALSE
	if(!istype(loc, /turf))
		return
	var/stepx = 0
	var/stepy = 0
	if(ismovable(target))
		var/atom/movable/AM = target
		stepx = AM.step_x
		stepy = AM.step_y
	var/image/I = image(icon = src, loc = loc, layer = layer + 0.1)
	I.plane = GAME_PLANE
	I.transform *= 0.75
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	var/turf/T = get_turf(src)
	var/direction
	var/to_x = 0
	var/to_y = 0

	if(!QDELETED(T) && !QDELETED(target))
		direction = get_dir(T, target)
	if(direction & NORTH)
		to_y = 32 + stepy
	else if(direction & SOUTH)
		to_y = -32 - stepy
	if(direction & EAST)
		to_x = 32 + stepx
	else if(direction & WEST)
		to_x = -32 - stepx
	if(!direction)
		if(!(stepx || stepy))
			to_y = 8
		else
			to_x = stepx
			to_y = stepy
	flick_overlay(I, GLOB.clients, 6)
	var/matrix/M = new
	M.Turn(pick(-30, 30))
	animate(I, alpha = 175, pixel_x = to_x, pixel_y = to_y, time = 3, transform = M, easing = CUBIC_EASING)
	sleep(1)
	animate(I, alpha = 0, transform = matrix(), time = 1)
