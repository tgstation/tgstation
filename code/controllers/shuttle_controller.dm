//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

// Controls the emergency shuttle


// these define the time taken for the shuttle to get to SS13
// and the time before it leaves again

#define SHUTTLEARRIVETIME 600		// 10 minutes = 600 seconds
#define SHUTTLELEAVETIME 180		// 3 minutes = 180 seconds
#define SHUTTLETRANSITTIME 120		// 2 minutes = 120 seconds
#define SHUTTLEAUTOCALLTIMER 2.5   	// 25 minutes

#define UNDOCKED 0 //Shuttle is always this until the shuttle has reached the station.
#define DOCKED -1 //Shuttle is at the station
#define TRANSIT 1 //Shuttle is coming to centcom from the station
#define ENDGAME 2 //It's what game tickers check for for the purposes of round completion, I'm not touching it.

var/global/datum/shuttle_controller/emergency_shuttle/emergency_shuttle

datum/shuttle_controller
	var/location = UNDOCKED //
	var/online = 0
	var/direction = 1 //-1 = going back to central command, 1 = going to SS13.  Only important for recalling

	var/endtime			// timeofday that shuttle arrives
	var/timelimit //important when the shuttle gets called for more than shuttlearrivetime
		//timeleft = 360 //600
	var/fake_recall = 0 //Used in rounds to prevent "ON NOES, IT MUST [INSERT ROUND] BECAUSE SHUTTLE CAN'T BE CALLED"
	var/always_fake_recall = 0

	var/pods = list("escape", "pod1", "pod2", "pod3", "pod4")


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
			if(always_fake_recall)

				if ((seclevel2num(get_security_level()) == SEC_LEVEL_RED))
					fake_recall = rand(SHUTTLEARRIVETIME / 4, SHUTTLEARRIVETIME - 100 / 2)
				else
					fake_recall = rand(SHUTTLEARRIVETIME / 2, SHUTTLEARRIVETIME - 100)

	proc/recall()
		if(direction == 1)
			var/timeleft = timeleft()
			if(timeleft >= SHUTTLEARRIVETIME)
				online = 0
				direction = 1
				endtime = null
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

	//calls the shuttle if there's no AI or comms console,
	proc/autoshuttlecall()
		var/callshuttle = 1
		for(var/SC in shuttle_caller_list)
			if(istype(SC,/mob/living/silicon/ai))
				var/mob/living/silicon/ai/AI = SC
				if(AI.stat && !AI.client)
					continue
			var/turf/T = get_turf(SC)
			if(T && T.z == 1)
				callshuttle = 0 //if there's an alive AI or a communication console on the station z level, we don't call the shuttle
				break

		if(ticker.mode.name == "revolution" || ticker.mode.name == "AI malfunction")
			callshuttle = 0

		if(callshuttle)
			if(!online && direction == 1) //we don't call the shuttle if it's already coming
				incall(SHUTTLEAUTOCALLTIMER) //X minutes! If they want to recall, they have X-(X-5) minutes to do so
				log_game("All the AIs, comm consoles and boards are destroyed. Shuttle called.")
				message_admins("All the AIs, comm consoles and boards are destroyed. Shuttle called.", 1)
				captain_announce("The emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")
				world << sound('sound/AI/shuttlecalled.ogg')

	proc/move_shuttles()
		var/datum/shuttle_manager/s
		for(var/t in pods)
			s = shuttles[t]
			s.move_shuttle()

	proc/process()

	emergency_shuttle
		process()
			if(!online)
				return
			var/timeleft = timeleft()
			if(timeleft > 1e5)		// midnight rollover protection
				timeleft = 0
			if(location == UNDOCKED)
				if(direction == -1)
					if(timeleft >= timelimit)
						online = 0
						direction = 1
						endtime = null
						return 0
				else if(fake_recall && (timeleft <= fake_recall))
					recall()
					fake_recall = 0
					return 0
				else if(timeleft <= 0)
					var/datum/shuttle_manager/s = shuttles["escape"]
					s.move_shuttle()
					location = DOCKED
					settimeleft(SHUTTLELEAVETIME)
					send2irc("Server", "The Emergency Shuttle has docked with the station.")
					captain_announce("The Emergency Shuttle has docked with the station. You have [round(timeleft()/60,1)] minutes to board the Emergency Shuttle.")
					world << sound('sound/AI/shuttledock.ogg')
			else if(timeleft <= 0) //Nothing happens if time's not up and the ship's docked or later
				if(location == DOCKED)
					move_shuttles()
					location = TRANSIT
					settimeleft(SHUTTLETRANSITTIME)
					captain_announce("The Emergency Shuttle has left the station. Estimate [round(timeleft()/60,1)] minutes until the shuttle docks at Central Command.")
				else if(location == TRANSIT)
					move_shuttles()
					message_admins("Shuttles have attempted to move to Centcom")
					location = ENDGAME
					online = 0
					endtime = null
				return 1
			return 0

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


/proc/push_mob_back(var/mob/living/L, var/dir)
	if(iscarbon(L) && isturf(L.loc))
		if(prob(88))
			var/turf/T = get_step(L, dir)
			if(T)
				for(var/obj/O in T) // For doors and such (kinda ugly but we can't have people opening doors)
					if(!O.CanPass(L, L.loc, 1, 0))
						return
				L.Move(get_step(L, dir), dir)