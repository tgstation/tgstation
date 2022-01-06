/atom/movable
	layer = OBJ_LAYER
	glide_size = 8
	appearance_flags = TILE_BOUND|PIXEL_SCALE

	///how many times a this movable had movement procs called on it since Moved() was last called
	var/move_stacks = 0
	var/last_move = null
	var/last_move_time = 0
	var/anchored = FALSE
	var/move_resist = MOVE_RESIST_DEFAULT
	var/move_force = MOVE_FORCE_DEFAULT
	var/pull_force = PULL_FORCE_DEFAULT
	var/datum/thrownthing/throwing = null
	var/throw_speed = 2 //How many tiles to move per ds when being thrown. Float values are fully supported
	var/throw_range = 7
	///Max range this atom can be thrown via telekinesis
	var/tk_throw_range = 10
	var/mob/pulledby = null
	var/initial_language_holder = /datum/language_holder
	var/datum/language_holder/language_holder // Mindless mobs and objects need language too, some times. Mind holder takes prescedence.
	var/verb_say = "says"
	var/verb_ask = "asks"
	var/verb_exclaim = "exclaims"
	var/verb_whisper = "whispers"
	var/verb_sing = "sings"
	var/verb_yell = "yells"
	var/speech_span
	var/inertia_dir = 0
	var/atom/inertia_last_loc
	var/inertia_moving = 0
	var/inertia_next_move = 0
	var/inertia_move_delay = 5
	/// Things we can pass through while moving. If any of this matches the thing we're trying to pass's [pass_flags_self], then we can pass through.
	var/pass_flags = NONE
	/// If false makes [CanPass][/atom/proc/CanPass] call [CanPassThrough][/atom/movable/proc/CanPassThrough] on this type instead of using default behaviour
	var/generic_canpass = TRUE
	///if FALSE this movable has special rules for blocking/allowing other movables onto the same turf so CanAllowThrough() gets called.
	///in this case the movable gets added to a bumpable_contents list on the turf when entering it. density also adds this movable to that list.
	///if TRUE this movable has the normal rules for blocking, so
	var/generic_can_allow_through = TRUE
	///0: not doing a diagonal move. 1 and 2: doing the first/second step of the diagonal move
	var/moving_diagonally = 0
	///attempt to resume grab after moving instead of before.
	var/atom/movable/moving_from_pull
	var/list/client_mobs_in_contents // This contains all the client mobs within this container
	var/datum/forced_movement/force_moving = null //handled soley by forced_movement.dm
	/**
	 * an associative lazylist of relevant nested contents by "channel", the list is of the form: list(channel = list(important nested contents of that type))
	 * each channel has a specific purpose and is meant to replace potentially expensive nested contents iteration
	 * do NOT add channels to this for little reason as it can add considerable memory usage.
	 */
	var/list/important_recursive_contents

	/**
	  * In case you have multiple types, you automatically use the most useful one.
	  * IE: Skating on ice, flippers on water, flying over chasm/space, etc.
	  * I reccomend you use the movetype_handler system and not modify this directly, especially for living mobs.
	  */
	var/movement_type = GROUND

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

	///Used for the calculate_adjacencies proc for icon smoothing.
	var/can_be_unanchored = FALSE

	///Lazylist to keep track on the sources of illumination.
	var/list/affected_dynamic_lights
	///Highest-intensity light affecting us, which determines our visibility.
	var/affecting_dynamic_lumi = 0

	/// Whether this atom should have its dir automatically changed when it moves. Setting this to FALSE allows for things such as directional windows to retain dir on moving without snowflake code all of the place.
	var/set_dir_on_move = TRUE

	/// The degree of thermal insulation that mobs in list/contents have from the external environment, between 0 and 1
	var/contents_thermal_insulation = 0
	/// The degree of pressure protection that mobs in list/contents have from the external environment, between 0 and 1
	var/contents_pressure_protection = 0


/atom/movable/Initialize(mapload)
	. = ..()
	switch(blocks_emissive)
		if(EMISSIVE_BLOCK_GENERIC)
			var/mutable_appearance/gen_emissive_blocker = mutable_appearance(icon, icon_state, plane = EMISSIVE_PLANE, alpha = src.alpha)
			gen_emissive_blocker.color = GLOB.em_block_color
			gen_emissive_blocker.dir = dir
			gen_emissive_blocker.appearance_flags |= appearance_flags
			add_overlay(list(gen_emissive_blocker))
		if(EMISSIVE_BLOCK_UNIQUE)
			render_target = ref(src)
			em_block = new(src, render_target)
			add_overlay(list(em_block))
	if(opacity)
		AddElement(/datum/element/light_blocking)
	switch(light_system)
		if(MOVABLE_LIGHT)
			AddComponent(/datum/component/overlay_lighting)
		if(MOVABLE_LIGHT_DIRECTIONAL)
			AddComponent(/datum/component/overlay_lighting, is_directional = TRUE)


/atom/movable/Destroy(force)
	QDEL_NULL(proximity_monitor)
	QDEL_NULL(language_holder)
	QDEL_NULL(em_block)

	unbuckle_all_mobs(force = TRUE)

	if(loc)
		//Restore air flow if we were blocking it (movables with ATMOS_PASS_PROC will need to do this manually if necessary)
		if(((CanAtmosPass == ATMOS_PASS_DENSITY && density) || CanAtmosPass == ATMOS_PASS_NO) && isturf(loc))
			CanAtmosPass = ATMOS_PASS_YES
			air_update_turf(TRUE, FALSE)
		loc.handle_atom_del(src)

	if(opacity)
		RemoveElement(/datum/element/light_blocking)

	invisibility = INVISIBILITY_ABSTRACT

	if(pulledby)
		pulledby.stop_pulling()
	if(pulling)
		stop_pulling()

	if(orbiting)
		orbiting.end_orbit(src)
		orbiting = null

	. = ..()

	for(var/movable_content in contents)
		qdel(movable_content)

	LAZYCLEARLIST(client_mobs_in_contents)

	moveToNullspace()

	//We add ourselves to this list, best to clear it out
	//DO it after moveToNullspace so memes can be had
	LAZYCLEARLIST(important_recursive_contents)

	vis_locs = null //clears this atom out of all viscontents
	vis_contents.Cut()

