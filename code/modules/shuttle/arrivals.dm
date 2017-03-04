/obj/docking_port/mobile/arrivals
	name = "arrivals shuttle"
	id = "arrivals"

	dwidth = 3
	width = 7
	height = 15
	dir = WEST
	preferred_direction = WEST
	port_angle = 180
	ignitionTime = 50

	roundstart_move = TRUE	//force a call to dockRoundstart

	var/docked	//docked at arrivals?
	var/damaged	//too damaged to undock?
	var/list/areas	//areas in our shuttle
	var/list/queued_announces	//people coming in that we have to announce
	var/roundstart_docked

/obj/docking_port/mobile/arrivals/Initialize(mapload)
	if(mapload)
		return TRUE	//late initialize to make sure the latejoin list is populated

	..()

	if(SSshuttle.arrivals)
		WARNING("More than one arrivals docking_port placed on map!")
		qdel(src)
		return

	SSshuttle.arrivals = src

	areas = list()

	if(latejoin.len)
		WARNING("Map contains predefined latejoin spawn points and an arrivals shuttle. Using the arrivals shuttle.")

	latejoin = list()
	for(var/area/shuttle/arrival/A in world)
		for(var/obj/structure/chair/C in A)
			latejoin += C
		areas += A

/obj/docking_port/mobile/arrivals/dockRoundstart()
	SSshuttle.generate_transit_dock(src)
	. = dock(assigned_transit)
	roundstart_docked = TRUE

/obj/docking_port/mobile/arrivals/check()
	. = ..()

	var/docked = src.docked

	if(damaged)
		//TODO: repair checks
		return
	//TODO: check for damage
	else if(FALSE)
		damaged = TRUE
		var/obj/machinery/announcement_system/announcer = pick(announcement_systems)
		announcer.announce("ARRIVALS_BROKEN", channels = list())
		if(!docked)
			SendToStation()
		return

	else if(mode != SHUTTLE_IGNITING)
		mode = SHUTTLE_IDLE

		//dock for people on the shuttle
		var/found_awake
		for(var/A in areas)
			for(var/mob/living/L in A)
				//don't dock for braindead'
				if(L.key && L.client && L.stat != DEAD)
					found_awake = TRUE
					break
			if(found_awake)
				break

		if(docked && !found_awake)
			hyperspace_sound(1)
			request(assigned_transit)
		else if(!docked && found_awake)
			SendToStation()

/obj/docking_port/mobile/arrivals/proc/SendToStation()
	if(!docked && mode == SHUTTLE_IDLE)
		request(SSshuttle.getDock("arrivals_stationary"))
		setTimer(config.arrivals_shuttle_dock_window)
		mode = SHUTTLE_CALL

/obj/docking_port/mobile/arrivals/proc/hyperspace_sound(phase)
	var/s
	switch(phase)
		if(1)
			s = 'sound/effects/hyperspace_begin.ogg'
		if(2)
			s = 'sound/effects/hyperspace_progress.ogg'
		if(3)
			s = 'sound/effects/hyperspace_end.ogg'
		else
			CRASH("Invalid hyperspace sound phase: [phase]")
	for(var/A in areas)
		A << s

/obj/docking_port/mobile/arrivals/dock(obj/docking_port/stationary/S1, force=FALSE)
	docked = S1 != assigned_transit
	if(!docked)
		hyperspace_sound(2)
	. = ..()
	if(docked)
		hyperspace_sound(3)
		
	for(var/L in queued_announces)
		AnnounceArrival(arglist(L))
	LAZYCLEARLIST(queued_announces)

/obj/docking_port/mobile/arrivals/proc/RequireUndocked()
	if(docked || damaged)
		return
	if(mode == SHUTTLE_IDLE)
		request(assigned_transit)

	while(docked && !damaged)
		stoplag()

/obj/docking_port/mobile/arrivals/proc/QueueAnnounce(mob, rank)
	LAZYADD(queued_announces, args.Copy())

/obj/docking_port/mobile/arrivals/canDock(obj/docking_port/stationary/S)
	if(docked && damaged)
		return SHUTTLE_ALREADY_DOCKED
	return SHUTTLE_CAN_DOCK

/obj/docking_port/mobile/arrivals/get_docked()
	var/at = assigned_transit
	if(!at)
		return ..()
	return at	//prevent us from losing our spot in transitspace