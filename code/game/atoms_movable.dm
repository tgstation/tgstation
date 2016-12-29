/atom/movable
	layer = OBJ_LAYER
	var/last_move = null
	var/anchored = 0
	var/throwing = 0
	var/throw_speed = 2
	var/throw_range = 7
	var/mob/pulledby = null
	var/languages_spoken = 0 //For say() and Hear()
	var/languages_understood = 0
	var/verb_say = "says"
	var/verb_ask = "asks"
	var/verb_exclaim = "exclaims"
	var/verb_yell = "yells"
	var/inertia_dir = 0
	var/atom/inertia_last_loc
	var/inertia_moving = 0
	var/inertia_next_move = 0
	var/inertia_move_delay = 5
	var/pass_flags = 0
	var/moving_diagonally = 0 //0: not doing a diagonal move. 1 and 2: doing the first/second step of the diagonal move
	var/list/client_mobs_in_contents // This contains all the client mobs within this container
	glide_size = 8
	appearance_flags = TILE_BOUND



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
	return 1

/atom/movable/Destroy()
	. = ..()
	if(loc)
		loc.handle_atom_del(src)
	if(reagents)
		qdel(reagents)
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
			throwing = 0
			throw_impact(A)
			. = 1
			if(!A || qdeleted(A))
				return
		A.Bumped(src)


/atom/movable/proc/forceMove(atom/destination)
	if(destination)
		if(pulledby)
			pulledby.stop_pulling()
		var/atom/oldloc = loc
		if(oldloc)
			oldloc.Exited(src, destination)
		loc = destination
		destination.Entered(src, oldloc)
		var/area/old_area = get_area(oldloc)
		var/area/destarea = get_area(destination)
		if(old_area != destarea)
			destarea.Entered(src)
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

/atom/movable/proc/throw_impact(atom/hit_atom)
	return hit_atom.hitby(src)

/atom/movable/hitby(atom/movable/AM, skipcatch, hitpush = 1, blocked)
	if(!anchored && hitpush)
		step(src, AM.dir)
	..()

/atom/movable/proc/throw_at_fast(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0)
	set waitfor = 0
	throw_at(target, range, speed, thrower, spin, diagonals_first)

/atom/movable/proc/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0)
	if(!target || !src || (flags & NODROP))
		return 0
	//use a modified version of Bresenham's algorithm to get from the atom's current position to that of the target

	if(pulledby)
		pulledby.stop_pulling()

	throwing = 1
	if(spin) //if we don't want the /atom/movable to spin.
		SpinAnimation(5, 1)

	var/dist_travelled = 0
	var/next_sleep = 0

	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)
	var/dx = (target.x > src.x) ? EAST : WEST
	var/dy = (target.y > src.y) ? NORTH : SOUTH

	var/pure_diagonal = 0
	if(dist_x == dist_y)
		pure_diagonal = 1

	if(dist_x <= dist_y)
		var/olddist_x = dist_x
		var/olddx = dx
		dist_x = dist_y
		dist_y = olddist_x
		dx = dy
		dy = olddx

	var/error = dist_x/2 - dist_y //used to decide whether our next move should be forward or diagonal.
	var/atom/finalturf = get_turf(target)
	var/hit = 0
	var/init_dir = get_dir(src, target)

	while(target && ((dist_travelled < range && loc != finalturf)  || !has_gravity(src))) //stop if we reached our destination (or max range) and aren't floating
		var/slept = 0
		if(!isturf(loc))
			hit = 1
			break

		var/atom/step
		if(dist_travelled < max(dist_x, dist_y)) //if we haven't reached the target yet we home in on it, otherwise we use the initial direction
			step = get_step(src, get_dir(src, finalturf))
		else
			step = get_step(src, init_dir)

		if(!pure_diagonal && !diagonals_first) // not a purely diagonal trajectory and we don't want all diagonal moves to be done first
			if(error >= 0 && max(dist_x,dist_y) - dist_travelled != 1) //we do a step forward unless we're right before the target
				step = get_step(src, dx)
			error += (error < 0) ? dist_x/2 : -dist_y
		if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
			break
		Move(step, get_dir(loc, step))
		if(!throwing) // we hit something during our move
			hit = 1
			break
		dist_travelled++

		if(dist_travelled > 600) //safety to prevent infinite while loop.
			break
		if(dist_travelled >= next_sleep)
			slept = 1
			next_sleep += speed
			sleep(1)
		if(!slept)
			var/ticks_slept = TICK_CHECK
			if(ticks_slept)
				slept = 1
				next_sleep += speed*(ticks_slept*world.tick_lag) //delay the next normal sleep

		if(slept && hitcheck()) //to catch sneaky things moving on our tile while we slept
			hit = 1
			break


	//done throwing, either because it hit something or it finished moving
	throwing = 0
	if(!hit)
		for(var/atom/A in get_turf(src)) //looking for our target on the turf we land on.
			if(A == target)
				hit = 1
				throw_impact(A)
				return 1

		throw_impact(get_turf(src))  // we haven't hit something yet and we still must, let's hit the ground.
	newtonian_move(init_dir)
	return 1

/atom/movable/proc/hitcheck()
	for(var/atom/movable/AM in get_turf(src))
		if(AM == src)
			continue
		if(AM.density && !(AM.pass_flags & LETPASSTHROW) && !(AM.flags & ON_BORDER))
			throwing = 0
			throw_impact(AM)
			return 1

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

	flick_overlay(I, clients, 5) // 5 ticks/half a second

	// And animate the attack!
	animate(I, alpha = 175, pixel_x = 0, pixel_y = 0, pixel_z = 0, time = 3)

/atom/movable/vv_get_dropdown()
	. = ..()
	. -= "Jump to"
	.["Follow"] = "?_src_=holder;adminplayerobservefollow=\ref[src]"
