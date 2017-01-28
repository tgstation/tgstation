/datum/round_event_control/hivebot_invasion //Hivebots
	name = "Hivebot Invasion"
	typepath = /datum/round_event/hivebot_invasion
	weight = 1
	max_occurrences = 1
	min_players = 25

/datum/round_event/hivebot_invasion
	announceWhen	= 0
	startWhen		= 20
	endWhen			= 180
	var/obj/effect/landmark/invasion_point
	var/beacon_probability = 1 //% chance for a beacon to spawn near the invasion point during the event

/datum/round_event/hivebot_invasion/setup()
	invasion_point = pick(generic_event_spawns)
	message_admins("Hivebot invasion point set to [get_area(invasion_point)]! ([invasion_point.x],[invasion_point.y],[invasion_point.z] - <a href='?_src_=holder;adminplayerobservecoodjump=1;X=[invasion_point.x];Y=[invasion_point.y];Z=[invasion_point.z]'>JMP</a>)")
	log_game("Hivebot invasion point set to [get_area(invasion_point)]! ([invasion_point.x],[invasion_point.y],[invasion_point.z])")


/datum/round_event/hivebot_invasion/announce()
	priority_announce("Long-range scanners have detected unidentified object on collision course with [station_name()]. Intent appears hostile. ETA: 30 seconds. All crew brace for impact.", "Impact Warning", sound = 'sound/machines/warning_alarm.ogg' )
	spawn(150)
		priority_announce("Impact location determined from trajectory to be [get_area(invasion_point)]. Leave the area immediately or risk annihilation.", "Impact Warning", sound = 'sound/misc/notice1.ogg')

/datum/round_event/hivebot_invasion/start()
	var/turf/T = get_turf(invasion_point)
	priority_announce("Object has made impact. Multiple radio signals converging on location. Destroy with extreme prejudice.", "Invasion Warning", sound = 'sound/misc/notice1.ogg')
	for(var/mob/player in player_list)
		if(player.z == invasion_point.z)
			shake_camera(player, 15, 1)
			player.playsound_local(T, 'sound/effects/explosionfar.ogg', 100, 1)
	for(var/mob/living/L in range(1, invasion_point)) //you done fucked up now
		L.gib()
	explosion(T, 0, 0, 20) //Very little heavy damage but a lot of light
	new/obj/machinery/droneDispenser/hivebot/invasion(T)

/datum/round_event/hivebot_invasion/end()
	priority_announce("Radio signals have ceased. Once neutralized, the threat can now be assumed eliminated.", "Invasion End")

/datum/round_event/hivebot_invasion/tick()
	if(prob(beacon_probability))
		var/turf/T = get_step(get_turf(invasion_point), pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, SOUTHWEST, NORTHWEST, SOUTHWEST))
		new/obj/structure/hivebot_beacon(T)
		beacon_probability = initial(beacon_probability)
	else
		beacon_probability++ //Beacon spawning becomes more likely the longer it goes without one



/datum/round_event_control/hivebot_invasion/false_alarm
	name = "Hivebot Invasion"
	typepath = /datum/round_event/hivebot_false_alarm
	weight = 5
	max_occurrences = 1
	min_players = 0

/datum/round_event/hivebot_false_alarm
	announceWhen	= 0
	startWhen		= 20

/datum/round_event/hivebot_false_alarm/start()
	priority_announce("Our long-range scanners were picking up space debris. There is no danger. We apologize for the inconvenience.", "False Alarm")
