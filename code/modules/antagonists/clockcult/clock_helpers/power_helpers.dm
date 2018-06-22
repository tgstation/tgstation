//Helper procs for clockwork power, used by structures and items and that kind of jazz.

/proc/get_clockwork_power(amount) //If no amount is provided, returns the clockwork power; otherwise, returns if there's enough power for that amount.
	return amount ? GLOB.clockwork_power >= amount : GLOB.clockwork_power

/proc/adjust_clockwork_power(amount) //Adjusts the global clockwork power by this amount (min 0.)
	var/current_power
	if(GLOB.ratvar_approaches)
		amount *= 0.75 //The herald's beacon reduces power costs by 25% across the board!
	if(GLOB.ratvar_awakens)
		current_power = GLOB.clockwork_power = INFINITY
	else
		current_power = GLOB.clockwork_power = CLAMP(GLOB.clockwork_power + amount, 0, MAX_CLOCKWORK_POWER)
	for(var/obj/effect/clockwork/sigil/transmission/T in GLOB.all_clockwork_objects)
		T.update_icon()
	var/unlock_message
	if(current_power >= SCRIPT_UNLOCK_THRESHOLD && !GLOB.script_scripture_unlocked)
		GLOB.script_scripture_unlocked = TRUE
		unlock_message = "<span class='large_brass bold'>The Ark swells as a key power threshold is reached. Script scriptures are now available.</span>"
	if(current_power >= APPLICATION_UNLOCK_THRESHOLD && !GLOB.application_scripture_unlocked)
		GLOB.application_scripture_unlocked = TRUE
		unlock_message = "<span class='large_brass bold'>The Ark surges as a key power threshold is reached. Application scriptures are now available.</span>"
	if(unlock_message && GLOB.servants_active)
		hierophant_message(unlock_message)
	return TRUE

/proc/can_access_clockwork_power(atom/movable/access_point, amount) //Returns true if the access point has access to clockwork power (and optionally, a number of watts for it)
	if(amount && !get_clockwork_power(amount)) //No point in trying if we don't have the power anyway
		return
	var/list/possible_conduits = view(5, access_point)
	return locate(/obj/effect/clockwork/sigil/transmission) in possible_conduits || GLOB.ratvar_awakens