/atom/movable/proc/update_emissive_block()
	if(!blocks_emissive)
		return
	else if (blocks_emissive == EMISSIVE_BLOCK_GENERIC)
		var/mutable_appearance/gen_emissive_blocker = emissive_blocker(icon, icon_state, alpha = src.alpha, appearance_flags = src.appearance_flags)
		gen_emissive_blocker.dir = dir
		return gen_emissive_blocker
	else if(blocks_emissive == EMISSIVE_BLOCK_UNIQUE)
		if(!em_block && !QDELETED(src))
			render_target = ref(src)
			em_block = new(src, render_target)
		return em_block

/atom/movable/update_overlays()
	. = ..()
	var/emissive_block = update_emissive_block()
	if(emissive_block)
		. += emissive_block

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

/atom/movable/proc/onZImpact(turf/impacted_turf, levels)
	var/atom/highest = impacted_turf
	for(var/atom/hurt_atom as anything in impacted_turf.contents)
		if(!hurt_atom.density)
			continue
		if(isobj(hurt_atom) || ismob(hurt_atom))
			if(hurt_atom.layer > highest.layer)
				highest = hurt_atom
	INVOKE_ASYNC(src, .proc/SpinAnimation, 5, 2)
	return TRUE

//For physical constraints to travelling up/down.
/atom/movable/proc/can_zTravel(turf/destination, direction)
	var/turf/current_turf = get_turf(src)
	if(!current_turf)
		return FALSE
	if(!direction)
		if(!destination)
			return FALSE
		direction = get_dir(current_turf, destination)
	if(direction != UP && direction != DOWN)
		return FALSE
	if(!destination)
		destination = get_step_multiz(src, direction)
		if(!destination)
			return FALSE
	return current_turf.zPassOut(src, direction, destination) && destination.zPassIn(src, direction, current_turf)


/atom/movable/vv_edit_var(var_name, var_value)
	var/static/list/banned_edits = list("step_x" = TRUE, "step_y" = TRUE, "step_size" = TRUE, "bounds" = TRUE)
	var/static/list/careful_edits = list("bound_x" = TRUE, "bound_y" = TRUE, "bound_width" = TRUE, "bound_height" = TRUE)
	if(banned_edits[var_name])
		return FALSE //PLEASE no.
	if((careful_edits[var_name]) && (var_value % world.icon_size) != 0)
		return FALSE

	switch(var_name)
		if(NAMEOF(src, x))
			var/turf/current_turf = locate(var_value, y, z)
			if(current_turf)
				admin_teleport(current_turf)
				return TRUE
			return FALSE
		if(NAMEOF(src, y))
			var/turf/T = locate(x, var_value, z)
			if(T)
				admin_teleport(T)
				return TRUE
			return FALSE
		if(NAMEOF(src, z))
			var/turf/T = locate(x, y, var_value)
			if(T)
				admin_teleport(T)
				return TRUE
			return FALSE
		if(NAMEOF(src, loc))
			if(isatom(var_value) || isnull(var_value))
				admin_teleport(var_value)
				return TRUE
			return FALSE
		if(NAMEOF(src, anchored))
			set_anchored(var_value)
			. = TRUE
		if(NAMEOF(src, pulledby))
			set_pulledby(var_value)
			. = TRUE
		if(NAMEOF(src, glide_size))
			set_glide_size(var_value)
			. = TRUE

	if(!isnull(.))
		datum_flags |= DF_VAR_EDITED
		return

	return ..()


/atom/movable/proc/start_pulling(atom/movable/pulled_atom, state, force = move_force, supress_message = FALSE)
	if(QDELETED(pulled_atom))
		return FALSE
	if(!(pulled_atom.can_be_pulled(src, state, force)))
		return FALSE

	// If we're pulling something then drop what we're currently pulling and pull this instead.
	if(pulling)
		if(state == 0)
			stop_pulling()
			return FALSE
		// Are we trying to pull something we are already pulling? Then enter grab cycle and end.
		if(pulled_atom == pulling)
			setGrabState(state)
			if(istype(pulled_atom,/mob/living))
				var/mob/living/pulled_mob = pulled_atom
				pulled_mob.grabbedby(src)
			return TRUE
		stop_pulling()

	SEND_SIGNAL(src, COMSIG_ATOM_START_PULL, pulled_atom, state, force)

	if(pulled_atom.pulledby)
		log_combat(pulled_atom, pulled_atom.pulledby, "pulled from", src)
		pulled_atom.pulledby.stop_pulling() //an object can't be pulled by two mobs at once.
	pulling = pulled_atom
	pulled_atom.set_pulledby(src)
	setGrabState(state)
	if(ismob(pulled_atom))
		var/mob/pulled_mob = pulled_atom
		log_combat(src, pulled_mob, "grabbed", addition="passive grab")
		if(!supress_message)
			pulled_mob.visible_message(span_warning("[src] grabs [pulled_mob] passively."), \
				span_danger("[src] grabs you passively."))
	return TRUE

/atom/movable/proc/stop_pulling()
	if(pulling)
		SEND_SIGNAL(pulling, COMSIG_ATOM_NO_LONGER_PULLED, src)
		pulling.set_pulledby(null)
		setGrabState(GRAB_PASSIVE)
		pulling = null


///Reports the event of the change in value of the pulledby variable.
/atom/movable/proc/set_pulledby(new_pulledby)
	if(new_pulledby == pulledby)
		return FALSE //null signals there was a change, be sure to return FALSE if none happened here.
	. = pulledby
	pulledby = new_pulledby


/atom/movable/proc/Move_Pulled(atom/moving_atom)
	if(!pulling)
		return FALSE
	if(pulling.anchored || pulling.move_resist > move_force || !pulling.Adjacent(src, src, pulling))
		stop_pulling()
		return FALSE
	if(isliving(pulling))
		var/mob/living/pulling_mob = pulling
		if(pulling_mob.buckled && pulling_mob.buckled.buckle_prevents_pull) //if they're buckled to something that disallows pulling, prevent it
			stop_pulling()
			return FALSE
	if(moving_atom == loc && pulling.density)
		return FALSE
	var/move_dir = get_dir(pulling.loc, moving_atom)
	if(!Process_Spacemove(move_dir))
		return FALSE
	pulling.Move(get_step(pulling.loc, move_dir), move_dir, glide_size)
	return TRUE

