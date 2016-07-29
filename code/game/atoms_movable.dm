<<<<<<< HEAD
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
	var/pass_flags = 0
	var/moving_diagonally = 0 //0: not doing a diagonal move. 1 and 2: doing the first/second step of the diagonal move
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

	if(!loc || (loc == oldloc && oldloc != newloc))
		last_move = 0
		return

	if(.)
		Moved(oldloc, direct)

	last_move = direct
	setDir(direct)

	spawn(5)	// Causes space drifting. /tg/station has no concept of speed, we just use 5
		if(loc && direct && last_move == direct)
			if(loc == newloc) //Remove this check and people can accelerate. Not opening that can of worms just yet.
				newtonian_move(last_move)

	if(. && has_buckled_mobs() && !handle_buckled_mob_movement(loc,direct)) //movement failed due to buckled mob(s)
		. = 0

//Called after a successful Move(). By this point, we've already moved
/atom/movable/proc/Moved(atom/OldLoc, Dir)
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

/mob/living/carbon/brain/forceMove(atom/destination)
	if(container)
		container.forceMove(destination)
	else //something went very wrong.
		CRASH("Brainmob without container.")


/mob/living/silicon/pai/forceMove(atom/destination)
	if(card)
		card.forceMove(destination)
	else //something went very wrong.
		CRASH("pAI without card")


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

	var/old_dir = dir
	. = step(src, direction)
	setDir(old_dir)

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
		if(!istype(loc, /turf))
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
	return 1

/atom/movable/proc/hitcheck()
	for(var/atom/movable/AM in get_turf(src))
		if(AM == src)
			continue
		if(AM.density && !(AM.pass_flags & LETPASSTHROW) && !(AM.flags & ON_BORDER))
			throwing = 0
			throw_impact(AM)
			return 1

//Overlays
/atom/movable/overlay
	var/atom/master = null
	anchored = 1

/atom/movable/overlay/New()
	verbs.Cut()

/atom/movable/overlay/attackby(a, b, c)
	if (src.master)
		return src.master.attackby(a, b, c)

/atom/movable/overlay/attack_paw(a, b, c)
	if (src.master)
		return src.master.attack_paw(a, b, c)

/atom/movable/overlay/attack_hand(a, b, c)
	if (src.master)
		return src.master.attack_hand(a, b, c)

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
=======
/atom/movable
	// Recycling shit

	var/w_type = NOT_RECYCLABLE  // Waste category for sorters. See setup.dm

	layer = 3

	var/last_move = null //Direction in which this atom last moved
	var/last_moved = 0   //world.time when this atom last moved

	var/anchored = 0
	var/move_speed = 10
	var/l_move_time = 1
	var/m_flag = 1
	var/throwing = 0
	var/throw_speed = 2
	var/throw_range = 7
	var/moved_recently = 0
	var/mob/pulledby = null

	var/area/areaMaster

	// Garbage collection (controller).
	//var/gcDestroyed
	//var/timeDestroyed

	var/sound_override = 0 //Do we make a sound when bumping into something?
	var/hard_deleted = 0

	var/obj/effect/overlay/chain/tether = null
	var/tether_pull = 0

	//glide_size = 8

	//Atom locking stuff.
	var/list/locked_atoms // Assoc list of atom = category.
	var/atom/movable/locked_to
	var/list/datum/locking_category/locking_categories // List of categories, unorganized.
	var/list/datum/locking_category/locking_categories_name // Same as above but assoc with the key being the name or type.

	var/lockflags = 0 // Flags for locking. DO NOT CONFUSE WITH /datum/locking_category/flags! These effect being locked.

	// Can we send relaymove() if gravity is disabled or we are in space? (Should be handled by relaymove, but shitcode abounds)
	var/internal_gravity = 0

/atom/movable/New()
	. = ..()
	areaMaster = get_area_master(src)
	if(flags & HEAR && !ismob(src))
		getFromPool(/mob/virtualhearer, src)

	locked_atoms            = list()
	locking_categories      = list()
	locking_categories_name = list()

/atom/movable/Destroy()
	if(flags & HEAR && !ismob(src))
		for(var/mob/virtualhearer/VH in virtualhearers)
			if(VH.attached == src)
				returnToPool(VH)
	gcDestroyed = "Bye, world!"
	tag = null

	var/turf/un_opaque
	if (opacity && isturf(loc))
		un_opaque = loc

	loc = null
	if (un_opaque)
		un_opaque.recalc_atom_opacity()

	for (var/atom/movable/AM in locked_atoms)
		unlock_atom(AM)

	if (locked_to)
		locked_to.unlock_atom(src)

	for (var/datum/locking_category/category in locking_categories)
		qdel(category)

	locking_categories      = null
	locking_categories_name = null

	..()

