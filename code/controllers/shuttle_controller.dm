//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

// Controls the emergency shuttle


// these define the time taken for the shuttle to get to SS13
// and the time before it leaves again
#define SHUTTLEARRIVETIME  600		// 10 minutes = 600 seconds
#define SHUTTLELEAVETIME   180		// 3 minutes = 180 seconds
#define SHUTTLETRANSITTIME 120		// 2 minutes = 120 seconds

var/global/datum/shuttle_controller/emergency_shuttle/emergency_shuttle

datum/shuttle_controller
	var/alert = 0 //0 = emergency, 1 = crew cycle

	var/location = 0 //0 = somewhere far away (in spess), 1 = at SS13, 2 = returned from SS13
	var/online = 0
	var/direction = 1 //-1 = going back to central command, 1 = going to SS13, 2 = in transit to centcom (not recalled)

	var/endtime			// timeofday that shuttle arrives
	var/timelimit //important when the shuttle gets called for more than shuttlearrivetime
		//timeleft = 360 //600
	var/fake_recall = 0 //Used in rounds to prevent "ON NOES, IT MUST [INSERT ROUND] BECAUSE SHUTTLE CAN'T BE CALLED"

	var/always_fake_recall = 0
	var/deny_shuttle = 0 //for admins not allowing it to be called.
	var/departed = 0

	var/shutdown = 0 // Completely shut down.

	var/can_recall = 1

	var/datum/shuttle/shuttle

	// call the shuttle
	// if not called before, set the endtime to T+600 seconds
	// otherwise if outgoing, switch to incoming

datum/shuttle_controller/proc/incall(coeff = 1)
	if(shutdown) return
	if((!universe.OnShuttleCall(null) || deny_shuttle) && alert == 1) //crew transfer shuttle does not gets recalled by gamemode
		return
	if(endtime)
		if(direction == -1)
			setdirection(1)
	else
		settimeleft(SHUTTLEARRIVETIME*coeff)
		online = 1
		if(always_fake_recall)
			fake_recall = rand(300,500)
	//turning on the red lights in hallways
	if(alert == 0)
		for(var/area/A in areas)
			if(istype(A, /area/hallway))
				A.readyalert()

datum/shuttle_controller/proc/shuttlealert(var/X)
	if(shutdown) return
	alert = X


datum/shuttle_controller/proc/force_shutdown()
	online=0
	shutdown=1



datum/shuttle_controller/proc/recall()
	if(shutdown) return
	if(!can_recall)	return
	if(direction == 1)
		var/timeleft = timeleft()
		if(alert == 0)
			if(timeleft >= 600)
				return
			captain_announce("The emergency shuttle has been recalled.")
			to_chat(world, sound('sound/AI/shuttlerecalled.ogg'))
			setdirection(-1)
			online = 1
			for(var/area/A in areas)
				if(istype(A, /area/hallway))
					A.readyreset()
			return
		else //makes it possible to send shuttle back.
			captain_announce("The shuttle has been recalled.")
			setdirection(-1)
			online = 1
			return

// returns the time (in seconds) before shuttle arrival
// note if direction = -1, gives a count-up to SHUTTLEARRIVETIME
datum/shuttle_controller/proc/timeleft()


	if(online)
		var/timeleft = round((endtime - world.timeofday)/10 ,1)
		if(direction == 1 || direction == 2)
			return timeleft
		else
			return SHUTTLEARRIVETIME-timeleft
	else
		return SHUTTLEARRIVETIME

// sets the time left to a given delay (in seconds)
datum/shuttle_controller/proc/settimeleft(var/delay)
	endtime = world.timeofday + delay * 10
	timelimit = delay

// sets the shuttle direction
// 1 = towards SS13, -1 = back to centcom
datum/shuttle_controller/proc/setdirection(var/dirn)
	if(direction == dirn)
		return
	direction = dirn
	// if changing direction, flip the timeleft by SHUTTLEARRIVETIME
	var/ticksleft = endtime - world.timeofday
	endtime = world.timeofday + (SHUTTLEARRIVETIME*10 - ticksleft)
	return

datum/shuttle_controller/proc/process()