/mob/living/Move_Pulled(atom/moving_atom)
	. = ..()
	if(!. || !isliving(moving_atom))
		return
	var/mob/living/pulled_mob = moving_atom
	set_pull_offsets(pulled_mob, grab_state)

/atom/movable/proc/check_pulling()
	if(pulling)
		var/atom/movable/pullee = pulling
		if(pullee && get_dist(src, pullee) > 1)
			stop_pulling()
			return
		if(!isturf(loc))
			stop_pulling()
			return
		if(pullee && !isturf(pullee.loc) && pullee.loc != loc) //to be removed once all code that changes an object's loc uses forceMove().
			log_game("DEBUG:[src]'s pull on [pullee] wasn't broken despite [pullee] being in [pullee.loc]. Pull stopped manually.")
			stop_pulling()
			return
		if(pulling.anchored || pulling.move_resist > move_force)
			stop_pulling()
			return
	if(pulledby && moving_diagonally != FIRST_DIAG_STEP && get_dist(src, pulledby) > 1) //separated from our puller and not in the middle of a diagonal move.
		pulledby.stop_pulling()


/atom/movable/proc/set_glide_size(target = 8)
	SEND_SIGNAL(src, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, target)
	glide_size = target

	for(var/m in buckled_mobs)
		var/mob/buckled_mob = m
		buckled_mob.set_glide_size(target)

/**
 * meant for movement with zero side effects. only use for objects that are supposed to move "invisibly" (like camera mobs or ghosts)
 * if you want something to move onto a tile with a beartrap or recycler or tripmine or mouse without that object knowing about it at all, use this
 * most of the time you want forceMove()
 */
/atom/movable/proc/abstract_move(atom/new_loc)
	var/atom/old_loc = loc
	move_stacks++
	loc = new_loc
	Moved(old_loc)

////////////////////////////////////////
// Here's where we rewrite how byond handles movement except slightly different
// To be removed on step_ conversion
// All this work to prevent a second bump
/atom/movable/Move(atom/newloc, direction, glide_size_override = 0)
	. = FALSE
	if(!newloc || newloc == loc)
		return

	if(!direction)
		direction = get_dir(src, newloc)

	if(set_dir_on_move)
		setDir(direction)

	var/is_multi_tile_object = bound_width > 32 || bound_height > 32

	var/list/old_locs
	if(is_multi_tile_object && isturf(loc))
		old_locs = locs // locs is a special list, this is effectively the same as .Copy() but with less steps
		for(var/atom/exiting_loc as anything in old_locs)
			if(!exiting_loc.Exit(src, direction))
				return
	else
		if(!loc.Exit(src, direction))
			return

	var/list/new_locs
	if(is_multi_tile_object && isturf(newloc))
		new_locs = block(
			newloc,
			locate(
				min(world.maxx, newloc.x + CEILING(bound_width / 32, 1)),
				min(world.maxy, newloc.y + CEILING(bound_height / 32, 1)),
				newloc.z
				)
		) // If this is a multi-tile object then we need to predict the new locs and check if they allow our entrance.
		for(var/atom/entering_loc as anything in new_locs)
			if(!entering_loc.Enter(src))
				return
			if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, entering_loc) & COMPONENT_MOVABLE_BLOCK_PRE_MOVE)
				return
	else // Else just try to enter the single destination.
		if(!newloc.Enter(src))
			return
		if(SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, newloc) & COMPONENT_MOVABLE_BLOCK_PRE_MOVE)
			return

	// Past this is the point of no return
	var/atom/oldloc = loc
	var/area/oldarea = get_area(oldloc)
	var/area/newarea = get_area(newloc)
	move_stacks++

	loc = newloc

	. = TRUE

	if(old_locs) // This condition will only be true if it is a multi-tile object.
		for(var/atom/exited_loc as anything in (old_locs - new_locs))
			exited_loc.Exited(src, direction)
	else // Else there's just one loc to be exited.
		oldloc.Exited(src, direction)
	if(oldarea != newarea)
		oldarea.Exited(src, direction)

	if(new_locs) // Same here, only if multi-tile.
		for(var/atom/entered_loc as anything in (new_locs - old_locs))
			entered_loc.Entered(src, oldloc, old_locs)
	else
		newloc.Entered(src, oldloc, old_locs)
	if(oldarea != newarea)
		newarea.Entered(src, oldarea)

	Moved(oldloc, direction, FALSE, old_locs)

////////////////////////////////////////

