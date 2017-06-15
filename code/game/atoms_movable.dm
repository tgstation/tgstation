
#ifndef PIXEL_SCALE
#define PIXEL_SCALE 0
#if DM_VERSION >= 512
#error HEY, PIXEL_SCALE probably exists now, remove this gross ass shim.
#endif
#endif

/atom/movable
	layer = OBJ_LAYER
	var/last_move = null
	var/anchored = 0
	var/datum/thrownthing/throwing = null
	var/throw_speed = 2 //How many tiles to move per ds when being thrown. Float values are fully supported
	var/throw_range = 7
	var/mob/pulledby = null
	var/initial_language_holder = /datum/language_holder
	var/datum/language_holder/language_holder
	var/verb_say = "says"
	var/verb_ask = "asks"
	var/verb_exclaim = "exclaims"
	var/verb_whisper = "whispers"
	var/verb_yell = "yells"
	var/inertia_dir = 0
	var/atom/inertia_last_loc
	var/inertia_moving = 0
	var/inertia_next_move = 0
	var/inertia_move_delay = 5
	var/pass_flags = 0
	var/moving_diagonally = 0 //0: not doing a diagonal move. 1 and 2: doing the first/second step of the diagonal move
	var/list/client_mobs_in_contents // This contains all the client mobs within this container
	var/list/acted_explosions	//for explosion dodging
	glide_size = 8
	appearance_flags = TILE_BOUND|PIXEL_SCALE
	var/datum/forced_movement/force_moving = null	//handled soley by forced_movement.dm
	var/floating = FALSE

/atom/movable/vv_edit_var(var_name, var_value)
	var/static/list/banned_edits = list("step_x", "step_y", "step_size")
	var/static/list/careful_edits = list("bound_x", "bound_y", "bound_width", "bound_height")
	if(var_name in banned_edits)
		return FALSE	//PLEASE no.
	if((var_name in careful_edits) && (var_value % world.icon_size) != 0)
		return FALSE
	switch(var_name)
		if("x")
			var/turf/T = locate(var_value, y, z)
			if(T)
				forceMove(T)
				return TRUE
			return FALSE
		if("y")
			var/turf/T = locate(x, var_value, z)
			if(T)
				forceMove(T)
				return TRUE
			return FALSE
		if("z")
			var/turf/T = locate(x, y, var_value)
			if(T)
				forceMove(T)
				return TRUE
			return FALSE
		if("loc")
			if(var_value == null || istype(var_value, /atom))
				forceMove(var_value)
				return TRUE
			return FALSE
	return ..()

/atom/movable/Move(atom/newloc, direct = 0)
	if(!loc || !newloc) return 0
	var/atom/oldloc = loc

	if(loc != newloc)
		if (!(direct & (direct - 1))) //Cardinal move
			. = ..()
		else //Diagonal move, split it into cardinal moves
			moving_diagonally = FIRST_DIAG_STEP
			if (direct & 1)
				if (direct & 4)
					if (step(src, NORTH))
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, EAST)
					else if (step(src, EAST))
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, NORTH)
				else if (direct & 8)
					if (step(src, NORTH))
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, WEST)
					else if (step(src, WEST))
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, NORTH)
			else if (direct & 2)
				if (direct & 4)
					if (step(src, SOUTH))
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, EAST)
					else if (step(src, EAST))
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, SOUTH)
				else if (direct & 8)
					if (step(src, SOUTH))
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, WEST)
					else if (step(src, WEST))
						moving_diagonally = SECOND_DIAG_STEP
						. = step(src, SOUTH)
			moving_diagonally = 0
			return

	if(!loc || (loc == oldloc && oldloc != newloc))
		last_move = 0
		return

	if(.)
		Moved(oldloc, direct)

	last_move = direct
	setDir(direct)
	if(. && has_buckled_mobs() && !handle_buckled_mob_movement(loc,direct)) //movement failed due to buckled mob(s)
		. = 0