datum/shuttle_controller/proc/move_pod(var/start_type,var/end_type,var/direction,var/open_doors)
	var/area/start_location=locate(start_type)
	var/area/end_location=locate(end_type)

	start_location.move_contents_to(end_location, null, direction)

	for(var/obj/machinery/door/D in all_doors)
		if( get_area(D) == end_location )
			spawn(0)
				if(open_doors)
					D.open()
				else
					D.close()

	for(var/mob/M in end_location)
		if(M.client)
			spawn()
				if(M.locked_to)
					shake_camera(M, 4, 1) // locked_to, not a lot of shaking
				else
					shake_camera(M, 10, 2) // unlocked_to, HOLY SHIT SHAKE THE ROOM
		if(istype(M, /mob/living/carbon))
			if(!M.locked_to)
				M.Weaken(5)


datum/shuttle_controller/emergency_shuttle

datum/shuttle_controller/emergency_shuttle/force_shutdown()
	..()
	if(direction == 2)
		location = 1

		//main shuttle
		if(shuttle && istype(shuttle,/datum/shuttle/escape))
			var/datum/shuttle/escape/E = shuttle
			E.open_all_doors()
			if(!E.move_to_dock(E.dock_station, 0, E.dir)) //Throw everything forward
				message_admins("WARNING: THE EMERGENCY SHUTTLE FAILED TO FIND THE STATION! PANIC PANIC PANIC")
		else
			message_admins("WARNING: THERE IS NO EMERGENCY SHUTTLE! PANIC")
			//move_pod(/area/shuttle/escape/transit,/area/shuttle/escape/station,NORTH,1)

		//pods
		move_pod(/area/shuttle/escape_pod1/transit,/area/shuttle/escape_pod1/station, NORTH,1)
		move_pod(/area/shuttle/escape_pod2/transit,/area/shuttle/escape_pod2/station, NORTH,1)
		move_pod(/area/shuttle/escape_pod3/transit,/area/shuttle/escape_pod3/station, NORTH,1)
		move_pod(/area/shuttle/escape_pod5/transit,/area/shuttle/escape_pod5/station, NORTH,1)

		online = 0

