
/// The Starfury map template itself.
/datum/map_template/battlecruiser_starfury
	name = "GBC Starfury"
	mappath = "_maps/templates/battlecruiser_starfury.dmm"

// Stationary docking ports for the Starfury's strike shuttles.
/obj/docking_port/stationary/starfury_corvette
	name = "GBC Starfury Corvette Bay"
	shuttle_id = "GBC_corvette_bay"
	roundstart_template = /datum/map_template/shuttle/starfury/corvette
	hidden = TRUE
	width = 14
	height = 7
	dwidth = 7
	dir = NORTH

/obj/docking_port/stationary/starfury_fighter
	name = "GBC Starfury Fighter Bay"
	shuttle_id = "GBC_fighter_bay"
	hidden = TRUE
	width = 5
	height = 7
	dwidth = 2
	dir = NORTH

/obj/docking_port/stationary/starfury_fighter/fighter_one
	name = "GBC Starfury Port Fighter Bay"
	shuttle_id = "GBC_fighter1_bay"
	roundstart_template = /datum/map_template/shuttle/starfury/fighter_one

/obj/docking_port/stationary/starfury_fighter/fighter_two
	name = "GBC Starfury Center Fighter Bay"
	shuttle_id = "GBC_fighter2_bay"
	roundstart_template = /datum/map_template/shuttle/starfury/fighter_two

/obj/docking_port/stationary/starfury_fighter/fighter_three
	name = "GBC Starfury Starboard Fighter Bay"
	shuttle_id = "GBC_fighter3_bay"
	roundstart_template = /datum/map_template/shuttle/starfury/fighter_three

// Mobile docking ports for the Starfury's strike shuttles.
/obj/docking_port/mobile/syndicate_fighter
	name = "syndicate fighter"
	shuttle_id = "syndicate_fighter"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	dir = NORTH
	port_direction = SOUTH
	width = 5
	height = 7
	dwidth = 2

/obj/docking_port/mobile/syndicate_fighter/fighter_one
	name = "gorlex fighter one"
	shuttle_id = "GBC_fighter1"

/obj/docking_port/mobile/syndicate_fighter/fighter_two
	name = "gorlex fighter two"
	shuttle_id = "GBC_fighter2"

/obj/docking_port/mobile/syndicate_fighter/fighter_three
	name = "gorlex fighter three"
	shuttle_id = "GBC_fighter3"

/obj/docking_port/mobile/syndicate_corvette
	name = "gorlex corvette"
	shuttle_id = "GBC_corvette"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	dir = NORTH
	port_direction = SOUTH
	preferred_direction = WEST
	width = 14
	dwidth = 6
	height = 7

/obj/machinery/computer/camera_advanced/shuttle_docker/gorlex/fighter
	name = "gorlex fighter navigation computer"
	desc = "Used to pilot gorlex fighters to commence precision strikes."
	x_offset = 0
	y_offset = 3