/proc/delete_profile(var/type, code = 0)
	if(!ticker || ticker.current_state < 3) return
	if(code == 0)
		if (!("[type]" in del_profiling))
			del_profiling["[type]"] = 0

		del_profiling["[type]"] += 1
	else if(code == 1)
		if (!("[type]" in ghdel_profiling))
			ghdel_profiling["[type]"] = 0

		ghdel_profiling["[type]"] += 1
	else
		if (!("[type]" in gdel_profiling))
			gdel_profiling["[type]"] = 0

		gdel_profiling["[type]"] += 1
		soft_dels += 1

/atom/movable/Del()
	if (gcDestroyed)

		if (hard_deleted)
			delete_profile("[type]", 1)
		else
			garbageCollector.dequeue("\ref[src]") // hard deletions have already been handled by the GC queue.
			delete_profile("[type]", 2)
	else // direct del calls or nulled explicitly.
		delete_profile("[type]", 0)
		Destroy()

	..()

/atom/movable/Move(newLoc,Dir=0,step_x=0,step_y=0)
	if(!loc || !newLoc)
		return 0
	//set up glide sizes before the move
	//ensure this is a step, not a jump

	//. = ..(NewLoc,Dir,step_x,step_y)
	if(timestopped)
		if(!pulledby || pulledby.timestopped) //being moved by our wizard maybe?
			return 0
	var/move_delay = max(5 * world.tick_lag, 1)
	if(ismob(src))
		var/mob/M = src
		if(M.client)
			move_delay = (3+(M.client.move_delayer.next_allowed - world.time))*world.tick_lag

	var/can_pull_tether = 0
	if(tether)
		if(tether.attempt_to_follow(src,newLoc))
			can_pull_tether = 1
		else
			return 0
	glide_size = Ceiling(32 / move_delay * world.tick_lag) - 1 //We always split up movements into cardinals for issues with diagonal movements.
	var/atom/oldloc = loc
	if((bound_height != 32 || bound_width != 32) && (loc == newLoc))
		. = ..()

		update_dir()
		return

	if(loc != newLoc)
		if (!(Dir & (Dir - 1))) //Cardinal move
			. = ..()
		else //Diagonal move, split it into cardinal moves
			if (Dir & 1)
				if (Dir & 4)
					if (step(src, NORTH))
						. = step(src, EAST)
					else if (step(src, EAST))
						. = step(src, NORTH)
				else if (Dir & 8)
					if (step(src, NORTH))
						. = step(src, WEST)
					else if (step(src, WEST))
						. = step(src, NORTH)
			else if (Dir & 2)
				if (Dir & 4)
					if (step(src, SOUTH))
						. = step(src, EAST)
					else if (step(src, EAST))
						. = step(src, SOUTH)
				else if (Dir & 8)
					if (step(src, SOUTH))
						. = step(src, WEST)
					else if (step(src, WEST))
						. = step(src, SOUTH)


	if(. && locked_atoms && locked_atoms.len)	//The move was succesful, update locked atoms.
		spawn(0)
			for(var/atom/movable/AM in locked_atoms)
				var/datum/locking_category/category = locked_atoms[AM]
				category.update_lock(AM)

	update_dir()

	if(!loc || (loc == oldloc && oldloc != newLoc))
		last_move = 0
		return

	update_client_hook(loc)

	if(tether && can_pull_tether && !tether_pull)
		tether.follow(src,oldloc)
		var/datum/chain/tether_datum = tether.chain_datum
		if(!tether_datum.Check_Integrity())
			tether_datum.snap = 1
			tether_datum.Delete_Chain()

	last_move = Dir
	last_moved = world.time
	src.move_speed = world.timeofday - src.l_move_time
	src.l_move_time = world.timeofday
	// Update on_moved listeners.
	INVOKE_EVENT(on_moved,list("loc"=newLoc))
	return .

//The reason behind change_dir()
/atom/movable/proc/update_dir()
	for(var/atom/movable/AM in locked_atoms)
		if(dir != AM.dir)
			AM.change_dir(dir, src)

//Like forceMove(), but for dirs!
/atom/movable/proc/change_dir(new_dir, var/changer)
	if(locked_to && changer != locked_to)
		return

	if(new_dir != dir)
		dir = new_dir
		update_dir()

