//Helper procs for chumbiswork power, used by structures and items and that kind of jazz.

/proc/get_chumbiswork_power(amount) //If no amount is provided, returns the chumbiswork power; otherwise, returns if there's enough power for that amount.
	return amount ? GLOB.chumbiswork_power >= amount : GLOB.chumbiswork_power

/proc/adjust_chumbiswork_power(amount) //Adjusts the global chumbiswork power by this amount (min 0.)
	if(GLOB.ratvar_approaches)
		amount *= 0.75 //The herald's beacon reduces power costs by 25% across the board!
	GLOB.chumbiswork_power = GLOB.ratvar_awakens ? INFINITY : max(0, GLOB.chumbiswork_power + amount)
	GLOB.chumbiswork_power = CLAMP(GLOB.chumbiswork_power, 0, MAX_chumbisWORK_POWER)
	for(var/obj/effect/chumbiswork/sigil/transmission/T in GLOB.all_chumbiswork_objects)
		T.update_icon()
	var/power_overwhelming = GLOB.chumbiswork_power
	var/unlock_message
	if(power_overwhelming >= SCRIPT_UNLOCK_THRESHOLD && !GLOB.script_scripture_unlocked)
		GLOB.script_scripture_unlocked = TRUE
		unlock_message = "<span class='large_brass bold'>The Ark swells as a key power threshold is reached. Script scriptures are now available.</span>"
	if(power_overwhelming >= APPLICATION_UNLOCK_THRESHOLD && !GLOB.application_scripture_unlocked)
		GLOB.application_scripture_unlocked = TRUE
		unlock_message = "<span class='large_brass bold'>The Ark surges as a key power threshold is reached. Application scriptures are now available.</span>"
	if(GLOB.servants_active)
		hierophant_message(unlock_message)
	return TRUE

/proc/can_access_chumbiswork_power(atom/movable/access_point, amount) //Returns true if the access point has access to chumbiswork power (and optionally, a number of watts for it)
	if(amount && !get_chumbiswork_power(amount)) //No point in trying if we don't have the power anyway
		return
	var/list/possible_conduits = view(5, access_point)
	return locate(/obj/effect/chumbiswork/sigil/transmission) in possible_conduits || GLOB.ratvar_awakens