//Called after a successful Move(). By this point, we've already moved
/atom/movable/proc/Moved(atom/OldLoc, Dir)
	if (!inertia_moving)
		inertia_next_move = world.time + inertia_move_delay
		newtonian_move(Dir)
	if (length(client_mobs_in_contents))
		update_parallax_contents()

	if (orbiters)
		for (var/thing in orbiters)
			var/datum/orbit/O = thing
			O.Check()
	if (orbiting)
		orbiting.Check()

	if(flags & CLEAN_ON_MOVE)
		clean_on_move()

	var/datum/proximity_monitor/proximity_monitor = src.proximity_monitor
	if(proximity_monitor)
		proximity_monitor.HandleMove()

	return 1

/atom/movable/proc/clean_on_move()
	var/turf/tile = loc
	if(isturf(tile))
		tile.clean_blood()
		for(var/A in tile)
			if(is_cleanable(A))
				qdel(A)
			else if(istype(A, /obj/item))
				var/obj/item/cleaned_item = A
				cleaned_item.clean_blood()
			else if(ishuman(A))
				var/mob/living/carbon/human/cleaned_human = A
				if(cleaned_human.lying)
					if(cleaned_human.head)
						cleaned_human.head.clean_blood()
						cleaned_human.update_inv_head()
					if(cleaned_human.wear_suit)
						cleaned_human.wear_suit.clean_blood()
						cleaned_human.update_inv_wear_suit()
					else if(cleaned_human.w_uniform)
						cleaned_human.w_uniform.clean_blood()
						cleaned_human.update_inv_w_uniform()
					if(cleaned_human.shoes)
						cleaned_human.shoes.clean_blood()
						cleaned_human.update_inv_shoes()
					cleaned_human.clean_blood()
					cleaned_human.wash_cream()
					to_chat(cleaned_human, "<span class='danger'>[src] cleans your face!</span>")

/atom/movable/Destroy(force)
	var/inform_admins = HAS_SECONDARY_FLAG(src, INFORM_ADMINS_ON_RELOCATE)
	var/stationloving = HAS_SECONDARY_FLAG(src, STATIONLOVING)

	if(inform_admins && force)
		var/turf/T = get_turf(src)
		message_admins("[src] has been !!force deleted!! in [ADMIN_COORDJMP(T)].")
		log_game("[src] has been !!force deleted!! in [COORD(T)].")

	if(stationloving && !force)
		var/turf/currentturf = get_turf(src)
		var/turf/targetturf = relocate()
		log_game("[src] has been destroyed in [COORD(currentturf)]. Moving it to [COORD(targetturf)].")
		if(inform_admins)
			message_admins("[src] has been destroyed in [ADMIN_COORDJMP(currentturf)]. Moving it to [ADMIN_COORDJMP(targetturf)].")
		return QDEL_HINT_LETMELIVE

	if(stationloving && force)
		STOP_PROCESSING(SSinbounds, src)

	QDEL_NULL(proximity_monitor)
	QDEL_NULL(language_holder)
	
	unbuckle_all_mobs(force=1)

	. = ..()
	if(loc)
		loc.handle_atom_del(src)
	for(var/atom/movable/AM in contents)
		qdel(AM)
	loc = null
	invisibility = INVISIBILITY_ABSTRACT
	if(pulledby)
		pulledby.stop_pulling()


// Previously known as HasEntered()
// This is automatically called when something enters your square
/atom/movable/Crossed(atom/movable/AM)
	return

/atom/movable/Bump(atom/A, yes) //the "yes" arg is to differentiate our Bump proc from byond's, without it every Bump() call would become a double Bump().
	if((A && yes))
		if(throwing)
			throwing.hit_atom(A)
			. = 1
			if(!A || QDELETED(A))
				return
		A.Bumped(src)

