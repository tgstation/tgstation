/atom
	layer = 2
	var/level = 2
	var/flags = FPRINT
	var/fingerprints = null
	var/list/fingerprintshidden = new/list()
	var/fingerprintslast = null
	var/blood_DNA = null
	var/blood_type = null
	var/last_bumped = 0

	///Chemistry.
	var/datum/reagents/reagents = null

	//var/chem_is_open_container = 0
	// replaced by OPENCONTAINER flags and atom/proc/is_open_container()
	///Chemistry.

	proc/assume_air(datum/air_group/giver)
		del(giver)
		return null

	proc/remove_air(amount)
		return null

	proc/return_air()
		return null


// Convenience proc to see if a container is open for chemistry handling
// returns true if open
// false if closed
	proc/is_open_container()
		return flags & OPENCONTAINER


obj
	assume_air(datum/air_group/giver)
		if(loc)
			return loc.assume_air(giver)
		else
			return null

	remove_air(amount)
		if(loc)
			return loc.remove_air(amount)
		else
			return null

	return_air()
		if(loc)
			return loc.return_air()
		else
			return null

/atom/proc/meteorhit(obj/meteor as obj)
	return

/atom/proc/allow_drop()
	return 1

/atom/proc/CheckExit()
	return 1

/atom/proc/HasEntered(atom/movable/AM as mob|obj)
	return

/atom/proc/HasProximity(atom/movable/AM as mob|obj)
	return

/atom/movable/overlay/attackby(a, b)
	if (src.master)
		return src.master.attackby(a, b)
	return

/atom/movable/overlay/attack_paw(a, b, c)
	if (src.master)
		return src.master.attack_paw(a, b, c)
	return

/atom/movable/overlay/attack_hand(a, b, c)
	if (src.master)
		return src.master.attack_hand(a, b, c)
	return

/atom/movable/overlay/New()
	for(var/x in src.verbs)
		src.verbs -= x
	return


/atom/movable
	layer = 3
	var/last_move = null
	var/anchored = 0
	// var/elevation = 2    - not used anywhere
	var/move_speed = 10
	var/l_move_time = 1
	var/m_flag = 1
	var/throwing = 0
	var/throw_speed = 2
	var/throw_range = 7
	var/moved_recently = 0

/atom/movable/overlay
	var/atom/master = null
	anchored = 1

/atom/movable/Move()
	var/atom/A = src.loc
	. = ..()
	src.move_speed = world.timeofday - src.l_move_time
	src.l_move_time = world.timeofday
	src.m_flag = 1
	if ((A != src.loc && A && A.z == src.z))
		src.last_move = get_dir(A, src.loc)
		src.moved_recently = 1
	return
////////////

