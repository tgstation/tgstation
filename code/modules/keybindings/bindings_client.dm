// Clients aren't datums so we have to define these procs indpendently.
// These verbs are called for all key press and release events
/client/verb/keyDown(_key as text)
	set instant = TRUE
	set hidden = TRUE

	var/datum/keybindings/bind = prefs.bindings

	bind.set_key_down(_key)
	var/movement = bind.get_movement_dir(_key)
	if(!(next_move_dir_sub & movement) && !bind.isheld_key("Ctrl"))
		next_move_dir_add |= movement

	// Client-level keybindings are ones anyone should be able to do at any time
	// Things like taking screenshots, hitting tab, and adminhelps.

	var/A = bind.get_key_action(_key) // TODO: runtime here
	if(!A)
		return

	switch(A)
		if(ACTION_AHELP)
			get_adminhelp()
			return
		if(ACTION_SCREENSHOT) // Screenshot. Hold shift to choose a name and location to save in
			winset(src, null, "command=.screenshot [!bind.isheld_key("shift") ? "auto" : ""]")
			return
		if(ACTION_MINHUD) // Toggles minimal HUD
			mob.button_pressed_F12()
			return
		if(ACTION_OOC)
			get_ooc()
			return
			
	var/datum/keyinfo/I = bind.to_keyinfo(_key, A)

	if(holder)
		holder.key_down(I, src)
	if(mob.focus)
		mob.focus.key_down(I, src)

/client/verb/keyUp(_key as text)
	set instant = TRUE
	set hidden = TRUE

	var/datum/keybindings/bind = prefs.bindings

	bind.set_key_up(_key)
	var/movement = bind.get_movement_dir(_key)
	if(!(next_move_dir_add & movement))
		next_move_dir_sub |= movement

	var/A = bind.get_key_action(_key)
	if(!A)
		return

	var/datum/keyinfo/I = bind.to_keyinfo(_key, A)

	if(holder)
		holder.key_up(I, src)
	if(mob.focus)
		mob.focus.key_up(I, src)

// Called every game tick
/client/keyLoop()
	if(holder)
		holder.keyLoop(src)
	if(mob.focus)
		mob.focus.keyLoop(src)

/client/proc/get_ooc()
	var/msg = input(src, null, "ooc \"text\"") as text|null
	ooc(msg)