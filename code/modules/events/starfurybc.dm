/datum/round_event_control/starfurybc
	name = "Starfury Battle Cruiser"
	typepath = /datum/round_event/ghost_role/starfurybc
	weight = 6
	max_occurrences = 1
	min_players = 40
	earliest_start = 70 MINUTES
	gamemode_blacklist = list("nuclear")

/datum/round_event_control/starfurybc/preRunEvent()
	if (!SSmapping.empty_space)
		return EVENT_CANT_RUN
	return ..()

/datum/round_event/ghost_role/starfurybc
	minimum_required = 5
	var/shuttle_spawned = FALSE
	var/preptime = 8 MINUTES
	var/announcetime = 4 MINUTES

/datum/round_event/ghost_role/starfurybc/start()
	priority_announce("Syndicate Battle Cruiser detected on long range scanners. ETA 8 Minutes. Emergency Shuttle will be delayed by 14 minutes.")
	var/delaytime = 8400
	var/timer = SSshuttle.emergency.timeLeft(1) + delaytime
	var/security_num = seclevel2num(get_security_level())
	var/set_coefficient = 1
	switch(security_num)
		if(SEC_LEVEL_GREEN)
			set_coefficient = 2
		if(SEC_LEVEL_BLUE)
			set_coefficient = 1
		else
			set_coefficient = 0.5
	var/recalld = timer - (SSshuttle.emergencyCallTime * set_coefficient)
	SSshuttle.emergency.setTimer(timer)
	if(recalld > 0)
		SSshuttle.block_recall(recalld)
	sleep(preptime)
	spawn_shuttle()

/datum/round_event/ghost_role/starfurybc/proc/spawn_shuttle()
	shuttle_spawned = TRUE

	var/list/candidates = pollGhostCandidates("Do you wish to be considered for syndicate battlecruiser crew?", ROLE_TRAITOR)
	shuffle_inplace(candidates)
	if(candidates.len < 5)
		return NOT_ENOUGH_PLAYERS

	var/datum/map_template/shuttle/syndicate/starfury/ship = new
	var/x = rand(TRANSITIONEDGE,world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE,world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/T = locate(x,y,z)
	if(!T)
		CRASH("SBC Starfury event found no turf to load in")

	if(!ship.load(T))
		CRASH("Loading SBC Starfury cruiser failed!")

	for(var/turf/A in ship.get_affected_turfs(T))
		for(var/obj/effect/mob_spawn/human/syndicate/spawner in A)
			if(candidates.len > 0)
				var/mob/M = candidates[1]
				spawner.create(M.ckey)
				candidates -= M
				announce_to_ghosts(M)
			else
				announce_to_ghosts(spawner)

	sleep(announcetime)
	priority_announce("Syndicate Battle Cruiser has been found near the station's sector, brace for impact.", sound = 'sound/machines/alarm.ogg')

/obj/machinery/computer/shuttle/starfurybc
	name = "battle cruiser console"
	shuttleId = "starfury"
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = LIGHT_COLOR_RED
	req_access = list(ACCESS_SYNDICATE)
	possible_destinations = "starfury_home;starfury_custom"

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/starfurybc
	name = "battle cruiser navigation computer"
	desc = "Used to designate a precise transit location for the battle cruiser."
	shuttleId = "starfury"
	jumpto_ports = list("starfury_home" = 1, "syndicate_nw" = 1)
	shuttlePortId = "starfury_custom"
	view_range = 140
	x_offset = -14
	y_offset = 22