/atom/movable/Move(atom/newloc, direct, glide_size_override = 0)
	var/atom/movable/pullee = pulling
	var/turf/current_turf = loc
	if(!moving_from_pull)
		check_pulling()
	if(!loc || !newloc)
		return FALSE
	var/atom/oldloc = loc
	//Early override for some cases like diagonal movement
	if(glide_size_override)
		set_glide_size(glide_size_override)

	if(loc != newloc)
		if (!(direct & (direct - 1))) //Cardinal move
			. = ..()
		else //Diagonal move, split it into cardinal moves
			moving_diagonally = FIRST_DIAG_STEP
			var/first_step_dir
			// The `&& moving_diagonally` checks are so that a forceMove taking
			// place due to a Crossed, Bumped, etc. call will interrupt
			// the second half of the diagonal movement, or the second attempt
			// at a first half if step() fails because we hit something.
			if (direct & NORTH)
				if (direct & EAST)
					if (step(src, NORTH) && moving_diagonally)
						first_step_dir = NORTH
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, EAST)
					else if (moving_diagonally && step(src, EAST))
						first_step_dir = EAST
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, NORTH)
				else if (direct & WEST)
					if (step(src, NORTH) && moving_diagonally)
						first_step_dir = NORTH
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, WEST)
					else if (moving_diagonally && step(src, WEST))
						first_step_dir = WEST
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, NORTH)
			else if (direct & SOUTH)
				if (direct & EAST)
					if (step(src, SOUTH) && moving_diagonally)
						first_step_dir = SOUTH
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, EAST)
					else if (moving_diagonally && step(src, EAST))
						first_step_dir = EAST
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, SOUTH)
				else if (direct & WEST)
					if (step(src, SOUTH) && moving_diagonally)
						first_step_dir = SOUTH
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, WEST)
					else if (moving_diagonally && step(src, WEST))
						first_step_dir = WEST
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, SOUTH)
			if(moving_diagonally == SECOND_DIAG_STEP)
				if(!. && set_dir_on_move)
					setDir(first_step_dir)
				else if (!inertia_moving)
					inertia_next_move = world.time + inertia_move_delay
					newtonian_move(direct)
			moving_diagonally = 0
			return

	if(!loc || (loc == oldloc && oldloc != newloc))
		last_move = 0
		return

	if(. && pulling && pulling == pullee && pulling != moving_from_pull) //we were pulling a thing and didn't lose it during our move.
		if(pulling.anchored)
			stop_pulling()
		else
			var/pull_dir = get_dir(src, pulling)
			//puller and pullee more than one tile away or in diagonal position and whatever the pullee is pulling isn't already moving from a pull as it'll most likely result in an infinite loop a la ouroborus.
			if(!pulling.pulling?.moving_from_pull && (get_dist(src, pulling) > 1 || (moving_diagonally != SECOND_DIAG_STEP && ((pull_dir - 1) & pull_dir))))
				pulling.moving_from_pull = src
				pulling.Move(current_turf, get_dir(pulling, current_turf), glide_size) //the pullee tries to reach our previous position
				pulling.moving_from_pull = null
			check_pulling()


	//glide_size strangely enough can change mid movement animation and update correctly while the animation is playing
	//This means that if you don't override it late like this, it will just be set back by the movement update that's called when you move turfs.
	if(glide_size_override)
		set_glide_size(glide_size_override)

	last_move = direct

	if(set_dir_on_move)
		setDir(direct)
	if(. && has_buckled_mobs() && !handle_buckled_mob_movement(loc, direct, glide_size_override)) //movement failed due to buckled mob(s)
		return FALSE


/**
 * Called after a successful Move(). By this point, we've already moved.
 * Arguments:
 * * old_loc is the location prior to the move. Can be null to indicate nullspace.
 * * movement_dir is the direction the movement took place. Can be NONE if it was some sort of teleport.
 * * The forced flag indicates whether this was a forced move, which skips many checks of regular movement.
 * * The old_locs is an optional argument, in case the moved movable was present in multiple locations before the movement.
 **/
/atom/movable/proc/Moved(atom/old_loc, movement_dir, forced = FALSE, list/old_locs)
	SHOULD_CALL_PARENT(TRUE)

	if (!inertia_moving)
		inertia_next_move = world.time + inertia_move_delay
		newtonian_move(movement_dir)
	if (length(client_mobs_in_contents))
		update_parallax_contents()

	for(var/datum/light_source/light as anything in light_sources)
		light.source_atom.update_light()

	move_stacks--
	if(move_stacks > 0) //we want only the first Moved() call in the stack to send this signal, all the other ones have an incorrect old_loc
		return
	if(move_stacks < 0)
		stack_trace("move_stacks is negative in Moved()!")
		move_stacks = 0 //setting it to 0 so that we dont get every movable with negative move_stacks runtiming on every movement

	SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, old_loc, movement_dir, forced, old_locs)

	var/turf/old_turf = get_turf(old_loc)
	var/turf/new_turf = get_turf(src)

	if (old_turf?.z != new_turf?.z)
		on_changed_z_level(old_turf, new_turf)

	return TRUE


// Make sure you know what you're doing if you call this, this is intended to only be called by byond directly.
// You probably want CanPass()
///do not call, deprecated in lieu of CanPass()
/atom/movable/Cross(atom/movable/AM)
	SHOULD_NOT_OVERRIDE(TRUE)
	CRASH("/atom/movable/Cross() was called as a deprecated proc! dont do this")

///default byond proc that is deprecated for us in lieu of signals. do not call
/atom/movable/Crossed(atom/movable/crossed_atom, oldloc)
	SHOULD_NOT_OVERRIDE(TRUE)
	CRASH("atom/movable/Crossed() was called!")

/**
 * `Uncross()` is a default BYOND proc that is called when something is *going*
 * to exit this atom's turf. It is prefered over `Uncrossed` when you want to
 * deny that movement, such as in the case of border objects, objects that allow
 * you to walk through them in any direction except the one they block
 * (think side windows).
 *
 * While being seemingly harmless, most everything doesn't actually want to
 * use this, meaning that we are wasting proc calls for every single atom
 * on a turf, every single time something exits it, when basically nothing
 * cares.
 *
 * This overhead caused real problems on Sybil round #159709, where lag
 * attributed to Uncross was so bad that the entire master controller
 * collapsed and people made Among Us lobbies in OOC.
 *
 * If you want to replicate the old `Uncross()` behavior, the most apt
 * replacement is [`/datum/element/connect_loc`] while hooking onto
 * [`COMSIG_ATOM_EXIT`].
 */
/atom/movable/Uncross()
	SHOULD_NOT_OVERRIDE(TRUE)
	CRASH("Uncross() should not be being called, please read the doc-comment for it for why.")

/**
 * default byond proc that is normally called on everything inside the previous turf
 * a movable was in after moving to its current turf
 * this is wasteful since the vast majority of objects do not use Uncrossed
 * use connect_loc to register to COMSIG_ATOM_EXITED instead
 */
/atom/movable/Uncrossed(atom/movable/uncrossed_atom)
	SHOULD_NOT_OVERRIDE(TRUE)
	CRASH("/atom/movable/Uncrossed() was called")

/atom/movable/Bump(atom/obstacle)
	if(!obstacle)
		CRASH("Bump was called with no argument.")
	SEND_SIGNAL(src, COMSIG_MOVABLE_BUMP, obstacle)
	. = ..()
	if(!QDELETED(throwing))
		throwing.finalize(hit = TRUE, target = obstacle)
		. = TRUE
		if(QDELETED(obstacle))
			return
	obstacle.Bumped(src)