/obj/machinery/computer/camera_advanced/shuttle_docker/gorlex/fighter/fighter_one
	shuttleId = "GBC_fighter1"
	shuttlePortId = "GBC_fighter1_custom"
	jump_to_ports = list("syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1, "GBC_fighter1_bay" = 1)
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/camera_advanced/shuttle_docker/gorlex/fighter/fighter_two
	shuttleId = "GBC_fighter2"
	shuttlePortId = "GBC_fighter2_custom"
	jump_to_ports = list("syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1, "GBC_fighter2_bay" = 1)
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/camera_advanced/shuttle_docker/gorlex/fighter/fighter_three
	shuttleId = "GBC_fighter3"
	shuttlePortId = "GBC_fighter3_custom"
	jump_to_ports = list("syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1, "GBC_fighter3_bay" = 1)
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/camera_advanced/shuttle_docker/gorlex/corvette
	name = "gorlex corvette navigation computer"
	desc = "Used to pilot the gorlex corvette to board enemy stations and ships."
	shuttleId = "GBC_corvette"
	shuttlePortId = "GBC_corvette_custom"
	jump_to_ports = list("syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1, "GBC_corvette_bay" = 1)
	y_offset = 3
	x_offset = 0

/obj/machinery/computer/shuttle/starfury/fighter
	name = "gorlex fighter control console"
	desc = "A control computer which controls a shuttle which operates from the GBC Starfury.."
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/shuttle/starfury/fighter/fighter_one
	shuttleId = "GBC_fighter1"
	possible_destinations = "GBC_fighter1_custom;GBC_fighter1_bay;GBC_fighter2_bay;GBC_fighter3_bay;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s"
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/shuttle/starfury/fighter/fighter_two
	shuttleId = "GBC_fighter2"
	possible_destinations = "GBC_fighter2_custom;GBC_fighter1_bay;GBC_fighter2_bay;GBC_fighter3_bay;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s"
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/shuttle/starfury/fighter/fighter_three
	shuttleId = "GBC_fighter3"
	possible_destinations = "GBC_fighter3_custom;GBC_fighter1_bay;GBC_fighter2_bay;GBC_fighter3_bay;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s"
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/shuttle/starfury/corvette
	name = "gorlex corvette control console"
	desc = "A control computer which controls a shuttle which operates from the GBC Starfury.."
	shuttleId = "GBC_corvette"
	possible_destinations = "GBC_corvette_custom;GBC_corvette_bay;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s"
	req_access = list(ACCESS_SYNDICATE)

/*
 * Summons the GBC Starfury, a large syndicate battlecruiser, in Deep Space.
 * It can be piloted into the station's area.
 */
/proc/summon_battlecruiser(datum/team/battlecruiser/team)

	var/list/candidates = poll_ghost_candidates("Do you wish to be considered for battlecruiser crew?", ROLE_TRAITOR)
	shuffle_inplace(candidates)

	var/datum/map_template/ship = SSmapping.map_templates["battlecruiser_starfury.dmm"]
	var/x = rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE - ship.width)
	var/y = rand(TRANSITIONEDGE, world.maxy - TRANSITIONEDGE - ship.height)
	var/z = SSmapping.empty_space?.z_value
	if(isnull(z))
		CRASH("Battlecruiser found no empty space level to load in!")

	var/turf/battlecruiser_loading_turf = locate(x, y, z)
	if(!battlecruiser_loading_turf)
		CRASH("Battlecruiser found no turf to load in!")

	if(!ship.load(battlecruiser_loading_turf))
		CRASH("Loading battlecruiser ship failed!")

	if(!team)
		team = new()
		var/obj/machinery/nuclearbomb/selfdestruct/nuke = locate() in GLOB.nuke_list
		if(nuke.r_code == NUKE_CODE_UNSET)
			nuke.r_code = random_nukecode()
		team.nuke = nuke
		team.update_objectives()

	for(var/turf/open/spawned_turf as anything in ship.get_affected_turfs(battlecruiser_loading_turf)) //not as anything to filter out closed turfs
		for(var/obj/effect/mob_spawn/ghost_role/human/syndicate/battlecruiser/spawner in spawned_turf)
			spawner.antag_team = team
			if(candidates.len > 0)
				var/mob/our_candidate = candidates[1]
				spawner.create(our_candidate)
				spawner.antag_team.players_spawned += (our_candidate.ckey)
				candidates.Splice(1, 2)
				notify_ghosts(
					"The battlecruiser has an object of interest: [our_candidate]!",
					source = our_candidate,
					action = NOTIFY_ORBIT,
					header = "Something's Interesting!"
					)
			else
				notify_ghosts(
					"The battlecruiser has an object of interest: [spawner]!",
					source = spawner,
					action = NOTIFY_ORBIT,
					header="Something's Interesting!"
					)

	priority_announce("Unidentified armed ship detected near the station.")
