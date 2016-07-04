// You might be wondering why this isn't client level. If focus is null, we don't want you to move.
// Only way to do that is to tie the behavior into the focus's keyLoop().

/atom/movable/keyLoop(client/user)
	if(!user.keys_held["ctrl"])
		var/movement_dir = 0
		for(var/_key in user.keys_held)
			movement_dir |= movement_keys[_key]
		for(var/cardinaldir in cardinal)
			if(user.next_move_dir_add & cardinaldir)
				movement_dir |= cardinaldir
			if(user.next_move_dir_sub & cardinaldir)
				movement_dir &= ~cardinaldir
		// Sanity checks in case you hold left and right and up to make sure you only go up
		if((movement_dir & NORTH) && (movement_dir & SOUTH))
			movement_dir &= ~(NORTH|SOUTH)
		if((movement_dir & EAST) && (movement_dir & WEST))
			movement_dir &= ~(EAST|WEST)

		user.Move(get_step(src, movement_dir), movement_dir)