/atom/movable/Exited(atom/movable/gone, direction)
	. = ..()

	if(LAZYLEN(gone.important_recursive_contents))
		var/list/nested_locs = get_nested_locs(src) + src
		for(var/channel in gone.important_recursive_contents)
			for(var/atom/movable/location as anything in nested_locs)
				LAZYREMOVEASSOC(location.important_recursive_contents, channel, gone.important_recursive_contents[channel])

/atom/movable/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()

	if(LAZYLEN(arrived.important_recursive_contents))
		var/list/nested_locs = get_nested_locs(src) + src
		for(var/channel in arrived.important_recursive_contents)
			for(var/atom/movable/location as anything in nested_locs)
				LAZYORASSOCLIST(location.important_recursive_contents, channel, arrived.important_recursive_contents[channel])

///allows this movable to hear and adds itself to the important_recursive_contents list of itself and every movable loc its in
/atom/movable/proc/become_hearing_sensitive(trait_source = TRAIT_GENERIC)
	if(!HAS_TRAIT(src, TRAIT_HEARING_SENSITIVE))
		RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_HEARING_SENSITIVE), .proc/on_hearing_sensitive_trait_loss)
		for(var/atom/movable/location as anything in get_nested_locs(src) + src)
			LAZYADDASSOCLIST(location.important_recursive_contents, RECURSIVE_CONTENTS_HEARING_SENSITIVE, src)
	ADD_TRAIT(src, TRAIT_HEARING_SENSITIVE, trait_source)


///allows this movable to know when it has "entered" another area no matter how many movable atoms its stuffed into, uses important_recursive_contents
/atom/movable/proc/become_area_sensitive(trait_source = TRAIT_GENERIC)
	if(!HAS_TRAIT(src, TRAIT_AREA_SENSITIVE))
		RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_AREA_SENSITIVE), .proc/on_area_sensitive_trait_loss)
		for(var/atom/movable/location as anything in get_nested_locs(src) + src)
			LAZYADDASSOCLIST(location.important_recursive_contents, RECURSIVE_CONTENTS_AREA_SENSITIVE, src)
	ADD_TRAIT(src, TRAIT_AREA_SENSITIVE, trait_source)

/atom/movable/proc/on_area_sensitive_trait_loss()
	SIGNAL_HANDLER

	UnregisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_AREA_SENSITIVE))
	for(var/atom/movable/location as anything in get_nested_locs(src) + src)
		LAZYREMOVEASSOC(location.important_recursive_contents, RECURSIVE_CONTENTS_AREA_SENSITIVE, src)

/atom/movable/proc/on_hearing_sensitive_trait_loss()
	SIGNAL_HANDLER

	UnregisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_HEARING_SENSITIVE))
	for(var/atom/movable/location as anything in get_nested_locs(src) + src)
		LAZYREMOVEASSOC(location.important_recursive_contents, RECURSIVE_CONTENTS_HEARING_SENSITIVE, src)

///Sets the anchored var and returns if it was sucessfully changed or not.
/atom/movable/proc/set_anchored(anchorvalue)
	SHOULD_CALL_PARENT(TRUE)
	if(anchored == anchorvalue)
		return
	. = anchored
	anchored = anchorvalue
	SEND_SIGNAL(src, COMSIG_MOVABLE_SET_ANCHORED, anchorvalue)

/atom/movable/proc/forceMove(atom/destination)
	. = FALSE
	if(destination)
		. = doMove(destination)
	else
		CRASH("No valid destination passed into forceMove")

/atom/movable/proc/moveToNullspace()
	return doMove(null)

/atom/movable/proc/doMove(atom/destination)
	. = FALSE
	move_stacks++
	var/atom/oldloc = loc
	if(destination)
		if(pulledby)
			pulledby.stop_pulling()
		var/same_loc = oldloc == destination
		var/area/old_area = get_area(oldloc)
		var/area/destarea = get_area(destination)
		var/movement_dir = get_dir(src, destination)

		moving_diagonally = 0

		loc = destination

		if(!same_loc)
			if(oldloc)
				oldloc.Exited(src, movement_dir)
				if(old_area && old_area != destarea)
					old_area.Exited(src, movement_dir)
			destination.Entered(src, oldloc)
			if(destarea && old_area != destarea)
				destarea.Entered(src, old_area)

		. = TRUE

	//If no destination, move the atom into nullspace (don't do this unless you know what you're doing)
	else
		. = TRUE
		loc = null
		if (oldloc)
			var/area/old_area = get_area(oldloc)
			oldloc.Exited(src, NONE)
			if(old_area)
				old_area.Exited(src, NONE)

	Moved(oldloc, NONE, TRUE)

/**
 * Called when a movable changes z-levels.
 *
 * Arguments:
 * * old_z - The previous z-level they were on before.
 * * notify_contents - Whether or not to notify the movable's contents that their z-level has changed.
 */
/atom/movable/proc/on_changed_z_level(turf/old_turf, turf/new_turf, notify_contents = TRUE)
	SEND_SIGNAL(src, COMSIG_MOVABLE_Z_CHANGED, old_turf, new_turf)

	if(!notify_contents)
		return

	for (var/atom/movable/content as anything in src) // Notify contents of Z-transition.
		content.on_changed_z_level(old_turf, new_turf)

/**
 * Called whenever an object moves and by mobs when they attempt to move themselves through space
 * And when an object or action applies a force on src, see [newtonian_move][/atom/movable/proc/newtonian_move]
 *
 * Return 0 to have src start/keep drifting in a no-grav area and 1 to stop/not start drifting
 *
 * Mobs should return 1 if they should be able to move of their own volition, see [/client/proc/Move]
 *
 * Arguments:
 * * movement_dir - 0 when stopping or any dir when trying to move
 */
/atom/movable/proc/Process_Spacemove(movement_dir = 0)
	if(has_gravity(src))
		return TRUE

	if(pulledby && (pulledby.pulledby != src || moving_from_pull))
		return TRUE

	if(throwing)
		return TRUE

	if(!isturf(loc))
		return TRUE

	if(locate(/obj/structure/lattice) in range(1, get_turf(src))) //Not realistic but makes pushing things in space easier
		return TRUE

	return FALSE


