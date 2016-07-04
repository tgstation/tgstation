// Clients aren't datums so we have to define these procs indpendently.
// These verbs are called for all key press and release events
/client/verb/keyDown(_key as text)
	set instant = 1
	set hidden = 1

	keys_held[_key] = world.time
	var/movement = movement_keys[_key]
	if(!(next_move_dir_sub & movement))
		next_move_dir_add |= movement

	// Client-level keybindings are ones anyone should be able to do at any time
	// Things like taking screenshots, hitting tab, and adminhelps.

	switch(_key)
		if("F1")
			if(keys_held["ctrl"] && keys_held["shift"]) // Is this command ever used?
				winset(src, null, "command=.options")
			else
				adminhelp()
		if("F2") // Screenshot. Hold shift to choose a name and location to save in
			winset(src, null, "command=.screenshot [!keys_held["shift"] ? "auto" : ""]")
		if("F12") // Toggles minimal HUD
			mob.button_pressed_F12()
	if(holder)
		holder.keyDown(_key, src)
	if(mob.focus)
		mob.focus.keyDown(_key, src)

/client/verb/keyUp(_key as text)
	set instant = 1
	set hidden = 1

	keys_held -= _key
	var/movement = movement_keys[_key]
	if(!(next_move_dir_add & movement))
		next_move_dir_sub |= movement

	if(holder)
		holder.keyUp(_key, src)
	if(mob.focus)
		mob.focus.keyUp(_key, src)

// Called every game tick
/client/proc/keyLoop()
	if(holder)
		holder.keyLoop(src)
	if(mob.focus)
		mob.focus.keyLoop(src)