/datum/round_event_control/starfurybc
	name = "Starfury Battle Cruiser"
	typepath = /datum/round_event/starfurybc
	weight = 6
	max_occurrences = 1
	min_players = 40
	earliest_start = 70 MINUTES
	gamemode_blacklist = list("nuclear")

/datum/round_event/starfurybc
	var/shuttle_spawned = FALSE

/*/datum/round_event/starfurybc/proc/spawn_shuttle()
	shuttle_spawned = TRUE

	var/list/candidates = pollGhostCandidates("Do you wish to be considered for syndicate battlecruiser crew?", ROLE_TRAITOR)
	shuffle_inplace(candidates)

	var/datum/map_template/shuttle/syndicate/starfury/ship = new
	var/x = rand(TRANSITIONEDGE,world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE,world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space.z_value
	var/turf/T = locate(x,y,z)
	if(!T)
		CRASH("Starfurybc event found no turf to load in")

	if(!ship.load(T))
		CRASH("Loading starfurybc ship failed!")

	for(var/turf/A in ship.get_affected_turfs(T))
		for(var/obj/effect/mob_spawn/human/syndicate/battlecruiser/spawner in A)
			if(candidates.len > 0)
				var/mob/M = candidates[1]
				spawner.create(M.ckey)
				candidates -= M
				announce_to_ghosts(M)
			else
				announce_to_ghosts(spawner)

	sleep(200)
	sound_to_playing_players('sound/magic/lightning_chargeup.ogg')
	priority_announce("Elite Syndicate BattleCruiser was found near the station's sector. Prepare yourselves.")
*/

/obj/machinery/computer/shuttle/starfurybc
	name = "battle cruiser console"
	shuttleId = "sbcmain"
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = LIGHT_COLOR_RED
	req_access = list(ACCESS_SYNDICATE)
	possible_destinations = "sbcmain_away;sbcmain_home;sbcmain_custom"

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/starfurybc
	name = "battle cruiser navigation computer"
	desc = "Used to designate a precise transit location for the battle cruiser."
	shuttleId = "sbcmain"
	lock_override = CAMERA_LOCK_STATION
	shuttlePortId = "sbcmain_custom"
	x_offset = 9
	y_offset = 0
	see_hidden = FALSE