/// Only moves the object if it's under no gravity
/atom/movable/proc/newtonian_move(direction)
	if(!isturf(loc) || Process_Spacemove(0))
		inertia_dir = 0
		return FALSE

	inertia_dir = direction
	if(!direction)
		return TRUE
	inertia_last_loc = loc
	SSspacedrift.processing[src] = src
	return TRUE

/atom/movable/proc/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	set waitfor = FALSE
	var/hitpush = TRUE
	var/impact_signal = SEND_SIGNAL(src, COMSIG_MOVABLE_IMPACT, hit_atom, throwingdatum)
	if(impact_signal & COMPONENT_MOVABLE_IMPACT_FLIP_HITPUSH)
		hitpush = FALSE // hacky, tie this to something else or a proper workaround later

	if(!(impact_signal && (impact_signal & COMPONENT_MOVABLE_IMPACT_NEVERMIND))) // in case a signal interceptor broke or deleted the thing before we could process our hit
		return hit_atom.hitby(src, throwingdatum=throwingdatum, hitpush=hitpush)

/atom/movable/hitby(atom/movable/hitting_atom, skipcatch, hitpush = TRUE, blocked, datum/thrownthing/throwingdatum)
	if(!anchored && hitpush && (!throwingdatum || (throwingdatum.force >= (move_resist * MOVE_FORCE_PUSH_RATIO))))
		step(src, hitting_atom.dir)
	..()

/atom/movable/proc/safe_throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG, gentle = FALSE)
	if((force < (move_resist * MOVE_FORCE_THROW_RATIO)) || (move_resist == INFINITY))
		return
	return throw_at(target, range, speed, thrower, spin, diagonals_first, callback, force, gentle)

///If this returns FALSE then callback will not be called.
/atom/movable/proc/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, force = MOVE_FORCE_STRONG, gentle = FALSE, quickstart = TRUE)
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

	var/datum/thrownthing/thrown_thing = new(src, target, get_dir(src, target), range, speed, thrower, diagonals_first, force, gentle, callback, target_zone)

	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)
	var/dx = (target.x > src.x) ? EAST : WEST
	var/dy = (target.y > src.y) ? NORTH : SOUTH

	if (dist_x == dist_y)
		thrown_thing.pure_diagonal = 1

	else if(dist_x <= dist_y)
		var/olddist_x = dist_x
		var/olddx = dx
		dist_x = dist_y
		dist_y = olddist_x
		dx = dy
		dy = olddx
	thrown_thing.dist_x = dist_x
	thrown_thing.dist_y = dist_y
	thrown_thing.dx = dx
	thrown_thing.dy = dy
	thrown_thing.diagonal_error = dist_x/2 - dist_y
	thrown_thing.start_time = world.time

	if(pulledby)
		pulledby.stop_pulling()
	if (quickstart && (throwing || SSthrowing.state == SS_RUNNING)) //Avoid stack overflow edgecases.
		quickstart = FALSE
	throwing = thrown_thing
	if(spin)
		SpinAnimation(5, 1)

	SEND_SIGNAL(src, COMSIG_MOVABLE_POST_THROW, thrown_thing, spin)
	SSthrowing.processing[src] = thrown_thing
	if (SSthrowing.state == SS_PAUSED && length(SSthrowing.currentrun))
		SSthrowing.currentrun[src] = thrown_thing
	if (quickstart)
		thrown_thing.tick()

/atom/movable/proc/handle_buckled_mob_movement(newloc, direct, glide_size_override)
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		if(!buckled_mob.Move(newloc, direct, glide_size_override))
			Move(buckled_mob.loc, direct)
			last_move = buckled_mob.last_move
			inertia_dir = last_move
			buckled_mob.inertia_dir = last_move
			return FALSE
	return TRUE

/atom/movable/proc/force_pushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return FALSE

/atom/movable/proc/force_push(atom/movable/pushed_atom, force = move_force, direction, silent = FALSE)
	. = pushed_atom.force_pushed(src, force, direction)
	if(!silent && .)
		visible_message(span_warning("[src] forcefully pushes against [pushed_atom]!"), span_warning("You forcefully push against [pushed_atom]!"))

/atom/movable/proc/move_crush(atom/movable/crushed_atom, force = move_force, direction, silent = FALSE)
	. = crushed_atom.move_crushed(src, force, direction)
	if(!silent && .)
		visible_message(span_danger("[src] crushes past [crushed_atom]!"), span_danger("You crush [crushed_atom]!"))

/atom/movable/proc/move_crushed(atom/movable/pusher, force = MOVE_FORCE_DEFAULT, direction)
	return FALSE

/atom/movable/CanAllowThrough(atom/movable/mover, border_dir)//TODOKYLER: this is SHIT
	. = ..()
	if(mover in buckled_mobs)
		return TRUE

/// Returns true or false to allow src to move through the blocker, mover has final say
/atom/movable/proc/CanPassThrough(atom/blocker, movement_dir, blocker_opinion)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_BE_PURE(TRUE)
	return blocker_opinion

/// called when this atom is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/atom/movable/proc/on_exit_storage(datum/component/storage/concrete/master_storage)
	SEND_SIGNAL(src, COMSIG_STORAGE_EXITED, master_storage)

/// called when this atom is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/atom/movable/proc/on_enter_storage(datum/component/storage/concrete/master_storage)
	SEND_SIGNAL(src, COMSIG_STORAGE_ENTERED, master_storage)

/atom/movable/proc/get_spacemove_backup()
	var/atom/movable/dense_object_backup
	for(var/checked_range in orange(1, get_turf(src)))
		if(isarea(checked_range))
			continue
		else if(isturf(checked_range))
			var/turf/turf = checked_range
			if(!turf.density)
				continue
			return turf
		else
			var/atom/movable/checked_atom = checked_range
			if(checked_atom.density || !checked_atom.CanPass(src, get_dir(src, checked_atom)))
				if(checked_atom.anchored)
					return checked_atom
				dense_object_backup = checked_atom
				break
	. = dense_object_backup

