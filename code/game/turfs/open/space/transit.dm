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
	RegisterSignal(src, COMSIG_ATOM_ENTERED, PROC_REF(initialize_drifting))
	RegisterSignal(src, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(initialize_drifting_but_from_initialize))

/turf/open/space/transit/Destroy()
	//Signals are NOT removed from turfs upon replacement, and we get replaced ALOT, so unregister our signal
	UnregisterSignal(src, list(COMSIG_TURF_RESERVATION_RELEASED, COMSIG_ATOM_ENTERED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON))

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

/turf/open/space/transit/proc/initialize_drifting(atom/entered, atom/movable/enterer)
	SIGNAL_HANDLER

	if(enterer && !HAS_TRAIT(enterer, TRAIT_HYPERSPACED))
		enterer.AddComponent(/datum/component/shuttle_cling, REVERSE_DIR(dir))

/turf/open/space/transit/proc/initialize_drifting_but_from_initialize(atom/movable/location, atom/movable/enterer, mapload)
	SIGNAL_HANDLER

	if(!mapload && !istype(enterer, /obj/docking_port) && !enterer.anchored)
		INVOKE_ASYNC(src, PROC_REF(initialize_drifting), src, enterer)

/turf/open/space/transit/Exited(atom/movable/gone, direction)
	. = ..()

	var/turf/location = gone.loc
	if(istype(location, /turf/open/space) && !istype(location, src.type))//they got forced out of transit area into default space tiles
		dump_in_space(gone) //launch them into game space, away from transitspace

///Get rid of all our contents, called when our reservation is released (which in our case means the shuttle arrived)
/turf/open/space/transit/proc/launch_contents(datum/turf_reservation/reservation)
	SIGNAL_HANDLER

	for(var/atom/movable/movable in contents)
		dump_in_space(movable)

///Dump a movable in a random valid spacetile
/proc/dump_in_space(atom/movable/dumpee)
	if(HAS_TRAIT(dumpee, TRAIT_DEL_ON_SPACE_DUMP))
		qdel(dumpee)
		return

	var/max = world.maxx-TRANSITIONEDGE
	var/min = 1+TRANSITIONEDGE

	var/list/possible_transtitons = list()
	for(var/datum/space_level/level as anything in SSmapping.z_list)
		if (level.linkage == CROSSLINKED)
			possible_transtitons += level.z_value
	if(!length(possible_transtitons)) //No space to throw them to - try throwing them onto mining
		possible_transtitons = SSmapping.levels_by_trait(ZTRAIT_MINING)
		if(!length(possible_transtitons)) //Just throw them back on station, if not just runtime.
			possible_transtitons = SSmapping.levels_by_trait(ZTRAIT_STATION)

	//move the dumpee to a random coordinate turf
	dumpee.forceMove(locate(rand(min,max), rand(min,max), pick(possible_transtitons)))

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
