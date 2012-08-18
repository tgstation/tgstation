//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

// Controls the emergency shuttle


// these define the time taken for the shuttle to get to SS13
// and the time before it leaves again
#define SHUTTLEARRIVETIME 600		// 10 minutes = 600 seconds
#define SHUTTLELEAVETIME 180		// 3 minutes = 180 seconds
#define SHUTTLETRANSITTIME 120		// 2 minutes = 120 seconds

var/global/datum/shuttle_controller/emergency_shuttle/emergency_shuttle

datum/shuttle_controller
	var/location = 0 //0 = somewhere far away (in spess), 1 = at SS13, 2 = returned from SS13
	var/online = 0
	var/direction = 1 //-1 = going back to central command, 1 = going to SS13, 2 = in transit to centcom (not recalled)

	var/endtime			// timeofday that shuttle arrives
	var/timelimit //important when the shuttle gets called for more than shuttlearrivetime
		//timeleft = 360 //600
	var/fake_recall = 0 //Used in rounds to prevent "ON NOES, IT MUST [INSERT ROUND] BECAUSE SHUTTLE CAN'T BE CALLED"


	// call the shuttle
	// if not called before, set the endtime to T+600 seconds
	// otherwise if outgoing, switch to incoming
	proc/incall(coeff = 1)
		if(endtime)
			if(direction == -1)
				setdirection(1)
		else
			settimeleft(SHUTTLEARRIVETIME*coeff)
			online = 1

	proc/recall()
		if(direction == 1)
			var/timeleft = timeleft()
			if(timeleft >= 600)
				return
			captain_announce("The emergency shuttle has been recalled.")
			world << sound('sound/AI/shuttlerecalled.ogg')
			setdirection(-1)
			online = 1


	// returns the time (in seconds) before shuttle arrival
	// note if direction = -1, gives a count-up to SHUTTLEARRIVETIME
	proc/timeleft()
		if(online)
			var/timeleft = round((endtime - world.timeofday)/10 ,1)
			if(direction == 1 || direction == 2)
				return timeleft
			else
				return SHUTTLEARRIVETIME-timeleft
		else
			return SHUTTLEARRIVETIME

	// sets the time left to a given delay (in seconds)
	proc/settimeleft(var/delay)
		endtime = world.timeofday + delay * 10
		timelimit = delay

	// sets the shuttle direction
	// 1 = towards SS13, -1 = back to centcom
	proc/setdirection(var/dirn)
		if(direction == dirn)
			return
		direction = dirn
		// if changing direction, flip the timeleft by SHUTTLEARRIVETIME
		var/ticksleft = endtime - world.timeofday
		endtime = world.timeofday + (SHUTTLEARRIVETIME*10 - ticksleft)
		return

	proc/process()

	emergency_shuttle
		process()
			if(!online)
				return
			var/timeleft = timeleft()
			if(timeleft > 1e5)		// midnight rollover protection
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
							var/area/start_location = locate(/area/shuttle/escape/transit)
							var/area/end_location = locate(/area/shuttle/escape/centcom)

							start_location.move_contents_to(end_location, null, NORTH)

							for(var/obj/machinery/door/D in world)
								if( get_area(D) == end_location )
									spawn(0)
										D.open()

							for(var/mob/M in end_location)
								if(M.client)
									spawn(0)
										if(M.buckled)
											shake_camera(M, 4, 1) // buckled, not a lot of shaking
										else
											shake_camera(M, 10, 2) // unbuckled, HOLY SHIT SHAKE THE ROOM
								if(istype(M, /mob/living/carbon))
									if(!M.buckled)
										M.Weaken(5)

							//pods
							start_location = locate(/area/shuttle/escape_pod1/transit)
							end_location = locate(/area/shuttle/escape_pod1/centcom)
							start_location.move_contents_to(end_location, null, NORTH)

							for(var/obj/machinery/door/D in world)
								if( get_area(D) == end_location )
									spawn(0)
										D.open()

							for(var/mob/M in end_location)
								if(M.client)
									spawn(0)
										if(M.buckled)
											shake_camera(M, 4, 1) // buckled, not a lot of shaking
										else
											shake_camera(M, 10, 2) // unbuckled, HOLY SHIT SHAKE THE ROOM
								if(istype(M, /mob/living/carbon))
									if(!M.buckled)
										M.Weaken(5)

							start_location = locate(/area/shuttle/escape_pod2/transit)
							end_location = locate(/area/shuttle/escape_pod2/centcom)
							start_location.move_contents_to(end_location, null, NORTH)

							for(var/obj/machinery/door/D in world)
								if( get_area(D) == end_location )
									spawn(0)
										D.open()

							for(var/mob/M in end_location)
								if(M.client)
									spawn(0)
										if(M.buckled)
											shake_camera(M, 4, 1) // buckled, not a lot of shaking
										else
											shake_camera(M, 10, 2) // unbuckled, HOLY SHIT SHAKE THE ROOM
								if(istype(M, /mob/living/carbon))
									if(!M.buckled)
										M.Weaken(5)

							start_location = locate(/area/shuttle/escape_pod3/transit)
							end_location = locate(/area/shuttle/escape_pod3/centcom)
							start_location.move_contents_to(end_location, null, NORTH)

							for(var/obj/machinery/door/D in world)
								if( get_area(D) == end_location )
									spawn(0)
										D.open()

							for(var/mob/M in end_location)
								if(M.client)
									spawn(0)
										if(M.buckled)
											shake_camera(M, 4, 1) // buckled, not a lot of shaking
										else
											shake_camera(M, 10, 2) // unbuckled, HOLY SHIT SHAKE THE ROOM
								if(istype(M, /mob/living/carbon))
									if(!M.buckled)
										M.Weaken(5)

							start_location = locate(/area/shuttle/escape_pod5/transit)
							end_location = locate(/area/shuttle/escape_pod5/centcom)
							start_location.move_contents_to(end_location, null, EAST)

							for(var/obj/machinery/door/D in world)
								if( get_area(D) == end_location )
									spawn(0)
										D.open()

							for(var/mob/M in end_location)
								if(M.client)
									spawn(0)
										if(M.buckled)
											shake_camera(M, 4, 1) // buckled, not a lot of shaking
										else
											shake_camera(M, 10, 2) // unbuckled, HOLY SHIT SHAKE THE ROOM
								if(istype(M, /mob/living/carbon))
									if(!M.buckled)
										M.Weaken(5)

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

						return 0

					/* --- Shuttle has docked with the station - begin countdown to transit --- */
					else if(timeleft <= 0)
						location = 1
						var/area/start_location = locate(/area/shuttle/escape/centcom)
						var/area/end_location = locate(/area/shuttle/escape/station)

						var/list/dstturfs = list()
						var/throwy = world.maxy

						for(var/turf/T in end_location)
							dstturfs += T
							if(T.y < throwy)
								throwy = T.y

						// hey you, get out of the way!
						for(var/turf/T in dstturfs)
							// find the turf to move things to
							var/turf/D = locate(T.x, throwy - 1, 1)
							//var/turf/E = get_step(D, SOUTH)
							for(var/atom/movable/AM as mob|obj in T)
								AM.Move(D)
								// NOTE: Commenting this out to avoid recreating mass driver glitch
								/*
								spawn(0)
									AM.throw_at(E, 1, 1)
									return
								*/

							if(istype(T, /turf/simulated))
								del(T)

						for(var/mob/living/carbon/bug in end_location) // If someone somehow is still in the shuttle's docking area...
							bug.gib()

						start_location.move_contents_to(end_location)
						settimeleft(SHUTTLELEAVETIME)
						send2irc("Server", "The Emergency Shuttle has docked with the station.")
						captain_announce("The Emergency Shuttle has docked with the station. You have [round(timeleft()/60,1)] minutes to board the Emergency Shuttle.")
						world << sound('sound/AI/shuttledock.ogg')

						return 1

				if(1)

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

						location = 0 // in deep space
						direction = 2 // heading to centcom

						//main shuttle
						var/area/start_location = locate(/area/shuttle/escape/station)
						var/area/end_location = locate(/area/shuttle/escape/transit)

						settimeleft(SHUTTLETRANSITTIME)
						start_location.move_contents_to(end_location, null, NORTH)

						for(var/obj/machinery/door/D in end_location)
							spawn(0)
								D.close()
							// Some aesthetic turbulance shaking
						for(var/mob/M in end_location)
							if(M.client)
								spawn(0)
									if(M.buckled)
										shake_camera(M, 4, 1) // buckled, not a lot of shaking
									else
										shake_camera(M, 10, 2) // unbuckled, HOLY SHIT SHAKE THE ROOM
							if(istype(M, /mob/living/carbon))
								if(!M.buckled)
									M.Weaken(5)

						//pods
						start_location = locate(/area/shuttle/escape_pod1/station)
						end_location = locate(/area/shuttle/escape_pod1/transit)
						start_location.move_contents_to(end_location, null, NORTH)
						for(var/obj/machinery/door/D in end_location)
							spawn(0)
								D.close()

						for(var/mob/M in end_location)
							if(M.client)
								spawn(0)
									if(M.buckled)
										shake_camera(M, 4, 1) // buckled, not a lot of shaking
									else
										shake_camera(M, 10, 2) // unbuckled, HOLY SHIT SHAKE THE ROOM
							if(istype(M, /mob/living/carbon))
								if(!M.buckled)
									M.Weaken(5)

						start_location = locate(/area/shuttle/escape_pod2/station)
						end_location = locate(/area/shuttle/escape_pod2/transit)
						start_location.move_contents_to(end_location, null, NORTH)
						for(var/obj/machinery/door/D in end_location)
							spawn(0)
								D.close()

						for(var/mob/M in end_location)
							if(M.client)
								spawn(0)
									if(M.buckled)
										shake_camera(M, 4, 1) // buckled, not a lot of shaking
									else
										shake_camera(M, 10, 2) // unbuckled, HOLY SHIT SHAKE THE ROOM
							if(istype(M, /mob/living/carbon))
								if(!M.buckled)
									M.Weaken(5)

						start_location = locate(/area/shuttle/escape_pod3/station)
						end_location = locate(/area/shuttle/escape_pod3/transit)
						start_location.move_contents_to(end_location, null, NORTH)
						for(var/obj/machinery/door/D in end_location)
							spawn(0)
								D.close()

						for(var/mob/M in end_location)
							if(M.client)
								spawn(0)
									if(M.buckled)
										shake_camera(M, 4, 1) // buckled, not a lot of shaking
									else
										shake_camera(M, 10, 2) // unbuckled, HOLY SHIT SHAKE THE ROOM
							if(istype(M, /mob/living/carbon))
								if(!M.buckled)
									M.Weaken(5)

						start_location = locate(/area/shuttle/escape_pod5/station)
						end_location = locate(/area/shuttle/escape_pod5/transit)
						start_location.move_contents_to(end_location, null, EAST)
						for(var/obj/machinery/door/D in end_location)
							spawn(0)
								D.close()

						for(var/mob/M in end_location)
							if(M.client)
								spawn(0)
									if(M.buckled)
										shake_camera(M, 4, 1) // buckled, not a lot of shaking
									else
										shake_camera(M, 10, 2) // unbuckled, HOLY SHIT SHAKE THE ROOM
							if(istype(M, /mob/living/carbon))
								if(!M.buckled)
									M.Weaken(5)

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
	var/speed = 10
	var/direction = SOUTH
	layer = 2 // TURF_LAYER

	New()
		..()
		pixel_x += rand(-2,30)
		pixel_y += rand(-2,30)
		var/starnum = pick("1", "1", "1", "2", "3", "4")

		icon_state = "star"+starnum

		speed = rand(2, 5)

	proc/startmove()

		while(src)
			sleep(speed)
			step(src, direction)
			for(var/obj/effect/starender/E in loc)
				del(src)


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