/atom/movable/proc/forceMove(atom/destination)
	if(destination)
		if(pulledby)
			pulledby.stop_pulling()
		var/atom/oldloc = loc
		var/same_loc = oldloc == destination
		var/area/old_area = get_area(oldloc)
		var/area/destarea = get_area(destination)

		if(oldloc && !same_loc)
			oldloc.Exited(src, destination)
			if(old_area)
				old_area.Exited(src, destination)

		loc = destination

		if(!same_loc)
			destination.Entered(src, oldloc)
			if(destarea && old_area != destarea)
				destarea.Entered(src, oldloc)

			for(var/atom/movable/AM in destination)
				if(AM == src)
					continue
				AM.Crossed(src)

		Moved(oldloc, 0)
		return 1
	return 0

/mob/living/forceMove(atom/destination)
	stop_pulling()
	if(buckled)
		buckled.unbuckle_mob(src,force=1)
	if(has_buckled_mobs())
		unbuckle_all_mobs(force=1)
	. = ..()
	if(client)
		reset_perspective(destination)
	update_canmove() //if the mob was asleep inside a container and then got forceMoved out we need to make them fall.

/mob/living/brain/forceMove(atom/destination)
	if(container)
		return container.forceMove(destination)
	else //something went very wrong.
		CRASH("Brainmob without container.")

//Called whenever an object moves and by mobs when they attempt to move themselves through space
//And when an object or action applies a force on src, see newtonian_move() below
//Return 0 to have src start/keep drifting in a no-grav area and 1 to stop/not start drifting
//Mobs should return 1 if they should be able to move of their own volition, see client/Move() in mob_movement.dm
//movement_dir == 0 when stopping or any dir when trying to move
/atom/movable/proc/Process_Spacemove(movement_dir = 0)
	if(has_gravity(src))
		return 1

	if(pulledby)
		return 1

	if(throwing)
		return 1

	if(locate(/obj/structure/lattice) in range(1, get_turf(src))) //Not realistic but makes pushing things in space easier
		return 1

	return 0


/atom/movable/proc/newtonian_move(direction) //Only moves the object if it's under no gravity
	if(!loc || Process_Spacemove(0))
		inertia_dir = 0
		return 0

	inertia_dir = direction
	if(!direction)
		return 1
	inertia_last_loc = loc
	SSspacedrift.processing[src] = src
	return 1

/atom/movable/proc/checkpass(passflag)
	return pass_flags&passflag

/atom/movable/proc/throw_impact(atom/hit_atom, throwingdatum)
	set waitfor = 0
	return hit_atom.hitby(src)

/atom/movable/hitby(atom/movable/AM, skipcatch, hitpush = 1, blocked)
	if(!anchored && hitpush)
		step(src, AM.dir)
	..()

/atom/movable/proc/throw_at(atom/target, range, speed, mob/thrower, spin=TRUE, diagonals_first = FALSE, var/datum/callback/callback)
	if (!target || (flags & NODROP) || speed <= 0)
		return

	if (pulledby)
		pulledby.stop_pulling()

	//They are moving! Wouldn't it be cool if we calculated their momentum and added it to the throw?
	if (thrower && thrower.last_move && thrower.client && thrower.client.move_delay >= world.time + world.tick_lag*2)
		var/user_momentum = thrower.movement_delay()
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
				return //no throw speed, the user was moving too fast.

	var/datum/thrownthing/TT = new()
	TT.thrownthing = src
	TT.target = target
	TT.target_turf = get_turf(target)
	TT.init_dir = get_dir(src, target)
	TT.maxrange = range
	TT.speed = speed
	TT.thrower = thrower
	TT.diagonals_first = diagonals_first
	TT.callback = callback

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
	if(spin)
		SpinAnimation(5, 1)

	SSthrowing.processing[src] = TT
	if (SSthrowing.state == SS_PAUSED && length(SSthrowing.currentrun))
		SSthrowing.currentrun[src] = TT
	TT.tick()


/atom/movable/proc/handle_buckled_mob_movement(newloc,direct)
	for(var/m in buckled_mobs)
		var/mob/living/buckled_mob = m
		if(!buckled_mob.Move(newloc, direct))
			loc = buckled_mob.loc
			last_move = buckled_mob.last_move
			inertia_dir = last_move
			buckled_mob.inertia_dir = last_move
			return 0
	return 1

