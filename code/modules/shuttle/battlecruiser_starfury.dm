
/// The Starfury map template itself.
/datum/map_template/battlecruiser_starfury
	name = "SBC Starfury"
	mappath = "_maps/templates/battlecruiser_starfury.dmm"

// Stationary docking ports for the Starfury's strike shuttles.
/obj/docking_port/stationary/starfury_corvette
	name = "SBC Starfury Corvette Bay"
	id = "SBC_corvette_bay"
	roundstart_template = /datum/map_template/shuttle/starfury/corvette
	hidden = TRUE
	width = 14
	height = 7
	dwidth = 7
	dir = NORTH

/obj/docking_port/stationary/starfury_fighter
	name = "SBC Starfury Fighter Bay"
	id = "SBC_fighter_bay"
	hidden = TRUE
	width = 5
	height = 7
	dwidth = 2
	dir = NORTH

/obj/docking_port/stationary/starfury_fighter/fighter_one
	name = "SBC Starfury Port Fighter Bay"
	id = "SBC_fighter1_bay"
	roundstart_template = /datum/map_template/shuttle/starfury/fighter_one

/obj/docking_port/stationary/starfury_fighter/fighter_two
	name = "SBC Starfury Center Fighter Bay"
	id = "SBC_fighter2_bay"
	roundstart_template = /datum/map_template/shuttle/starfury/fighter_two

/obj/docking_port/stationary/starfury_fighter/fighter_three
	name = "SBC Starfury Starboard Fighter Bay"
	id = "SBC_fighter3_bay"
	roundstart_template = /datum/map_template/shuttle/starfury/fighter_three

// Mobile docking ports for the Starfury's strike shuttles.
/obj/docking_port/mobile/syndicate_fighter
	name = "syndicate fighter"
	id = "syndicate_fighter"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	dir = NORTH
	port_direction = SOUTH
	width = 5
	height = 7
	dwidth = 2

/obj/docking_port/mobile/syndicate_fighter/fighter_one
	name = "syndicate fighter one"
	id = "SBC_fighter1"

/obj/docking_port/mobile/syndicate_fighter/fighter_two
	name = "syndicate fighter two"
	id = "SBC_fighter2"

/obj/docking_port/mobile/syndicate_fighter/fighter_three
	name = "syndicate fighter three"
	id = "SBC_fighter3"

/obj/docking_port/mobile/syndicate_corvette
	name = "syndicate corvette"
	id = "SBC_corvette"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	dir = NORTH
	port_direction = SOUTH
	preferred_direction = WEST
	width = 14
	dwidth = 6
	height = 7

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/fighter
	name = "syndicate fighter navigation computer"
	desc = "Used to pilot syndicate fighters to commence precision strikes."
	x_offset = 0
	y_offset = 3

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/fighter/fighter_one
	shuttleId = "SBC_fighter1"
	shuttlePortId = "SBC_fighter1_custom"
	jump_to_ports = list("syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1, "SBC_fighter1_bay" = 1)
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/fighter/fighter_two
	shuttleId = "SBC_fighter2"
	shuttlePortId = "SBC_fighter2_custom"
	jump_to_ports = list("syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1, "SBC_fighter2_bay" = 1)
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/fighter/fighter_three
	shuttleId = "SBC_fighter3"
	shuttlePortId = "SBC_fighter3_custom"
	jump_to_ports = list("syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1, "SBC_fighter3_bay" = 1)
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/corvette
	name = "syndicate corvette navigation computer"
	desc = "Used to pilot the syndicate corvette to board enemy stations and ships."
	shuttleId = "SBC_corvette"
	shuttlePortId = "SBC_corvette_custom"
	jump_to_ports = list("syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1, "SBC_corvette_bay" = 1)
	y_offset = 3
	x_offset = 0

/obj/machinery/computer/shuttle/starfury/fighter
	name = "syndicate fighter control console"
	desc = "A control computer which controls a shuttle which operates from the SBC Starfury.."
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/shuttle/starfury/fighter/fighter_one
	shuttleId = "SBC_fighter1"
	possible_destinations = "SBC_fighter1_custom;SBC_fighter1_bay;SBC_fighter2_bay;SBC_fighter3_bay;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s"
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/shuttle/starfury/fighter/fighter_two
	shuttleId = "SBC_fighter2"
	possible_destinations = "SBC_fighter2_custom;SBC_fighter1_bay;SBC_fighter2_bay;SBC_fighter3_bay;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s"
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/shuttle/starfury/fighter/fighter_three
	shuttleId = "SBC_fighter3"
	possible_destinations = "SBC_fighter3_custom;SBC_fighter1_bay;SBC_fighter2_bay;SBC_fighter3_bay;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s"
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/shuttle/starfury/corvette
	name = "syndicate corvette control console"
	desc = "A control computer which controls a shuttle which operates from the SBC Starfury.."
	shuttleId = "SBC_corvette"
	possible_destinations = "SBC_corvette_custom;SBC_corvette_bay;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s"
	req_access = list(ACCESS_SYNDICATE)

/*
 * Summons the SBC Starfury, a large syndicate battlecruiser, in Deep Space.
 * It can be piloted into the station's area.
 */
/proc/summon_battlecruiser()

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

	var/datum/team/battlecruiser/team = new()
	var/obj/machinery/nuclearbomb/selfdestruct/nuke = locate() in GLOB.nuke_list
	if(nuke.r_code == "ADMIN")
		nuke.r_code = random_nukecode()
	team.nuke = nuke
	team.update_objectives()

	for(var/turf/open/spawned_turf as anything in ship.get_affected_turfs(battlecruiser_loading_turf)) //not as anything to filter out closed turfs
		for(var/obj/effect/mob_spawn/ghost_role/human/syndicate/battlecruiser/spawner in spawned_turf)
			spawner.antag_team = team
			if(candidates.len > 0)
				var/mob/our_candidate = candidates[1]
				spawner.create(our_candidate)
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