// Atom locking, lock an atom to another atom, and the locked atom will move when the other atom moves.
// Essentially buckling mobs to chairs. For all atoms.
// Category is the locking category to lock this atom to, see /code/datums/locking_category.dm.
// For category you should pass the typepath of the category, however strings should be used for slots made dynamically at runtime.
/atom/movable/proc/lock_atom(var/atom/movable/AM, var/datum/locking_category/category = /datum/locking_category)
	if (AM in locked_atoms || AM.locked_to || !istype(AM))
		return 0

	category = get_lock_cat(category)
	if (!category) // String category which didn't exist.
		return 0

	AM.locked_to = src

	locked_atoms[AM] = category
	category.lock(AM)

	return 1

/atom/movable/proc/unlock_atom(var/atom/movable/AM)
	if (!locked_atoms.Find(AM))
		return

	var/datum/locking_category/category = locked_atoms[AM]
	locked_atoms    -= AM
	AM.locked_to     = null
	category.unlock(AM)

	return 1

/atom/movable/proc/unlock_from()
	if(!locked_to)
		return 0

	locked_to.unlock_atom(src)

/atom/movable/proc/get_lock_cat(var/category = /datum/locking_category)
	. = locking_categories_name[category]

	if (!.)
		if (istext(category))
			return

		. = getFromPool(category, src)
		locking_categories_name[category] = .
		locking_categories += .

/atom/movable/proc/get_locked(var/category)
	if (!category)
		return locked_atoms

	if (locking_categories_name.Find(category))
		var/datum/locking_category/C = locking_categories_name[category]
		return C.locked

	return list()

/atom/movable/proc/is_locking(var/category) // Returns true if we have any locked atoms in this category.
	var/list/atom/movable/locked = get_locked(category)
	return locked && locked.len

/atom/movable/proc/recycle(var/datum/materials/rec)
	if(materials)
		for(var/matid in materials.storage)
			var/datum/material/material = materials.getMaterial(matid)
			rec.addAmount(matid, materials.storage[matid] / material.cc_per_sheet) //the recycler's material is read as 1 = 1 sheet
			materials.storage[matid] = 0
		return 1
	return 0

// Previously known as HasEntered()
// This is automatically called when something enters your square
/atom/movable/Crossed(atom/movable/AM)
	return

/atom/movable/Bump(atom/Obstacle)
	if(src.throwing)
		src.throw_impact(Obstacle)
		src.throwing = 0

	if (Obstacle)
		Obstacle.Bumped(src)

/atom/movable/proc/forceMove(atom/destination,var/no_tp=0)
	if(destination)
		if(loc)
			loc.Exited(src)

		last_move = get_dir(loc, destination)
		last_moved = world.time

		loc = destination

		loc.Entered(src)
		if(isturf(destination))
			var/area/A = get_area_master(destination)
			A.Entered(src)

			for(var/atom/movable/AM in loc)
				AM.Crossed(src,no_tp)


		for(var/atom/movable/AM in locked_atoms)
			var/datum/locking_category/category = locked_atoms[AM]
			category.update_lock(AM)

		update_client_hook(destination)

		// Update on_moved listeners.
		INVOKE_EVENT(on_moved,list("loc"=loc))
		return 1
	return 0

/atom/movable/proc/update_client_hook(atom/destination)
	if(locate(/mob) in src)
		for(var/client/C in parallax_on_clients)
			if((get_turf(C.eye) == destination) && (C.mob.hud_used))
				C.mob.hud_used.update_parallax_values()

/mob/update_client_hook(atom/destination)
	if(locate(/mob) in src)
		for(var/client/C in parallax_on_clients)
			if((get_turf(C.eye) == destination) && (C.mob.hud_used))
				C.mob.hud_used.update_parallax_values()
	else if(client && hud_used)
		hud_used.update_parallax_values()

/atom/movable/proc/forceEnter(atom/destination)
	if(destination)
		if(loc)
			loc.Exited(src)
		loc = destination
		loc.Entered(src)
		if(isturf(destination))
			var/area/A = get_area_master(destination)
			A.Entered(src)

		for(var/atom/movable/AM in locked_atoms)
			AM.forceMove(loc)

		update_client_hook(destination)
		return 1
	return 0

/atom/movable/proc/hit_check(var/speed, mob/user)
	. = 1

	if(src.throwing)
		for(var/atom/A in get_turf(src))
			if(A == src) continue

			if(isliving(A))
				var/mob/living/L = A
				if(L.lying) continue
				src.throw_impact(L, speed, user)

				if(src.throwing == 1) //If throwing == 1, the throw was weak and will stop when it hits a dude. If a hulk throws this item, throwing is set to 2 (so the item will pass through multiple mobs)
					src.throwing = 0
					. = 0

			else if(isobj(A))
				if(A.density && !A.throwpass)	// **TODO: Better behaviour for windows which are dense, but shouldn't always stop movement
					src.throw_impact(A, speed, user)
					src.throwing = 0
					. = 0