/atom/movable/CanPass(atom/movable/mover, turf/target, height=1.5)
	if(mover in buckled_mobs)
		return 1
	return ..()


/atom/movable/proc/get_spacemove_backup()
	var/atom/movable/dense_object_backup
	for(var/A in orange(1, get_turf(src)))
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
				if(AM.anchored)
					return AM
				dense_object_backup = AM
				break
	. = dense_object_backup

//called when a mob resists while inside a container that is itself inside something.
/atom/movable/proc/relay_container_resist(mob/living/user, obj/O)
	return


/atom/movable/proc/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect, end_pixel_y)
	if(!no_effect && (visual_effect_icon || used_item))
		do_item_attack_animation(A, visual_effect_icon, used_item)

	var/pixel_x_diff = 0
	var/pixel_y_diff = 0
	var/final_pixel_y = initial(pixel_y)
	if(end_pixel_y)
		final_pixel_y = end_pixel_y

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
	animate(pixel_x = initial(pixel_x), pixel_y = final_pixel_y, time = 2)

/atom/movable/proc/do_item_attack_animation(atom/A, visual_effect_icon, obj/item/used_item)
	var/image/I
	if(visual_effect_icon)
		I = image('icons/effects/effects.dmi', A, visual_effect_icon, A.layer + 0.1)
	else if(used_item)
		I = image(used_item.icon, A, used_item.icon_state, A.layer + 0.1)

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
	. -= "Jump to"
	.["Follow"] = "?_src_=holder;adminplayerobservefollow=\ref[src]"

/atom/movable/proc/ex_check(ex_id)
	if(!ex_id)
		return TRUE
	LAZYINITLIST(acted_explosions)
	if(ex_id in acted_explosions)
		return FALSE
	acted_explosions += ex_id
	return TRUE

/atom/movable/proc/float(on)
	if(throwing)
		return
	if(on && !floating)
		animate(src, pixel_y = pixel_y + 2, time = 10, loop = -1)
		sleep(10)
		animate(src, pixel_y = pixel_y - 2, time = 10, loop = -1)
		floating = TRUE
	else if (!on && floating)
		animate(src, pixel_y = initial(pixel_y), time = 10)
		floating = FALSE

/* Stationloving
*
* A stationloving atom will always teleport back to the station
* if it ever leaves the station z-levels or Centcom. It will also,
* when Destroy() is called, will teleport to a random turf on the
* station.
*
* The turf is guaranteed to be "safe" for normal humans, probably.
* If the station is SUPER SMASHED UP, it might not work.
*
* Here are some important procs:
* relocate()
* moves the atom to a safe turf on the station
*
* check_in_bounds()
* regularly called and checks if `in_bounds()` returns true. If false, it
* triggers a `relocate()`.
*
* in_bounds()
* By default, checks that the atom's z is the station z or centcom.
*/

/atom/movable/proc/set_stationloving(state, inform_admins=FALSE)
	var/currently = HAS_SECONDARY_FLAG(src, STATIONLOVING)

	if(inform_admins)
		SET_SECONDARY_FLAG(src, INFORM_ADMINS_ON_RELOCATE)
	else
		CLEAR_SECONDARY_FLAG(src, INFORM_ADMINS_ON_RELOCATE)

	if(state == currently)
		return
	else if(!state)
		STOP_PROCESSING(SSinbounds, src)
		CLEAR_SECONDARY_FLAG(src, STATIONLOVING)
	else
		START_PROCESSING(SSinbounds, src)
		SET_SECONDARY_FLAG(src, STATIONLOVING)

