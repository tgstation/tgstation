// You might be wondering why this isn't client level. If focus is null, we don't want you to move.
// Only way to do that is to tie the behavior into the focus's keyLoop().

/atom/movable/keyLoop(client/user)
	// Clients don't go null randomly. They do go null unexpectedly though, when they're poked in particular ways
	// keyLoop is called by a for loop over mobs. We're guarenteed that all the mobs have clients at the START
	// But the move of one mob might poke the client of another, so we do this
	if(!user)
		return FALSE
	var/movement_dir = user.intended_direction | user.next_move_dir_add
	// If we're not movin anywhere, we aren't movin anywhere
	// Safe because nothing adds to movement_dir after this moment
	if(!movement_dir)
		// No input == our removal would have done nothing
		// So we can safely forget about it
		user.next_move_dir_sub = NONE
		return FALSE

	if(user.next_move_dir_sub)
		movement_dir &= ~user.next_move_dir_sub
	// Sanity checks in case you hold left and right and up to make sure you only go up
	if((movement_dir & NORTH) && (movement_dir & SOUTH))
		movement_dir &= ~(NORTH|SOUTH)
	if((movement_dir & EAST) && (movement_dir & WEST))
		movement_dir &= ~(EAST|WEST)

	if(user.dir != NORTH && movement_dir) //If we're not moving, don't compensate, as byond will auto-fill dir otherwise
		movement_dir = turn(movement_dir, -dir2angle(user.dir)) //By doing this we ensure that our input direction is offset by the client (camera) direction

	//turn without moving while using the movement lock key, unless something wants to ignore it and move anyway
	if(user.movement_locked && !(SEND_SIGNAL(src, COMSIG_MOVABLE_KEYBIND_FACE_DIR, movement_dir) & COMSIG_IGNORE_MOVEMENT_LOCK))
		keybind_face_direction(movement_dir)
	// Null check cause of the signal above
	else if(user)
		user.Move(get_step(src, movement_dir), movement_dir)
		return !!movement_dir //true if there was actually any player input

	return FALSE

/client/proc/calculate_move_dir()
	var/movement_dir = NONE
	for(var/_key in keys_held)
		movement_dir |= movement_keys[_key]
	intended_direction = movement_dir
