/atom/movable
	layer = 3
	var/last_move = null
	var/anchored = 0
	var/move_speed = 10
	var/l_move_time = 1
	var/m_flag = 1
	var/throwing = 0
	var/throw_speed = 2
	var/throw_range = 7
	var/mob/pulledby = null
	var/languages = 0 //For say() and Hear()
	glide_size = 8

/atom/movable/Move()
	var/atom/A = src.loc
	. = ..()
	src.move_speed = world.timeofday - src.l_move_time
	src.l_move_time = world.timeofday
	src.m_flag = 1
	if ((A != src.loc && A && A.z == src.z))
		src.last_move = get_dir(A, src.loc)
	return

/atom/movable/Del()
	if(isnull(gc_destroyed) && loc)
		testing("GC: -- [type] was deleted via del() rather than qdel() --")
//	else if(isnull(gc_destroyed))
//		testing("GC: [type] was deleted via GC without qdel()") //Not really a huge issue but from now on, please qdel()
//	else
//		testing("GC: [type] was deleted via GC with qdel()")
	..()

/atom/movable/Destroy()
	if(reagents)
		qdel(reagents)
	for(var/atom/movable/AM in contents)
		qdel(AM)
	tag = null
	loc = null
	invisibility = 101
	// Do not call ..()

// Previously known as HasEntered()
// This is automatically called when something enters your square
/atom/movable/Crossed(atom/movable/AM)
	return

/atom/movable/Bump(var/atom/A as mob|obj|turf|area, yes)
	if(src.throwing)
		src.throw_impact(A)
		src.throwing = 0

	if ((A && yes))
		A.last_bumped = world.time
		A.Bumped(src)
	return
	..()
	return

/atom/movable/proc/forceMove(atom/destination)
	if(destination)
		if(loc)
			loc.Exited(src)
		loc = destination
		loc.Entered(src)
		for(var/atom/movable/AM in loc)
			AM.Crossed(src)
		return 1
	return 0

/atom/movable/proc/hit_check() // todo: this is partly obsolete due to passflags already, add throwing stuff to mob CanPass and finish it
	if(src.throwing)
		for(var/atom/A in get_turf(src))
			if(A == src) continue
			if(istype(A,/mob/living))
				if(A:lying) continue
				src.throw_impact(A)
				if(src.throwing == 1)
					src.throwing = 0
			if(isobj(A))
				if(A.density && !A.throwpass)	// **TODO: Better behaviour for windows which are dense, but shouldn't always stop movement
					src.throw_impact(A)
					src.throwing = 0

/atom/movable/proc/throw_at(atom/target, range, speed)
	if(!target || !src || (flags & NODROP))	return 0
	//use a modified version of Bresenham's algorithm to get from the atom's current position to that of the target

	src.throwing = 1

	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)
	var/dx = (target.x > src.x) ? EAST : WEST
	var/dy = (target.y > src.y) ? NORTH : SOUTH
	var/dist_travelled = 0
	var/dist_since_sleep = 0

	var/tdist_x = dist_x;
	var/tdist_y = dist_y;
	var/tdx = dx;
	var/tdy = dy;

	if(dist_x <= dist_y)
		tdist_x = dist_y;
		tdist_y = dist_x;
		tdx = dy;
		tdy = dx;

	var/error = tdist_x/2 - tdist_y
	while(target && (((((dist_x > dist_y) && ((src.x < target.x && dx == EAST) || (src.x > target.x && dx == WEST))) || ((dist_x <= dist_y) && ((src.y < target.y && dy == NORTH) || (src.y > target.y && dy == SOUTH))) || (src.x > target.x && dx == WEST)) && dist_travelled < range) || !has_gravity(src)))
		// only stop when we've gone the whole distance (or max throw range) and are on a non-space tile, or hit something, or hit the end of the map, or someone picks it up
		if(!src.throwing) break
		if(!istype(src.loc, /turf)) break

		var/atom/step = get_step(src, (error < 0) ? tdy : tdx)
		if(!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
			break
		src.Move(step)
		hit_check()
		error += (error < 0) ? tdist_x : -tdist_y;
		dist_travelled++
		dist_since_sleep++
		if(dist_since_sleep >= speed)
			dist_since_sleep = 0
			sleep(1)

	//done throwing, either because it hit something or it finished moving
	src.throwing = 0
	if(isobj(src))
		src.throw_impact(get_turf(src))

	return 1


//Overlays
/atom/movable/overlay
	var/atom/master = null
	anchored = 1

/atom/movable/overlay/New()
	verbs.Cut()
	return

/atom/movable/overlay/attackby(a, b)
	if (src.master)
		return src.master.attackby(a, b)
	return

/atom/movable/overlay/attack_paw(a, b, c)
	if (src.master)
		return src.master.attack_paw(a, b, c)
	return

/atom/movable/overlay/attack_hand(a, b, c)
	if (src.master)
		return src.master.attack_hand(a, b, c)
	return
