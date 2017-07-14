/datum/round_event_control/hivebot_invasion //A hivebot swarm core impacts the station and warps in hivebots.
	name = "Hivebot Invasion"
	typepath = /datum/round_event/hivebot_invasion
	weight = 5
	max_occurrences = 1
	min_players = 25
	earliest_start = 18000

/datum/round_event/hivebot_invasion
	announceWhen	= 0
	startWhen		= 20
	var/obj/effect/landmark/invasion_point

/datum/round_event/hivebot_invasion/setup()
	invasion_point = pick(GLOB.generic_event_spawns)
	message_admins("Hivebot invasion point set to [get_area(invasion_point)]! [ADMIN_COORDJMP(invasion_point)]")
	log_game("Hivebot invasion point set to [get_area(invasion_point)]! ([COORD(invasion_point)])")


/datum/round_event/hivebot_invasion/announce()
	priority_announce("Long-range scanners have detected an unidentified object on collision course with [station_name()]. Intent appears hostile. ETA: 30 seconds. All crew brace for impact.", "Impact Warning", sound = 'sound/machines/warning_alarm.ogg' )
	addtimer(CALLBACK(GLOBAL_PROC, /proc/priority_announce, "Impact location determined from trajectory to be [get_area(invasion_point)]. Leave the area immediately or risk annihilation.", "Impact Warning", 'sound/misc/notice1.ogg'), 150)

/datum/round_event/hivebot_invasion/start()
	var/turf/T = get_turf(invasion_point)
	priority_announce("Object has made impact. Heavy bluespace activity detected; object likely serves as a beacon. Destroy the object as quickly as possible.", "Invasion Warning", sound = 'sound/misc/notice1.ogg')
	for(var/P in GLOB.player_list)
		var/mob/player = P
		if(player.z == invasion_point.z)
			shake_camera(player, 15, 1)
			player.playsound_local(T, 'sound/effects/explosionfar.ogg', 100, 1)
	for(var/mob/living/L in range(1, invasion_point)) //you done fucked up now
		L.gib()
	explosion(T, 0, 0, 10) //Very little heavy damage but a lot of light
	new/obj/machinery/hivebot_swarm_core(T)



/datum/round_event_control/hivebot_invasion/false_alarm
	name = "Hivebot Invasion (False Alarm)"
	typepath = /datum/round_event/hivebot_false_alarm
	weight = 3
	max_occurrences = 1
	min_players = 0

/datum/round_event/hivebot_false_alarm
	announceWhen	= 0
	startWhen		= 15

/datum/round_event/hivebot_false_alarm/announce()
	priority_announce("Long-range scanners have detected an unidentified object on collision course with [station_name()]. Intent appears hostile. ETA: 30 seconds. All crew brace for impact.", "Impact Warning", sound = 'sound/machines/warning_alarm.ogg' )

/datum/round_event/hivebot_false_alarm/start()
	priority_announce("Our long-range scanners were picking up space debris. There is no danger. We apologize for the inconvenience.", "False Alarm")
