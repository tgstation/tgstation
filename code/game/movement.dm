//Movement could literally be its own module
//Dir isn't actually the direction of movement, it's the direction the object should face after finishing the move
/atom/movable/Move(atom/NewLoc, Dir = 0)
	if(!loc || !NewLoc || loc == NewLoc)
		return 0
	var/atom/OldLoc = loc
	var/direct = get_dir(src, NewLoc) //direct is the actual direction of movement
	if(!Dir)
		Dir = direct

	if(moving_flags & (KEEP_DIRECTION | FIRST_DIAG_STEP | SECOND_DIAG_STEP))
		Dir = dir
	else if(Dir && dir != Dir)
		setDir(Dir)

	if(!(direct & (direct - 1))) //Cardinal move
		. = ..()
	else //Diagonal move, split it into cardinal moves
		moving_flags |= FIRST_DIAG_STEP
		if(direct & NORTH)
			if(direct & EAST)
				if(Move(get_step(src, NORTH), NORTH))
					moving_flags |= SECOND_DIAG_STEP
					moving_flags &= ~FIRST_DIAG_STEP
					. = Move(get_step(src, EAST), EAST)
				else if(Move(get_step(src, EAST), EAST))
					moving_flags |= SECOND_DIAG_STEP
					moving_flags &= ~FIRST_DIAG_STEP
					. = Move(get_step(src, NORTH), NORTH)
			else if(direct & WEST)
				if(Move(get_step(src, NORTH), NORTH))
					moving_flags |= SECOND_DIAG_STEP
					moving_flags &= ~FIRST_DIAG_STEP
					. = Move(get_step(src, WEST), WEST)
				else if(Move(get_step(src, WEST), WEST))
					moving_flags |= SECOND_DIAG_STEP
					moving_flags &= ~FIRST_DIAG_STEP
					. = Move(get_step(src, NORTH), NORTH)
		else if(direct & SOUTH)
			if(direct & EAST)
				if(Move(get_step(src, SOUTH), SOUTH))
					moving_flags |= SECOND_DIAG_STEP
					moving_flags &= ~FIRST_DIAG_STEP
					. = Move(get_step(src, EAST), EAST)
				else if(Move(get_step(src, EAST), EAST))
					moving_flags |= SECOND_DIAG_STEP
					moving_flags &= ~FIRST_DIAG_STEP
					. = Move(get_step(src, SOUTH), SOUTH)
			else if(direct & WEST)
				if(Move(get_step(src, SOUTH), SOUTH))
					moving_flags |= SECOND_DIAG_STEP
					moving_flags &= ~FIRST_DIAG_STEP
					. = Move(get_step(src, WEST), WEST)
				else if(Move(get_step(src, WEST), WEST))
					moving_flags |= SECOND_DIAG_STEP
					moving_flags &= ~FIRST_DIAG_STEP
					. = Move(get_step(src, SOUTH), SOUTH)
		moving_flags &= ~(FIRST_DIAG_STEP|SECOND_DIAG_STEP)
		return

	if(!loc || loc == OldLoc)
		return 0

	if(. && has_buckled_mobs() && !handle_buckled_mob_movement(loc, direct)) //movement failed due to buckled mob(s)
		. = 0

	if(.)
		Moved(OldLoc)

//Called after a successful Move(). By this point, we've already moved
/atom/movable/proc/Moved(atom/OldLoc)
	set waitfor = FALSE
	last_move = dir
	if(!CANATMOSPASS(src, OldLoc)) //air blocker left the tile
		move_update_air(OldLoc)
	if (!inertia_moving)
		inertia_next_move = world.time + inertia_move_delay
		newtonian_move(dir)
	if (length(client_mobs_in_contents))
		update_parallax_contents()

	if (orbiters)
		for (var/thing in orbiters)
			var/datum/orbit/O = thing
			O.Check()
	if (orbiting)
		orbiting.Check()

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

		Moved(oldloc)
		return 1
	return 0