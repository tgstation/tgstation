//Helper procs for clockwork power, used by structures and items and that kind of jazz.

/proc/get_clockwork_power(amount) //If no amount is provided, returns the clockwork power; otherwise, returns if there's enough power for that amount.
	return amount ? GLOB.clockwork_power >= amount : GLOB.clockwork_power

/proc/adjust_clockwork_power(amount) //Adjusts the global clockwork power by this amount (min 0.)
	if(GLOB.ratvar_approaches)
		amount *= 0.75 //The herald's beacon reduces power costs by 25% across the board!
	GLOB.clockwork_power = GLOB.ratvar_awakens ? INFINITY : max(0, GLOB.clockwork_power + amount)
	for(var/obj/effect/clockwork/sigil/transmission/T in GLOB.all_clockwork_objects)
		T.update_icon()
	return TRUE

/proc/can_access_clockwork_power(atom/movable/access_point, amount) //Returns true if the access point has access to clockwork power (and optionally, a number of watts for it)
	if(amount && !get_clockwork_power(amount)) //No point in trying if we don't have the power anyway
		return
	var/list/possible_conduits = view(5, access_point)
	return locate(/obj/effect/clockwork/sigil/transmission) in possible_conduits || GLOB.ratvar_awakens
