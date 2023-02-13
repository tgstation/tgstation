/turf/open/space/transit
	name = "\proper hyperspace"
	desc = "What is this, light-speed? We need to go to plaid speed!"  // spaceballs was a great movie
	icon_state = "black"
	dir = SOUTH
	baseturfs = /turf/open/space/transit
	flags_1 = NOJAUNT //This line goes out to every wizard that ever managed to escape the den. I'm sorry.
	explosive_resistance = INFINITY

/turf/open/space/transit/Initialize(mapload)
	. = ..()
	update_appearance()
	RegisterSignal(src, COMSIG_TURF_RESERVATION_RELEASED, PROC_REF(launch_contents))

	for(var/atom/movable/movable in src)
		throw_atom(movable)

/turf/open/space/transit/Destroy()
	//Signals are NOT removed from turfs upon replacement, and we get replaced ALOT, so unregister our signal
	UnregisterSignal(src, COMSIG_TURF_RESERVATION_RELEASED)
	return ..()

/turf/open/space/transit/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	. = ..()
	underlay_appearance.icon_state = "speedspace_ns_[get_transit_state(asking_turf)]"
	underlay_appearance.transform = turn(matrix(), get_transit_angle(asking_turf))

/turf/open/space/transit/update_icon()
	. = ..()
	transform = turn(matrix(), get_transit_angle(src))

/turf/open/space/transit/update_icon_state()
	icon_state = "speedspace_ns_[get_transit_state(src)]"
	return ..()

/turf/open/space/transit/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()

	if(!HAS_TRAIT(arrived, TRAIT_HYPERSPACED) && !HAS_TRAIT(arrived, TRAIT_FREE_HYPERSPACE_MOVEMENT))
		arrived.AddComponent(/datum/component/shuttle_cling, turn(dir, 180), old_loc)

/turf/open/space/transit/Exited(atom/movable/gone, direction)
	. = ..()

	var/turf/location = gone.loc
	if(istype(location, /turf/open/space) && !istype(location, src.type))//they got forced out of transit area into default space tiles
		throw_atom(gone) //launch them into game space, away from transitspace

///Get rid of all our contents, called when our reservation is released (which in our case means the shuttle arrived)
/turf/open/space/transit/proc/launch_contents(datum/turf_reservation/reservation)
	SIGNAL_HANDLER

	for(var/atom/movable/movable in contents)
		throw_atom(movable)

/turf/open/space/transit/proc/throw_atom(atom/movable/AM)
	if(!AM || istype(AM, /obj/docking_port) || istype(AM, /obj/effect/abstract))
		return
	var/max = world.maxx-TRANSITIONEDGE
	var/min = 1+TRANSITIONEDGE

	var/list/possible_transtitons = list()
	for(var/A in SSmapping.z_list)
		var/datum/space_level/D = A
		if (D.linkage == CROSSLINKED)
			possible_transtitons += D.z_value
	if(!length(possible_transtitons)) //No space to throw them to - try throwing them onto mining
		possible_transtitons = SSmapping.levels_by_trait(ZTRAIT_MINING)
		if(!length(possible_transtitons)) //Just throw them back on station, if not just runtime.
			possible_transtitons = SSmapping.levels_by_trait(ZTRAIT_STATION)
	var/_z = pick(possible_transtitons)

	//now select coordinates for a border turf
	var/_x
	var/_y
	switch(dir)
		if(SOUTH)
			_x = rand(min,max)
			_y = max
		if(WEST)
			_x = max
			_y = rand(min,max)
		if(EAST)
			_x = min
			_y = rand(min,max)
		else
			_x = rand(min,max)
			_y = min

	var/turf/T = locate(_x, _y, _z)
	AM.forceMove(T)

/turf/open/space/transit/CanBuildHere()
	return SSshuttle.is_in_shuttle_bounds(src)

/turf/open/space/transit/south
	dir = SOUTH

/turf/open/space/transit/north
	dir = NORTH

/turf/open/space/transit/horizontal
	dir = WEST

/turf/open/space/transit/west
	dir = WEST

/turf/open/space/transit/east
	dir = EAST

/proc/get_transit_state(turf/T)
	var/p = 9
	. = 1
	switch(T.dir)
		if(NORTH)
			. = ((-p*T.x+T.y) % 15) + 1
			if(. < 1)
				. += 15
		if(EAST)
			. = ((T.x+p*T.y) % 15) + 1
		if(WEST)
			. = ((T.x-p*T.y) % 15) + 1
			if(. < 1)
				. += 15
		else
			. = ((p*T.x+T.y) % 15) + 1

/proc/get_transit_angle(turf/T)
	. = 0
	switch(T.dir)
		if(NORTH)
			. = 180
		if(EAST)
			. = 90
		if(WEST)
			. = -90
