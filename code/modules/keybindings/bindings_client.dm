// Clients aren't datums so we have to define these procs indpendently.
// These verbs are called for all key press and release events
/client/verb/keyDown(_key as text)
	set instant = TRUE
	set hidden = TRUE

	client_keysend_amount += 1
		
	var/cache = client_keysend_amount

	if(keysend_tripped && next_keysend_trip_reset <= world.time)
		keysend_tripped = FALSE

	if(next_keysend_reset <= world.time)
		client_keysend_amount = 0
		next_keysend_reset = world.time + (1 SECONDS)

	//The "tripped" system is to confirm that flooding is still happening after one spike
	//not entirely sure how byond commands interact in relation to lag
	//don't want to kick people if a lag spike results in a huge flood of commands being sent
	if(cache >= MAX_KEYPRESS_AUTOKICK)
		if(!keysend_tripped)
			keysend_tripped = TRUE		
			next_keysend_trip_reset = world.time + (2 SECONDS)
		else
			log_admin("Client [ckey] was just autokicked for flooding keysends; likely abuse but potentially lagspike.")
			message_admins("Client [ckey] was just autokicked for flooding keysends; likely abuse but potentially lagspike.")
			QDEL_IN(src, 1)
			return

	///Check if the key is short enough to even be a real key
	if(LAZYLEN(_key) > MAX_KEYPRESS_COMMANDLENGTH)
		to_chat(src, "<span class='userdanger'>Invalid KeyDown detected! You have been disconnected from the server automatically.</span>")
		log_admin("Client [ckey] just attempted to send an invalid keypress. Keymessage was over [MAX_KEYPRESS_COMMANDLENGTH] characters, autokicking due to likely abuse.")
		message_admins("Client [ckey] just attempted to send an invalid keypress. Keymessage was over [MAX_KEYPRESS_COMMANDLENGTH] characters, autokicking due to likely abuse.")
		QDEL_IN(src, 1)
		return
	//offset by 1 because the buffer address is 0 indexed because the math was simpler
	keys_held[current_key_address + 1] = _key
	//the time a key was pressed isn't actually used anywhere (as of 2019-9-10) but this allows easier access usage/checking
	keys_held[_key] = world.time
	current_key_address = ((current_key_address + 1) % HELD_KEY_BUFFER_LENGTH)
	var/movement = SSinput.movement_keys[_key]
	if(!(next_move_dir_sub & movement) && !keys_held["Ctrl"])
		next_move_dir_add |= movement

	// Client-level keybindings are ones anyone should be able to do at any time
	// Things like taking screenshots, hitting tab, and adminhelps.

	switch(_key)
		if("F1")
			if(keys_held["Ctrl"] && keys_held["Shift"]) // Is this command ever used?
				winset(src, null, "command=.options")
			else
				get_adminhelp()
			return
		if("F2") // Screenshot. Hold shift to choose a name and location to save in
			winset(src, null, "command=.screenshot [!keys_held["shift"] ? "auto" : ""]")
			return
		if("F12") // Toggles minimal HUD
			mob.button_pressed_F12()
			return

	if(holder)
		holder.key_down(_key, src)
	if(mob.focus)
		mob.focus.key_down(_key, src)

/client/verb/keyUp(_key as text)
	set instant = TRUE
	set hidden = TRUE

	//Can't just do a remove because it would alter the length of the rolling buffer, instead search for the key then null it out if it exists
	for(var/i in 1 to HELD_KEY_BUFFER_LENGTH)
		if(keys_held[i] == _key)
			keys_held[i] = null
			break
	var/movement = SSinput.movement_keys[_key]
	if(!(next_move_dir_add & movement))
		next_move_dir_sub |= movement

	if(holder)
		holder.key_up(_key, src)
	if(mob.focus)
		mob.focus.key_up(_key, src)

// Called every game tick
/client/keyLoop()
	if(holder)
		holder.keyLoop(src)
	if(mob?.focus)
		mob.focus.keyLoop(src)
