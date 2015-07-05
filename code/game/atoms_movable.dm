/atom/movable
	layer = 3
	var/last_move = null
	var/anchored = 0
	var/throwing = 0
	var/throw_speed = 2
	var/throw_range = 7
	var/mob/pulledby = null
	var/languages = 0 //For say() and Hear()
	var/verb_say = "says"
	var/verb_ask = "asks"
	var/verb_exclaim = "exclaims"
	var/verb_yell = "yells"
	var/inertia_dir = 0
	var/pass_flags = 0
	glide_size = 8


/atom/movable/Move(atom/newloc, direct = 0)
	if(!loc || !newloc) return 0
	var/atom/oldloc = loc

	if(loc != newloc)
		if (!(direct & (direct - 1))) //Cardinal move
			. = ..()
		else //Diagonal move, split it into cardinal moves
			if (direct & 1)
				if (direct & 4)
					if (step(src, NORTH))
						. = step(src, EAST)
					else if (step(src, EAST))
						. = step(src, NORTH)
				else if (direct & 8)
					if (step(src, NORTH))
						. = step(src, WEST)
					else if (step(src, WEST))
						. = step(src, NORTH)
			else if (direct & 2)
				if (direct & 4)
					if (step(src, SOUTH))
						. = step(src, EAST)
					else if (step(src, EAST))
						. = step(src, SOUTH)
				else if (direct & 8)
					if (step(src, SOUTH))
						. = step(src, WEST)
					else if (step(src, WEST))
						. = step(src, SOUTH)

	if(!loc || (loc == oldloc && oldloc != newloc))
		last_move = 0
		return

	if(.)
		Moved(oldloc, direct)

	last_move = direct

	spawn(5)	// Causes space drifting. /tg/station has no concept of speed, we just use 5
		if(loc && direct && last_move == direct)
			if(loc == newloc) //Remove this check and people can accelerate. Not opening that can of worms just yet.
				newtonian_move(last_move)

//Called after a successful Move(). By this point, we've already moved
/atom/movable/proc/Moved(atom/OldLoc, Dir)
	return 1

/atom/movable/Del()
	if(isnull(gc_destroyed) && loc)
		testing("GC: -- [type] was deleted via del() rather than qdel() --")
//	else if(isnull(gc_destroyed))
//		testing("GC: [type] was deleted via GC without qdel()") //Not really a huge issue but from now on, please qdel()
//	else
//		testing("GC: [type] was deleted via GC with qdel()")
	..()

/atom/movable/Destroy()
	. = ..()
	if(reagents)
		qdel(reagents)
	for(var/atom/movable/AM in contents)
		qdel(AM)
	loc = null
	invisibility = 101
	if (pulledby)
		if (pulledby.pulling == src)
			pulledby.pulling = null
		pulledby = null


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
		var/atom/oldloc = loc
		if(oldloc)
			oldloc.Exited(src, destination)
		loc = destination
		destination.Entered(src, oldloc)
		for(var/atom/movable/AM in destination)
			if(AM == src)	continue
			AM.Crossed(src)
		Moved(oldloc, 0)
		return 1
	return 0

//Called whenever an object moves and by mobs when they attempt to move themselves through space
//And when an object or action applies a force on src, see newtonian_move() below
//Return 0 to have src start/keep drifting in a no-grav area and 1 to stop/not start drifting
//Mobs should return 1 if they should be able to move of their own volition, see client/Move() in mob_movement.dm
//movement_dir == 0 when stopping or any dir when trying to move
/atom/movable/proc/Process_Spacemove(var/movement_dir = 0)
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
	dir = old_dir

/atom/movable/proc/checkpass(passflag)
	return pass_flags&passflag

/atom/movable/proc/hit_check(mob/thrower) // todo: this is partly obsolete due to passflags already, add throwing stuff to mob CanPass and finish it
	if(src.throwing)
		for(var/atom/A in get_turf(src))
			if(A == src) continue
			if(istype(A,/mob/living))
				if(A:lying) continue
				src.throw_impact(A,thrower)
				if(src.throwing == 1)
					src.throwing = 0
			if(isobj(A))
				if(A.density && !A.throwpass)	// **TODO: Better behaviour for windows which are dense, but shouldn't always stop movement
					src.throw_impact(A,thrower)
					src.throwing = 0

/atom/movable/proc/throw_at(atom/target, range, speed, mob/thrower)
	if(!target || !src || (flags & NODROP))	return 0
	//use a modified version of Bresenham's algorithm to get from the atom's current position to that of the target

	src.throwing = 1
	if(target.allow_spin) // turns out 1000+ spinning objects being thrown at the singularity creates lag - Iamgoofball
		SpinAnimation(5, 1)
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
		src.Move(step, get_dir(loc, step))
		hit_check(thrower)
		error += (error < 0) ? tdist_x : -tdist_y;
		dist_travelled++
		dist_since_sleep++
		if(dist_since_sleep >= speed)
			dist_since_sleep = 0
			sleep(1)

	//done throwing, either because it hit something or it finished moving
	src.throwing = 0
	if(isobj(src))
		src.throw_impact(get_turf(src),thrower)

	return 1


//Overlays
/atom/movable/overlay
	var/atom/master = null
	anchored = 1

/atom/movable/overlay/New()
	verbs.Cut()
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