datum/shuttle_controller/emergency_shuttle/process()
	if(!online || shutdown)
		return

	var/timeleft = timeleft()
	if(timeleft > 1e5)		// midnight rollover protection
		timeleft = 0
	if(timeleft < 0)		// Sanity
		timeleft = 0
	switch(location)
		if(0)

			/* --- Shuttle is in transit to Central Command from SS13 --- */
			if(direction == 2)
				if(timeleft>0)
					return 0

				/* --- Shuttle has arrived at Centrcal Command --- */
				else
					// turn off the star spawners
					/*
					for(var/obj/effect/starspawner/S in world)
						S.spawning = 0
					*/

					location = 2

					//main shuttle
					if(shuttle && istype(shuttle,/datum/shuttle/escape))
						var/datum/shuttle/escape/E = shuttle
						E.open_all_doors()
						if(!E.move_to_dock(E.dock_centcom, 0, E.dir)) //Throw everything forward
							message_admins("WARNING: THE EMERGENCY SHUTTLE FAILED TO FIND CENTCOMM! PANIC PANIC PANIC")
					else
						message_admins("WARNING: THERE IS NO EMERGENCY SHUTTLE! PANIC")
						//move_pod(/area/shuttle/escape/transit,/area/shuttle/escape/centcom,NORTH,1)

					//pods
					move_pod(/area/shuttle/escape_pod1/transit,/area/shuttle/escape_pod1/centcom, NORTH,1)
					move_pod(/area/shuttle/escape_pod2/transit,/area/shuttle/escape_pod2/centcom, NORTH,1)
					move_pod(/area/shuttle/escape_pod3/transit,/area/shuttle/escape_pod3/centcom, NORTH,1)
					move_pod(/area/shuttle/escape_pod5/transit,/area/shuttle/escape_pod5/centcom, NORTH,1)

					online = 0

					return 1

			/* --- Shuttle has docked centcom after being recalled --- */
			if(timeleft>timelimit)
				online = 0
				direction = 1
				endtime = null

				return 0

			else if((fake_recall != 0) && (timeleft <= fake_recall))
				recall()
				fake_recall = 0
				return 0

			/* --- Shuttle has docked with the station - begin countdown to transit --- */
			else if(timeleft <= 0)
				location = 1

				if(shuttle && istype(shuttle,/datum/shuttle/escape))
					var/datum/shuttle/escape/E = shuttle
					E.open_all_doors()
					if(!E.move_to_dock(E.dock_station, 0, E.dir)) //Throw everything forward, on chance that there's anybody in the shuttle
						message_admins("WARNING: THE EMERGENCY SHUTTLE FAILED TO FIND THE STATION! PANIC PANIC PANIC")

				settimeleft(SHUTTLELEAVETIME)
				send2mainirc("The Emergency Shuttle has docked with the station.")
				captain_announce("The Emergency Shuttle has docked with the station. You have [round(timeleft()/60,1)] minutes to board the Emergency Shuttle.")
				to_chat(world, sound('sound/AI/shuttledock.ogg'))

				if(universe.name == "Hell Rising")
					to_chat(world, "___________________________________________________________________")
					to_chat(world, "<span class='sinister' style='font-size:3'> A vile force of darkness is making its way toward the escape shuttle.</span>")

				return 1

		if(1)

			// Just before it leaves, close the damn doors!
			if(timeleft == 2 || timeleft == 1)
				for(var/obj/machinery/door/unpowered/shuttle/D in shuttle.linked_area)
					spawn(0)
						D.close()
						D.locked = 1

			if(timeleft>0)
				return 0

			/* --- Shuttle leaves the station, enters transit --- */
			else

				// Turn on the star effects

				/* // kinda buggy atm, i'll fix this later
				for(var/obj/effect/starspawner/S in world)
					if(!S.spawning)
						spawn() S.startspawn()
				*/

				departed = 1 // It's going!
				location = 0 // in deep space
				direction = 2 // heading to centcom

				settimeleft(SHUTTLETRANSITTIME)

				// Shuttle Radio
				CallHook("EmergencyShuttleDeparture", list())

				//main shuttle
				if(shuttle && istype(shuttle,/datum/shuttle/escape))
					var/datum/shuttle/escape/E = shuttle
					E.close_all_doors()
					if(!E.move_to_dock(E.transit_port, 0, turn(E.dir,180))) //Throw everything backwards
						message_admins("WARNING: THE EMERGENCY SHUTTLE FAILED TO FIND TRANSIT! PANIC PANIC PANIC")
				else
					message_admins("WARNING: THERE IS NO EMERGENCY SHUTTLE! PANIC")
					//move_pod(/area/shuttle/escape/station,/area/shuttle/escape/transit,NORTH,0)

				//pods
				move_pod(/area/shuttle/escape_pod1/station,/area/shuttle/escape_pod1/transit,NORTH,0)
				move_pod(/area/shuttle/escape_pod2/station,/area/shuttle/escape_pod2/transit,NORTH,0)
				move_pod(/area/shuttle/escape_pod3/station,/area/shuttle/escape_pod3/transit,NORTH,0)

				move_pod(/area/shuttle/escape_pod5/station,/area/shuttle/escape_pod5/transit,EAST,0)

				captain_announce("The Emergency Shuttle has left the station. Estimate [round(timeleft()/60,1)] minutes until the shuttle docks at Central Command.")

				return 1

		else
			return 1


/*
	Some slapped-together star effects for maximum spess immershuns. Basically consists of a
	spawner, an ender, and bgstar. Spawners create bgstars, bgstars shoot off into a direction
	until they reach a starender.
*/

/obj/effect/bgstar
	name = "star"
	var/speed
	var/direction = SOUTH
	layer = TURF_LAYER

/obj/effect/bgstar/New()
	. = ..()
	pixel_x += rand(-2, 30)
	pixel_y += rand(-2, 30)
	icon_state = "star" + pick("1", "1", "1", "2", "3", "4")
	speed = rand(2, 5)

/obj/effect/bgstar/proc/startmove()
	while (src)
		sleep(speed)
		step(src, direction)

		for (var/obj/effect/starender/E in loc)
			qdel(src)

/obj/effect/starender
	invisibility = 101

/obj/effect/starspawner
	invisibility = 101
	var/spawndir = SOUTH
	var/spawning = 0

	West
		spawndir = WEST

	proc/startspawn()
		spawning = 1
		while(spawning)
			sleep(rand(2, 30))
			var/obj/effect/bgstar/S = new/obj/effect/bgstar(locate(x,y,z))
			S.direction = spawndir
			spawn()
				S.startmove()
