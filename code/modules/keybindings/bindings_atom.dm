
/atom/movable/key_loop(client/user)

// This entire block is me being lazy and not wanting to handle Client/Move() and its shit.
// This logic should be atom/movable/key_loop() and call various procs that get redefined at the various mob levels like mob.movement_delay()

	if(!user.keys_active["ctrl"]) // Control is used to change facing in mobs, so don't move if holding control
		var/movement_dir = 0
		for(var/key in user.keys_active)
			if(movement_keys[key])
				movement_dir |= movement_keys[key]

		// sanity checks in case you hold left and right and up to make sure you only go up
		if(movement_dir & (NORTH|SOUTH))
			movement_dir &= ~(NORTH|SOUTH)
		if(movement_dir & (EAST|WEST))
			movement_dir &= ~(EAST|WEST)

		if(movement_dir)
			var/oldloc = loc
			var/olddelay = user.move_delay

			if(src == user.mob)
				user.Move(get_step(src, movement_dir), movement_dir)
			else if(density)
				loc = get_step(src, movement_dir)
			else
				step(src, movement_dir)

			// Without this, things with no movement delay (ghosts, possessed objects, AI eye) move way too fast to be usable
			// This is a band-aid fix to the real problem that those things aren't getting movement delays when they should!
			if(loc != oldloc && user.move_delay == olddelay)
				user.move_delay += world.tick_lag


	return ..()