///called when a mob resists while inside a container that is itself inside something.
/atom/movable/proc/relay_container_resist_act(mob/living/user, obj/container)
	return


/atom/movable/proc/do_attack_animation(atom/attacked_atom, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect && (visual_effect_icon || used_item))
		do_item_attack_animation(attacked_atom, visual_effect_icon, used_item)

	if(attacked_atom == src)
		return //don't do an animation if attacking self
	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/turn_dir = 1

	var/direction = get_dir(src, attacked_atom)
	if(direction & NORTH)
		pixel_y_diff = 8
		turn_dir = prob(50) ? -1 : 1
	else if(direction & SOUTH)
		pixel_y_diff = -8
		turn_dir = prob(50) ? -1 : 1

	if(direction & EAST)
		pixel_x_diff = 8
	else if(direction & WEST)
		pixel_x_diff = -8
		turn_dir = -1

	var/matrix/initial_transform = matrix(transform)
	var/matrix/rotated_transform = transform.Turn(15 * turn_dir)
	animate(src, pixel_x = pixel_x + pixel_x_diff, pixel_y = pixel_y + pixel_y_diff, transform=rotated_transform, time = 1, easing=BACK_EASING|EASE_IN, flags = ANIMATION_PARALLEL)
	animate(pixel_x = pixel_x - pixel_x_diff, pixel_y = pixel_y - pixel_y_diff, transform=initial_transform, time = 2, easing=SINE_EASING, flags = ANIMATION_PARALLEL)

/atom/movable/proc/do_item_attack_animation(atom/attacked_atom, visual_effect_icon, obj/item/used_item)
	var/image/attack_image
	if(visual_effect_icon)
		attack_image = image('icons/effects/effects.dmi', attacked_atom, visual_effect_icon, attacked_atom.layer + 0.1)
	else if(used_item)
		attack_image = image(icon = used_item, loc = attacked_atom, layer = attacked_atom.layer + 0.1)
		attack_image.plane = GAME_PLANE

		// Scale the icon.
		attack_image.transform *= 0.4
		// The icon should not rotate.
		attack_image.appearance_flags = APPEARANCE_UI

		// Set the direction of the icon animation.
		var/direction = get_dir(src, attacked_atom)
		if(direction & NORTH)
			attack_image.pixel_y = -12
		else if(direction & SOUTH)
			attack_image.pixel_y = 12

		if(direction & EAST)
			attack_image.pixel_x = -14
		else if(direction & WEST)
			attack_image.pixel_x = 14

		if(!direction) // Attacked self?!
			attack_image.pixel_z = 16

	if(!attack_image)
		return

	flick_overlay(attack_image, GLOB.clients, 10)

	// And animate the attack!
	animate(attack_image, alpha = 175, transform = matrix() * 0.75, pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 3)
	animate(time = 1)
	animate(alpha = 0, time = 3, easing = CIRCULAR_EASING|EASE_OUT)

/atom/movable/vv_get_dropdown()
	. = ..()
	. += "<option value='?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(src)]'>Follow</option>"
	. += "<option value='?_src_=holder;[HrefToken()];admingetmovable=[REF(src)]'>Get</option>"


/* Language procs
* Unless you are doing something very specific, these are the ones you want to use.
*/

/// Gets or creates the relevant language holder. For mindless atoms, gets the local one. For atom with mind, gets the mind one.
/atom/movable/proc/get_language_holder(get_minds = TRUE)
	if(!language_holder)
		language_holder = new initial_language_holder(src)
	return language_holder

/// Grants the supplied language and sets omnitongue true.
/atom/movable/proc/grant_language(language, understood = TRUE, spoken = TRUE, source = LANGUAGE_ATOM)
	var/datum/language_holder/language_holder = get_language_holder()
	return language_holder.grant_language(language, understood, spoken, source)

/// Grants every language.
/atom/movable/proc/grant_all_languages(understood = TRUE, spoken = TRUE, grant_omnitongue = TRUE, source = LANGUAGE_MIND)
	var/datum/language_holder/language_holder = get_language_holder()
	return language_holder.grant_all_languages(understood, spoken, grant_omnitongue, source)

/// Removes a single language.
/atom/movable/proc/remove_language(language, understood = TRUE, spoken = TRUE, source = LANGUAGE_ALL)
	var/datum/language_holder/language_holder = get_language_holder()
	return language_holder.remove_language(language, understood, spoken, source)

/// Removes every language and sets omnitongue false.
/atom/movable/proc/remove_all_languages(source = LANGUAGE_ALL, remove_omnitongue = FALSE)
	var/datum/language_holder/language_holder = get_language_holder()
	return language_holder.remove_all_languages(source, remove_omnitongue)

/// Adds a language to the blocked language list. Use this over remove_language in cases where you will give languages back later.
/atom/movable/proc/add_blocked_language(language, source = LANGUAGE_ATOM)
	var/datum/language_holder/language_holder = get_language_holder()
	return language_holder.add_blocked_language(language, source)

/// Removes a language from the blocked language list.
/atom/movable/proc/remove_blocked_language(language, source = LANGUAGE_ATOM)
	var/datum/language_holder/language_holder = get_language_holder()
	return language_holder.remove_blocked_language(language, source)

/// Checks if atom has the language. If spoken is true, only checks if atom can speak the language.
/atom/movable/proc/has_language(language, spoken = FALSE)
	var/datum/language_holder/language_holder = get_language_holder()
	return language_holder.has_language(language, spoken)

/// Checks if atom can speak the language.
/atom/movable/proc/can_speak_language(language)
	var/datum/language_holder/language_holder = get_language_holder()
	return language_holder.can_speak_language(language)

/// Returns the result of tongue specific limitations on spoken languages.
/atom/movable/proc/could_speak_language(language)
	return TRUE

/// Returns selected language, if it can be spoken, or finds, sets and returns a new selected language if possible.
/atom/movable/proc/get_selected_language()
	var/datum/language_holder/language_holder = get_language_holder()
	return language_holder.get_selected_language()

/// Gets a random understood language, useful for hallucinations and such.
/atom/movable/proc/get_random_understood_language()
	var/datum/language_holder/language_holder = get_language_holder()
	return language_holder.get_random_understood_language()

