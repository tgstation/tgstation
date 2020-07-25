// You might be wondering why this isn't client level. If focus is null, we don't want you to move.
// Only way to do that is to tie the behavior into the focus's keyLoop().

/atom/movable/keyLoop(client/user)
	if(!user.keys_held["Ctrl"] || user.keys_held["Alt"])
		var/movement_dir
		for(var/_key in user.keys_held)
			movement_dir = movement_dir | user.movement_keys[_key]
		switch(movement_dir) // Yeah this is ugly but better performance wise
			if(NORTH)
				user.North()
			if(NORTHEAST)
				user.Northeast()
			if(EAST)
				user.East()
			if(SOUTHEAST)
				user.Southeast()
			if(SOUTH)
				user.South()
			if(SOUTHWEST)
				user.Southwest()
			if(WEST)
				user.West()
			if(NORTHWEST)
				user.Northwest()
