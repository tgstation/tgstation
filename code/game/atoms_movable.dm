/atom/movable
	// Recycling shit

	var/w_type = NOT_RECYCLABLE  // Waste category for sorters. See setup.dm

	layer = 3
	var/last_move = null
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
	//glide_size = 8

/atom/movable/New()
	. = ..()
	areaMaster = get_area_master(src)
	if(flags & HEAR && !ismob(src))
		getFromPool(/mob/virtualhearer, src)

/atom/movable/Destroy()
	if(flags & HEAR && !ismob(src))
		for(var/mob/virtualhearer/VH in virtualhearers)
			if(VH.attached == src)
				returnToPool(VH)
	gcDestroyed = "Bye, world!"
	tag = null
	loc = null
	..()

/proc/delete_profile(var/type, code = 0)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/delete_profile() called tick#: [world.time]")
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
	var/move_delay = 5 * world.tick_lag
	if(ismob(src))
		var/mob/M = src
		if(M.client)
			move_delay = (3+(M.client.move_delayer.next_allowed - world.time))*world.tick_lag
	glide_size = Ceiling(32 / move_delay * world.tick_lag) - 1 //We always split up movements into cardinals for issues with diagonal movements.
	var/atom/oldloc = loc
	if((bound_height != 32 || bound_width != 32) && (loc == newLoc))
		return ..()
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

	if(!loc || (loc == oldloc && oldloc != newLoc))
		last_move = 0
		return

	last_move = Dir
	src.move_speed = world.timeofday - src.l_move_time
	src.l_move_time = world.timeofday
	// Update on_moved listeners.
	INVOKE_EVENT(on_moved,list("loc"=newLoc))
	return .

/atom/movable/proc/recycle(var/datum/materials/rec)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/recycle() called tick#: [world.time]")
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

/atom/movable/proc/forceMove(atom/destination)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/forceMove() called tick#: [world.time]")
	if(destination)
		if(loc)
			loc.Exited(src)

		loc = destination
		loc.Entered(src)
		if(isturf(destination))
			var/area/A = get_area_master(destination)
			A.Entered(src)

		for(var/atom/movable/AM in loc)
			AM.Crossed(src)

		// Update on_moved listeners.
		INVOKE_EVENT(on_moved,list("loc"=loc))
		return 1
	return 0

/atom/movable/proc/forceEnter(atom/destination)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/forceEnter() called tick#: [world.time]")
	if(destination)
		if(loc)
			loc.Exited(src)
		loc = destination
		loc.Entered(src)
		if(isturf(destination))
			var/area/A = get_area_master(destination)
			A.Entered(src)
		return 1
	return 0

/atom/movable/proc/hit_check(var/speed, mob/user)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/hit_check() called tick#: [world.time]")
	if(src.throwing)
		for(var/atom/A in get_turf(src))
			if(A == src) continue
			if(istype(A,/mob/living))
				if(A:lying) continue
				src.throw_impact(A, speed, user)
				if(src.throwing == 1)
					src.throwing = 0
			if(isobj(A))
				if(A.density && !A.throwpass)	// **TODO: Better behaviour for windows which are dense, but shouldn't always stop movement
					src.throw_impact(A, speed, user)
					src.throwing = 0

/atom/movable/proc/throw_at(atom/target, range, speed, override = 1)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/throw_at() called tick#: [world.time]")
	if(!target || !src)	return 0
	if(override)
		sound_override = 1
	//use a modified version of Bresenham's algorithm to get from the atom's current position to that of the target

	throwing = 1
	throw_speed = speed

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
	if(dist_x > dist_y)
		var/error = dist_x/2 - dist_y



		while(src && target &&((((src.x < target.x && dx == EAST) || (src.x > target.x && dx == WEST)) && dist_travelled < range) || (a && a.has_gravity == 0)  || istype(src.loc, /turf/space)) && src.throwing && istype(src.loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(error < 0)
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step)
				hit_check(throw_speed, user)
				error += dist_x
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= throw_speed)
					dist_since_sleep = 0
					sleep(1)
			else
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step)
				hit_check(throw_speed, user)
				error -= dist_y
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= throw_speed)
					dist_since_sleep = 0
					sleep(1)
			a = get_area(src.loc)
	else
		var/error = dist_y/2 - dist_x
		while(src && target &&((((src.y < target.y && dy == NORTH) || (src.y > target.y && dy == SOUTH)) && dist_travelled < range) || (a && a.has_gravity == 0)  || istype(src.loc, /turf/space)) && src.throwing && istype(src.loc, /turf))
			// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
			if(error < 0)
				var/atom/step = get_step(src, dx)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step)
				hit_check(throw_speed, user)
				error += dist_y
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= throw_speed)
					dist_since_sleep = 0
					sleep(1)
			else
				var/atom/step = get_step(src, dy)
				if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
					break
				src.Move(step)
				hit_check(throw_speed, user)
				error -= dist_x
				dist_travelled++
				dist_since_sleep++
				if(dist_since_sleep >= throw_speed)
					dist_since_sleep = 0
					sleep(1)

			a = get_area(src.loc)

	//done throwing, either because it hit something or it finished moving
	src.throwing = 0
	if(isobj(src)) src.throw_impact(get_turf(src), throw_speed, user)

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

/////////////////////////////
// SINGULOTH PULL REFACTOR
/////////////////////////////
/atom/movable/proc/canSingulothPull(var/obj/machinery/singularity/singulo)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/canSingulothPull() called tick#: [world.time]")
	return singuloCanEat()

/atom/movable/proc/say_understands(var/mob/other)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/say_understands() called tick#: [world.time]")
	return 1

////////////
/// HEAR ///
////////////
/atom/movable/proc/addHear()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/addHear() called tick#: [world.time]")
	flags |= HEAR
	getFromPool(/mob/virtualhearer, src)

/atom/movable/proc/removeHear()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/removeHear() called tick#: [world.time]")
	flags &= ~HEAR
	for(var/mob/virtualhearer/VH in virtualhearers)
		if(VH.attached == src)
			returnToPool(VH)

//Can it be moved by a shuttle?
/atom/movable/proc/can_shuttle_move(var/datum/shuttle/S)
	return 1