/// Gets a random spoken language, useful for forced speech and such.
/atom/movable/proc/get_random_spoken_language()
	var/datum/language_holder/language_holder = get_language_holder()
	return language_holder.get_random_spoken_language()

/// Copies all languages into the supplied atom/language holder. Source should be overridden when you
/// do not want the language overwritten by later atom updates or want to avoid blocked languages.
/atom/movable/proc/copy_languages(from_holder, source_override)
	if(isatom(from_holder))
		var/atom/movable/thing = from_holder
		from_holder = thing.get_language_holder()
	var/datum/language_holder/language_holder = get_language_holder()
	return language_holder.copy_languages(from_holder, source_override)

/// Empties out the atom specific languages and updates them according to the current atoms language holder.
/// As a side effect, it also creates missing language holders in the process.
/atom/movable/proc/update_atom_languages()
	var/datum/language_holder/language_holder = get_language_holder()
	return language_holder.update_atom_languages(src)

/* End language procs */

//Returns an atom's power cell, if it has one. Overload for individual items.
/atom/movable/proc/get_cell()
	return

/atom/movable/proc/can_be_pulled(user, grab_state, force)
	if(src == user || !isturf(loc))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_ATOM_CAN_BE_PULLED, user) & COMSIG_ATOM_CANT_PULL)
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
	if(newstate == grab_state)
		return
	SEND_SIGNAL(src, COMSIG_MOVABLE_SET_GRAB_STATE, newstate)
	. = grab_state
	grab_state = newstate
	switch(grab_state) // Current state.
		if(GRAB_PASSIVE)
			REMOVE_TRAIT(pulling, TRAIT_IMMOBILIZED, CHOKEHOLD_TRAIT)
			REMOVE_TRAIT(pulling, TRAIT_HANDS_BLOCKED, CHOKEHOLD_TRAIT)
			if(. >= GRAB_NECK) // Previous state was a a neck-grab or higher.
				REMOVE_TRAIT(pulling, TRAIT_FLOORED, CHOKEHOLD_TRAIT)
		if(GRAB_AGGRESSIVE)
			if(. >= GRAB_NECK) // Grab got downgraded.
				REMOVE_TRAIT(pulling, TRAIT_FLOORED, CHOKEHOLD_TRAIT)
			else // Grab got upgraded from a passive one.
				ADD_TRAIT(pulling, TRAIT_IMMOBILIZED, CHOKEHOLD_TRAIT)
				ADD_TRAIT(pulling, TRAIT_HANDS_BLOCKED, CHOKEHOLD_TRAIT)
		if(GRAB_NECK, GRAB_KILL)
			if(. <= GRAB_AGGRESSIVE)
				ADD_TRAIT(pulling, TRAIT_FLOORED, CHOKEHOLD_TRAIT)

/**
 * Adds the deadchat_plays component to this atom with simple movement commands.
 *
 * Returns the component added.
 * Arguments:
 * * mode - Either ANARCHY_MODE or DEMOCRACY_MODE passed to the deadchat_control component. See [/datum/component/deadchat_control] for more info.
 * * cooldown - The cooldown between command inputs passed to the deadchat_control component. See [/datum/component/deadchat_control] for more info.
 */
/atom/movable/proc/deadchat_plays(mode = ANARCHY_MODE, cooldown = 12 SECONDS)
	return AddComponent(/datum/component/deadchat_control/cardinal_movement, mode, list(), cooldown)

/atom/movable/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION(VV_HK_DEADCHAT_PLAYS, "Start/Stop Deadchat Plays")
	VV_DROPDOWN_OPTION(VV_HK_ADD_FANTASY_AFFIX, "Add Fantasy Affix")

/atom/movable/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_DEADCHAT_PLAYS] && check_rights(R_FUN))
		if(tgui_alert(usr, "Allow deadchat to control [src] via chat commands?", "Deadchat Plays [src]", list("Allow", "Cancel")) != "Allow")
			return

		// Alert is async, so quick sanity check to make sure we should still be doing this.
		if(QDELETED(src))
			return

		// This should never happen, but if it does it should not be silent.
		if(deadchat_plays() == COMPONENT_INCOMPATIBLE)
			to_chat(usr, span_warning("Deadchat control not compatible with [src]."))
			CRASH("deadchat_control component incompatible with object of type: [type]")

		to_chat(usr, span_notice("Deadchat now control [src]."))
		log_admin("[key_name(usr)] has added deadchat control to [src]")
		message_admins(span_notice("[key_name(usr)] has added deadchat control to [src]"))

/obj/item/proc/do_pickup_animation(atom/target)
	set waitfor = FALSE
	if(!istype(loc, /turf))
		return
	var/image/pickup_animation = image(icon = src, loc = loc, layer = layer + 0.1)
	pickup_animation.plane = GAME_PLANE
	pickup_animation.transform *= 0.75
	pickup_animation.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	var/turf/current_turf = get_turf(src)
	var/direction
	var/to_x = target.base_pixel_x
	var/to_y = target.base_pixel_y

	if(!QDELETED(current_turf) && !QDELETED(target))
		direction = get_dir(current_turf, target)
	if(direction & NORTH)
		to_y += 32
	else if(direction & SOUTH)
		to_y -= 32
	if(direction & EAST)
		to_x += 32
	else if(direction & WEST)
		to_x -= 32
	if(!direction)
		to_y += 16
	flick_overlay(pickup_animation, GLOB.clients, 6)
	var/matrix/animation_matrix = new
	animation_matrix.Turn(pick(-30, 30))
	animate(pickup_animation, alpha = 175, pixel_x = to_x, pixel_y = to_y, time = 3, transform = animation_matrix, easing = CUBIC_EASING)
	sleep(1)
	animate(pickup_animation, alpha = 0, transform = matrix(), time = 1)

/**
* A wrapper for setDir that should only be able to fail by living mobs.
*
* Called from [/atom/movable/proc/keyLoop], this exists to be overwritten by living mobs with a check to see if we're actually alive enough to change directions
*/
/atom/movable/proc/keybind_face_direction(direction)
	setDir(direction)