/atom/movable/proc/throw_at(atom/target, range, speed, override = 1, var/fly_speed = 0) //fly_speed parameter: if 0, does nothing. Otherwise, changes how fast the object flies WITHOUT affecting damage!
	if(!target || !src)	return 0
	if(override)
		sound_override = 1
	//use a modified version of Bresenham's algorithm to get from the atom's current position to that of the target

	throwing = 1
	if(!speed)
		speed = throw_speed
	if(!fly_speed)
		fly_speed = speed

	var/mob/user
	if(usr)
		user = usr
		if(M_HULK in usr.mutations)
			src.throwing = 2 // really strong throw!

	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)

	var/dx
	if (target.x > src.x)
		dx = EAST
	else
		dx = WEST

	var/dy
	if (target.y > src.y)
		dy = NORTH
	else
		dy = SOUTH
	var/dist_travelled = 0
	var/dist_since_sleep = 0
	var/area/a = get_area(src.loc)

	. = 1

	if(dist_x > dist_y)
		var/error = dist_x/2 - dist_y


		var/tS = 0
		while(src && target &&((((src.x < target.x && dx == EAST) || (src.x > target.x && dx == WEST)) && dist_travelled < range) || (a && a.has_gravity == 0)  || istype(src.loc, /turf/space)) && src.throwing && istype(src.loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(tS && dist_travelled)
				timestopped = loc.timestopped
				tS = 0
			if(timestopped && !dist_travelled)
				timestopped = 0
				tS = 1
			while((loc.timestopped || timestopped) && dist_travelled)
				sleep(3)
			if(error < 0)
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					. = 0
					break

				src.Move(step)
				. = hit_check(speed, user)
				error += dist_x
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= fly_speed)
					dist_since_sleep = 0
					sleep(1)
			else
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					. = 0
					break

				src.Move(step)
				. = hit_check(speed, user)
				error -= dist_y
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= fly_speed)
					dist_since_sleep = 0
					sleep(1)
			a = get_area(src.loc)
	else
		var/error = dist_y/2 - dist_x
		while(src && target &&((((src.y < target.y && dy == NORTH) || (src.y > target.y && dy == SOUTH)) && dist_travelled < range) || (a && a.has_gravity == 0)  || istype(src.loc, /turf/space)) && src.throwing && istype(src.loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(timestopped)
				sleep(1)
				continue
			if(error < 0)
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					. = 0
					break

				src.Move(step)
				. = hit_check(speed, user)
				error += dist_y
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= fly_speed)
					dist_since_sleep = 0
					sleep(1)
			else
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					. = 0
					break

				src.Move(step)
				. = hit_check(speed, user)
				error -= dist_x
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= fly_speed)
					dist_since_sleep = 0
					sleep(1)

			a = get_area(src.loc)

	//done throwing, either because it hit something or it finished moving
	src.throwing = 0
	if(isobj(src))
		src.throw_impact(get_turf(src), speed, user)

/atom/movable/change_area(oldarea, newarea)
	areaMaster = newarea
	..()

//Overlays
/atom/movable/overlay
	var/atom/master = null
	anchored = 1

/atom/movable/overlay/New()
	. = ..()
	verbs.len = 0

/atom/movable/overlay/blob_act()
	return

/atom/movable/overlay/attackby(a, b, c)
	if (src.master)
		return src.master.attackby(a, b, c)
	return

/atom/movable/overlay/attack_paw(a, b, c)
	if (src.master)
		return src.master.attack_paw(a, b, c)
	return

/atom/movable/overlay/attack_hand(a, b, c)
	if (src.master)
		return src.master.attack_hand(a, b, c)
	return

/atom/movable/proc/attempt_to_follow(var/atom/movable/A,var/turf/T)
	if(anchored)
		return 0
	if(get_dist(T,loc) <= 1)
		return 1
	else
		var/turf/U = get_turf(A)
		if(!U) return null
		return src.forceMove(U)

/////////////////////////////
// SINGULOTH PULL REFACTOR
/////////////////////////////
/atom/movable/proc/canSingulothPull(var/obj/machinery/singularity/singulo)
	return 1

/atom/movable/proc/say_understands(var/mob/other)
	return 1

////////////
/// HEAR ///
////////////
/atom/movable/proc/addHear()
	flags |= HEAR
	getFromPool(/mob/virtualhearer, src)

/atom/movable/proc/removeHear()
	flags &= ~HEAR
	for(var/mob/virtualhearer/VH in virtualhearers)
		if(VH.attached == src)
			returnToPool(VH)

//Can it be moved by a shuttle?
/atom/movable/proc/can_shuttle_move(var/datum/shuttle/S)
	return 1
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
