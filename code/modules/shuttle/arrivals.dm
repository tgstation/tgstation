/obj/docking_port/mobile/arrivals
	name = "arrivals shuttle"
	id = "arrivals"

	dwidth = 3
	width = 7
	height = 15
	dir = WEST
	port_angle = 180

	callTime = INFINITY
	ignitionTime = 50

	roundstart_move = TRUE	//force a call to dockRoundstart

	var/sound_played
	var/damaged	//too damaged to undock?
	var/list/areas	//areas in our shuttle
	var/list/queued_announces	//people coming in that we have to announce
	var/obj/machinery/requests_console/console

/obj/docking_port/mobile/arrivals/Initialize(mapload)
	preferred_direction = dir
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
	for(var/area/shuttle/arrival/A in sortedAreas)
		for(var/obj/structure/chair/C in A)
			latejoin += C
		if(!console)
			console = locate(/obj/machinery/requests_console) in A
		areas += A

/obj/docking_port/mobile/arrivals/dockRoundstart()
	SSshuttle.generate_transit_dock(src)
	Launch()
	timer = world.time
	check()
	return TRUE

/obj/docking_port/mobile/arrivals/check()
	. = ..()

	if(damaged)
		//TODO: repair checks
		return
	//TODO: check for damage
	else if(FALSE)
		damaged = TRUE
		var/obj/machinery/announcement_system/announcer = pick(announcement_systems)
		announcer.announce("ARRIVALS_BROKEN", channels = list())
		if(mode == SHUTTLE_CALL)
			SendToStation()
		return


	var/found_awake = PersonCheck()
	if(mode == SHUTTLE_CALL)
		if(found_awake)
			SendToStation()
	else if(mode == SHUTTLE_IGNITING)
		if(found_awake)
			mode = SHUTTLE_IDLE
		else if(!sound_played)
			hyperspace_sound(HYPERSPACE_WARMUP, areas)
			sound_played = TRUE
	else if(!found_awake)
		Launch(FALSE)


/obj/docking_port/mobile/arrivals/proc/PersonCheck()
	for(var/A in areas)
		for(var/mob/living/L in A)
			//don't dock for braindead'
			if(L.key && L.client && L.stat != DEAD)
				return TRUE

/obj/docking_port/mobile/arrivals/proc/SendToStation()
	var/dockTime = config.arrivals_shuttle_dock_window
	if(mode == SHUTTLE_CALL && timeLeft(1) > dockTime)
		if(console)
			console.say(damaged ? "Initiating emergency docking for repairs!" : "Now approaching: [MAP_NAME].")
		hyperspace_sound(HYPERSPACE_LAUNCH, areas)	//for the new guy
		setTimer(dockTime)

/obj/docking_port/mobile/arrivals/dock(obj/docking_port/stationary/S1, force=FALSE)
	var/docked = S1 == assigned_transit
	sound_played = FALSE
	if(docked)	//about to launch
		if(PersonCheck())
			mode = SHUTTLE_IDLE
			return
	. = ..()
	if(!. && !docked)
		console.say("Welcome to your new life, employees!")
		for(var/L in queued_announces)
			var/datum/callback/C = L
			C.Invoke()
		LAZYCLEARLIST(queued_announces)

/obj/docking_port/mobile/arrivals/check_effects()
	..()
	if(!sound_played && timeLeft(1) <= HYPERSPACE_END_TIME)
		sound_played = TRUE
		hyperspace_sound(HYPERSPACE_END, areas)

/obj/docking_port/mobile/arrivals/canDock(obj/docking_port/stationary/S)
	. = ..()
	if(. == SHUTTLE_ALREADY_DOCKED)
		. = SHUTTLE_CAN_DOCK

/obj/docking_port/mobile/arrivals/proc/Launch(pickingup)
	if(mode != SHUTTLE_CALL)
		if(console)
			console.say(pickingup ? "Departing immediately for new employee pickup." : "Shuttle departing.")
		request(SSshuttle.getDock("arrivals_stationary"))		//we will intentionally never return SHUTTLE_ALREADY_DOCKED

/obj/docking_port/mobile/arrivals/proc/RequireUndocked(mob/user)
	if(mode != SHUTTLE_CALL || damaged)
		return
	
	Launch(TRUE)

	user << "<span class='notice'>Calling your shuttle. One moment...</span>"
	while(mode != SHUTTLE_CALL && !damaged)
		stoplag()

/obj/docking_port/mobile/arrivals/proc/QueueAnnounce(mob, rank)
	LAZYINITLIST(queued_announces)
	queued_announces.Add(CALLBACK(GLOBAL_PROC, .proc/AnnounceArrival, mob, rank))

/obj/docking_port/mobile/arrivals/enterTransit()
	testing("Arrivals entering transit")
	..()