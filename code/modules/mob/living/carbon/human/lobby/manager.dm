/datum/lobby_manager
	var/list/lights = list()
	var/list/shutters = list()
	var/list/announcers = list()

	var/list/hub_spawners = list()
	var/list/wall_spawners = list()

	var/list/poll_computers = list()
	
	var/list/spawn_landmarks = list()
	var/list/ready_landmarks = list()

	var/process_started = FALSE
	var/process_complete = FALSE

/datum/lobby_manager/proc/BeginProcess()
	set waitfor = FALSE

	if(process_started)
		return
	process_started = TRUE

	var/obj/docking_port/mobile/crew/shuttle
	var/you_had_your_chance = !SSticker.start_immediately	//if "Start Now" is clicked after this, you still gotta do wait for this sequence
	if(you_had_your_chance)
		shuttle = SSshuttle.getShuttle("crew_shuttle")
		if(!shuttle)
			process_complete = TRUE
			CRASH("Unable to find crew shuttle!")

		//dock crew shuttle
		shuttle.StopFlying()

		for(var/I in announcers)
			var/obj/O = I
			O.say("We have arrived at [station_name()]. Crew assigned to this outpost please report to the back area of the shuttle immediately.")

		UNTIL(SSticker.GetTimeLeft() < 150)

		for(var/I in lights)
			var/turf/open/floor/light/lobby/L = I
			L.WarningSequence()

		UNTIL(SSticker.GetTimeLeft() < 50)

		for(var/I in 1 to shutters.len)
			if(I == shutters.len)
				var/obj/machinery/door/door = shutters[I]
				door.close()    //wait on the last one
			else
				INVOKE_ASYNC(shutters[I], /obj/machinery/door/proc/close)
	
	process_complete = TRUE

	if(you_had_your_chance)
		for(var/I in lights)
			var/turf/open/floor/light/lobby/L = I
			L.Normalize()
			CHECK_TICK
		
		sleep(30)

	lights.Cut()

	if(you_had_your_chance)
		UNTIL(SSticker.setup_done)

		for(var/I in announcers)
			var/obj/O = I
			O.say("Returning to CentCom.")

		shuttle.Launch()

		sleep(50)

		for(var/I in announcers)
			var/obj/O = I
			O.say("Employees destined for space station 13 please take the teleporter to the next en-route shuttle in the back.")
	announcers.Cut()

	if(you_had_your_chance)
		sleep(10)

	for(var/I in hub_spawners)
		var/turf/T = get_turf(I)
		T.ChangeTurf(/turf/open/floor/light/lobby)
		new /obj/structure/lobby_teleporter(T)
		if(you_had_your_chance)
			CHECK_TICK

	for(var/I in wall_spawners)
		var/turf/T = get_turf(I)
		qdel(I)
		//because otherwise it leaves weirdness at the corners
		T.PlaceOnTop(/turf/closed/wall/mineral/titanium/nodiagonal)
		if(you_had_your_chance)
			CHECK_TICK
	QDEL_LIST(wall_spawners)

	if(you_had_your_chance)
		for(var/I in 1 to shutters.len)
			if(I == shutters.len)
				var/obj/machinery/door/door = shutters[I]
				door.open()    //wait on the last one
			else
				INVOKE_ASYNC(shutters[I], /obj/machinery/door/proc/open)
	shutters.Cut()

/datum/lobby_manager/proc/AtRoundEnd()
	for(var/I in hub_spawners)
		var/obj/structure/lobby_teleporter/T = locate() in get_turf(I)
		if(T)
			//look off
			T.icon_state = "tele1"

/datum/lobby_manager/proc/GetRandomTeleporter()
	return locate(/obj/structure/lobby_teleporter) in get_turf(safepick(hub_spawners))