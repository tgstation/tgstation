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
	var/list/locked_atoms
	var/atom/movable/locked_to
	var/locked_should_lie = 0	//Whether locked mobs should lie down, used by beds.
	var/lockflags = DENSE_WHEN_LOCKING | DENSE_WHEN_LOCKED

	// Can we send relaymove() if gravity is disabled or we are in space? (Should be handled by relaymove, but shitcode abounds)
	var/internal_gravity = 0

/atom/movable/New()
	. = ..()
	areaMaster = get_area_master(src)
	if(flags & HEAR && !ismob(src))
		getFromPool(/mob/virtualhearer, src)

	locked_atoms = list()

/atom/movable/Destroy()
	if(flags & HEAR && !ismob(src))
		for(var/mob/virtualhearer/VH in virtualhearers)
			if(VH.attached == src)
				returnToPool(VH)
	gcDestroyed = "Bye, world!"
	tag = null
	loc = null

	for(var/atom/movable/AM in locked_atoms)
		unlock_atom(AM)

	if(locked_to)
		locked_to.unlock_atom(src)

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
				var/new_loc = loc

				if(locked_atoms[AM])
					var/list/atomlock_params = locked_atoms[AM]

					var/offset_x = atomlock_params[1]
					var/offset_y = atomlock_params[2]

					var/rotate_with_our_dir = atomlock_params[3]

					if(rotate_with_our_dir)
						var/newX = offset_x
						var/newY = offset_y

						switch(dir)
							if(NORTH) //up
								offset_x = newX
								offset_y = newY
							if(EAST) // right
								offset_x = newY
								offset_y = -newX
							if(SOUTH) //down
								offset_x = -newX
								offset_y = -newY
							if(WEST) //left
								offset_x = -newY
								offset_y = newX

					if(offset_x || offset_y)
						var/newer_loc = locate(x + offset_x, y + offset_y, z)
						if(newer_loc)
							new_loc = newer_loc

				AM.forceMove(new_loc)

	update_dir()

	if(!loc || (loc == oldloc && oldloc != newLoc))
		last_move = 0
		return

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

//Atom locking, lock an atom to another atom, and the locked atom will move when the other atom moves.
//Essentially buckling mobs to chairs. For all atoms.
//Please don't lock atoms to other atoms if the atoms locked to expect for example a different type, it's basically bound to runtime/glitch.
//x_offset, y_offset parameters are used if you don't want the locked atom to be on the top of this atom. So x_offset = 1 means the atom-locked object will always be one turf to the east, etc...
//rotate_offsets parameter is used if you have set x_offset or y_offset, and want the offsets to be relative to the object's direction
/atom/movable/proc/lock_atom(var/atom/movable/AM, var/x_offset = 0, var/y_offset = 0, var/rotate_offsets = 0)
	if(AM in locked_atoms || AM.locked_to || !istype(AM))
		return

	AM.locked_to = src
	locked_atoms += AM

	if(x_offset || y_offset)
		locked_atoms[AM] = list(x_offset, y_offset, rotate_offsets)

		var/new_loc = loc

		if(rotate_offsets)
			var/newX = x_offset
			var/newY = y_offset

			switch(dir)
				if(NORTH) //up
					x_offset = newX
					y_offset = newY
				if(EAST) // right
					x_offset = newY
					y_offset = -newX
				if(SOUTH) //down
					x_offset = -newX
					y_offset = -newY
				if(WEST) //left
					x_offset = -newY
					y_offset = newX

			var/newer_loc = locate(x + x_offset, y + y_offset, z)
			if(newer_loc)
				new_loc = newer_loc

		AM.forceMove(new_loc)

	else
		AM.forceMove(loc)

	AM.change_dir(dir, src)

	if(ismob(AM))
		var/mob/M = AM
		M.update_canmove()

	AM.anchored = 1

	if((lockflags & DENSE_WHEN_LOCKING) && (AM.lockflags & DENSE_WHEN_LOCKED))
		density = 1

	return 1

/atom/movable/proc/unlock_atom(var/atom/movable/AM)
	if(!(AM in locked_atoms))
		return

	locked_atoms -= AM
	AM.locked_to = null

	if(ismob(AM))
		var/mob/M = AM
		M.update_canmove()

	AM.anchored = initial(AM.anchored)

	if((lockflags & DENSE_WHEN_LOCKING) && (AM.lockflags && DENSE_WHEN_LOCKED))
		density = initial(density)

	return 1

/atom/movable/proc/unlock_from()
	if(!locked_to)
		return 0

	locked_to.unlock_atom(src)

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

/atom/movable/Bump(atom/Obstacle, yes)
	if(src.throwing)
		src.throw_impact(Obstacle)
		src.throwing = 0

	if ((Obstacle && yes))
		Obstacle.last_bumped = world.time
		Obstacle.Bumped(src)
	return
	..()
	return

/atom/movable/proc/forceMove(atom/destination,var/no_tp=0)
	if(destination)
		if(loc)
			loc.Exited(src)

		loc = destination
		loc.Entered(src)
		if(isturf(destination))
			var/area/A = get_area_master(destination)
			A.Entered(src)

		for(var/atom/movable/AM in loc)
			AM.Crossed(src,no_tp)


		for(var/atom/movable/AM in locked_atoms)
			AM.forceMove(loc)

		// Update on_moved listeners.
		INVOKE_EVENT(on_moved,list("loc"=loc))
		return 1
	return 0

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
	return singuloCanEat()

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