/atom/movable/proc/relocate()
	var/targetturf = find_safe_turf(ZLEVEL_STATION)
	if(!targetturf)
		if(GLOB.blobstart.len > 0)
			targetturf = get_turf(pick(GLOB.blobstart))
		else
			throw EXCEPTION("Unable to find a blobstart landmark")

	if(ismob(loc))
		var/mob/M = loc
		M.transferItemToLoc(src, targetturf, TRUE)	//nodrops disks when?
	else if(istype(loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = loc
		S.remove_from_storage(src, targetturf)
	else
		forceMove(targetturf)
	// move the disc, so ghosts remain orbiting it even if it's "destroyed"
	return targetturf

/atom/movable/proc/check_in_bounds()
	if(in_bounds())
		return
	else
		var/turf/currentturf = get_turf(src)
		to_chat(get(src, /mob), "<span class='danger'>You can't help but feel that you just lost something back there...</span>")
		var/turf/targetturf = relocate()
		log_game("[src] has been moved out of bounds in [COORD(currentturf)]. Moving it to [COORD(targetturf)].")
		if(HAS_SECONDARY_FLAG(src, INFORM_ADMINS_ON_RELOCATE))
			message_admins("[src] has been moved out of bounds in [ADMIN_COORDJMP(currentturf)]. Moving it to [ADMIN_COORDJMP(targetturf)].")

/atom/movable/proc/in_bounds()
	. = FALSE
	var/turf/currentturf = get_turf(src)
	if(currentturf && (currentturf.z == ZLEVEL_CENTCOM || currentturf.z == ZLEVEL_STATION))
		. = TRUE


/* Language procs */
/atom/movable/proc/get_language_holder(shadow=TRUE)
	if(language_holder)
		return language_holder
	else
		language_holder = new initial_language_holder(src)
		return language_holder

/atom/movable/proc/grant_language(datum/language/dt)
	var/datum/language_holder/H = get_language_holder()
	H.grant_language(dt)

/atom/movable/proc/grant_all_languages(omnitongue=FALSE)
	var/datum/language_holder/H = get_language_holder()
	H.grant_all_languages(omnitongue)

/atom/movable/proc/get_random_understood_language()
	var/datum/language_holder/H = get_language_holder()
	. = H.get_random_understood_language()

/atom/movable/proc/remove_language(datum/language/dt)
	var/datum/language_holder/H = get_language_holder()
	H.remove_language(dt)

/atom/movable/proc/remove_all_languages()
	var/datum/language_holder/H = get_language_holder()
	H.remove_all_languages()

/atom/movable/proc/has_language(datum/language/dt)
	var/datum/language_holder/H = get_language_holder()
	. = H.has_language(dt)

/atom/movable/proc/copy_known_languages_from(thing, replace=FALSE)
	var/datum/language_holder/H = get_language_holder()
	. = H.copy_known_languages_from(thing, replace)

// Whether an AM can speak in a language or not, independent of whether
// it KNOWS the language
/atom/movable/proc/could_speak_in_language(datum/language/dt)
	. = TRUE

/atom/movable/proc/can_speak_in_language(datum/language/dt)
	var/datum/language_holder/H = get_language_holder()

	if(!H.has_language(dt))
		return FALSE
	else if(H.omnitongue)
		return TRUE
	else if(could_speak_in_language(dt) && (!H.only_speaks_language || H.only_speaks_language == dt))
		return TRUE
	else
		return FALSE

/atom/movable/proc/get_default_language()
	// if no language is specified, and we want to say() something, which
	// language do we use?
	var/datum/language_holder/H = get_language_holder()

	if(H.selected_default_language)
		if(can_speak_in_language(H.selected_default_language))
			return H.selected_default_language
		else
			H.selected_default_language = null


	var/datum/language/chosen_langtype
	var/highest_priority

	for(var/lt in H.languages)
		var/datum/language/langtype = lt
		if(!can_speak_in_language(langtype))
			continue

		var/pri = initial(langtype.default_priority)
		if(!highest_priority || (pri > highest_priority))
			chosen_langtype = langtype
			highest_priority = pri

	H.selected_default_language = .
	. = chosen_langtype

/* End language procs */
/atom/movable/proc/ConveyorMove(movedir)
	set waitfor = FALSE
	if(!anchored && has_gravity())
		step(src, movedir)

//Returns an atom's power cell, if it has one. Overload for individual items.
/atom/movable/proc/get_cell()
	return
