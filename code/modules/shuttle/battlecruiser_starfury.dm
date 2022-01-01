
// Some landmarks that denote the locations of starfury shuttle docks.
// The docks themselves are placed in runtime, because shuttle-on-shuttle is hell.
/obj/effect/landmark/starfury_shuttle_dock
	name = "starfury shuttle dock"

/obj/effect/landmark/starfury_shuttle_dock/fighter_one
	name = "starfury fighter one shuttle dock"

/obj/effect/landmark/starfury_shuttle_dock/fighter_two
	name = "starfury fighter two shuttle dock"

/obj/effect/landmark/starfury_shuttle_dock/fighter_three
	name = "starfury fighter three shuttle dock"

/obj/effect/landmark/starfury_shuttle_dock/corvette
	name = "starfury corvette shuttle dock"

// Stationary docking ports for the Starfury and her strike shuttles.
/obj/docking_port/stationary/starfury
	name = "\improper SBC Starfury Deep Space Dock"
	id = "SBC_starfury"
	hidden = TRUE
	height = 67
	width = 37
	dwidth = 34
	dir = WEST

/obj/docking_port/stationary/starfury_corvette
	name = "SBC Starfury Corvette Bay"
	id = "SBC_corvette_bay"
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

/obj/docking_port/stationary/starfury_fighter/fighter_two
	name = "SBC Starfury Center Fighter Bay"
	id = "SBC_fighter2_bay"

/obj/docking_port/stationary/starfury_fighter/fighter_three
	name = "SBC Starfury Starboard Fighter Bay"
	id = "SBC_fighter3_bay"

// Mobile docking ports for the Starfury and her strike shuttles.
/obj/docking_port/mobile/syndicate_starfury
	name = "\improper SBC Starfury"
	id = "SBC_starfury"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	dir = WEST
	port_direction = EAST
	height = 67
	width = 37
	dwidth = 34

/obj/docking_port/mobile/syndicate_starfury/Initialize(mapload)
	. = ..()
	SSpoints_of_interest.make_point_of_interest(src)

/obj/docking_port/mobile/syndicate_fighter
	name = "syndicate fighter"
	id = "syndicate_fighter"
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)
	hidden = TRUE
	find_deepest_baseturf = TRUE
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
	find_deepest_baseturf = TRUE
	dir = NORTH
	port_direction = SOUTH
	preferred_direction = WEST
	width = 14
	dwidth = 6
	height = 7

// Shuttle navigation consoles for the Starfury and her shuttles.
/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/starfury
	name = "\improper SBC Starfury navigation computer"
	desc = "Used to pilot the behemoth syndicate spacecraft known as the SBC Starfury."
	flags_1 = NODECONSTRUCT_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	shuttleId = "SBC_starfury"
	shuttlePortId = "SBC_starfury_custom"

// Once the Starfury reaches the staiton z-level, it cannot have its custom port moved.
/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/starfury/attack_hand(mob/user, list/modifiers)
	if(is_station_level(z))
		to_chat(user, span_warning("The Starfury is locked into orbit with a station and cannot be moved!"))
		return
	return ..()

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/starfury/placeLandingSpot()
	if(is_station_level(z))
		to_chat(current_user, span_warning("The Starfury is locked into orbit with a station and cannot be moved!"))
		return
	return ..()

/obj/item/paper/guides/starfury_pilot
	name = "starfury piloting guide"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "slipfull"
	show_written_words = FALSE
	info = "\
		Congratulations, Syndicate agent, for you have been bestowed the prestigious job \
		of piloting the great battlecruiser SBC Starfury into combat against our foes.<br><br>\
		The Starfury is a behemoth spacecraft designed to transport large amounts of Syndicate \
		agents, equipment, and strike-craft into enemy territory for large-scale missions.<br><br> \
		<b>Note:</b> Upon entering orbit with an enemy position, the battlecruiser will <b>lock</b> \
		position. The captain can then give the order to board the enemy. <br> \
		After locking into near-enemy orbit, a set of Syndicate strike-craft will land in your \
		shuttle bay to aid you and your crew in boarding the enemy and gaining space superiority.<br><br> \
		Good luck, pilot. Glory to the Syndicate. \
		"

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/fighter
	name = "syndicate fighter navigation computer"
	desc = "Used to pilot syndicate fighters to commence precision strikes."

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/fighter/fighter_one
	shuttleId = "SBC_fighter1"
	shuttlePortId = "SBC_fighter1_custom"
	jumpto_ports = list("SBC_fighter1_bay" = 1, "syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1)

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/fighter/fighter_two
	shuttleId = "SBC_fighter2"
	shuttlePortId = "SBC_fighter2_custom"
	jumpto_ports = list("SBC_fighter2_bay" = 1, "syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1)

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/fighter/fighter_three
	shuttleId = "SBC_fighter3"
	shuttlePortId = "SBC_fighter3_custom"
	jumpto_ports = list("SBC_fighter3_bay" = 1, "syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1)

/obj/machinery/computer/camera_advanced/shuttle_docker/syndicate/corvette
	name = "syndicate corvette navigation computer"
	desc = "Used to pilot the syndicate corvette to board enemy stations and ships."
	shuttleId = "SBC_corvette"
	shuttlePortId = "SBC_corvette_custom"
	jumpto_ports = list("SBC_corvette_bay" = 1, "syndicate_ne" = 1, "syndicate_nw" = 1, "syndicate_n" = 1, "syndicate_se" = 1, "syndicate_sw" = 1, "syndicate_s" = 1)

// Shuttle control consoles for the Starfury and her shuttles.
/obj/machinery/computer/shuttle/starfury
	name = "starfury shuttle console"
	desc = "A control computer for a shuttle of the SBC Starfury."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = "#FA8282"
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/computer/shuttle/starfury/battlecruiser
	name = "\improper SBC Starfury shuttle console"
	desc = "A control computer for the great battlecruiser SBC Starfury."
	flags_1 = NODECONSTRUCT_1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	shuttleId = "SBC_starfury"
	possible_destinations = "SBC_starfury_custom;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s"
	/// Whether the battlecruiser bay has been filled with shuttlecraft yet.
	var/static/populated_bay = FALSE

// Once the Starfury reaches the staiton z-level, it cannot be moved.
/obj/machinery/computer/shuttle/starfury/battlecruiser/on_changed_z_level(turf/old_turf, turf/new_turf, notify_contents = TRUE)
	. = ..()

	// We just flew into the station's z-level
	if(!new_turf)
		return

	if(is_station_level(new_turf.z))
		// Lock it down...
		say("Shuttle locked into orbit with a station.")
		locked = TRUE
		// And send in the ships to fill the bay
		if(!populated_bay)
			load_shuttlecraft()

/*
 * Fills the SBC Starfury's bay with two fighters and one corvette.
 */
/obj/machinery/computer/shuttle/starfury/battlecruiser/proc/load_shuttlecraft()

	// Get all of our shuttle templates for ease of access
	var/list/shuttles = flatten_list(SSmapping.shuttle_templates)

	// Load in the first fighter and its dock
	var/datum/map_template/shuttle/starfury/fighter_one/first_fighter = locate() in shuttles
	var/obj/effect/landmark/starfury_shuttle_dock/fighter_one/fighter_one_landmark = locate() in GLOB.landmarks_list
	if(fighter_one_landmark)
		var/obj/docking_port/stationary/starfury_fighter/fighter_one/fighter_one_dock = new(get_turf(fighter_one_landmark))
		SSshuttle.action_load(first_fighter, fighter_one_dock)

	// Then the second fighter and its dock
	var/datum/map_template/shuttle/starfury/fighter_two/second_fighter = locate() in shuttles
	var/obj/effect/landmark/starfury_shuttle_dock/fighter_two/fighter_two_landmark = locate() in GLOB.landmarks_list
	if(fighter_two_landmark)
		var/obj/docking_port/stationary/starfury_fighter/fighter_two/fighter_two_dock = new(get_turf(fighter_two_landmark))
		SSshuttle.action_load(second_fighter, fighter_two_dock)

	// Load in the third fighter's dock, even though there's not a third fighter per se
	var/obj/effect/landmark/starfury_shuttle_dock/fighter_three/fighter_three_landmark = locate() in GLOB.landmarks_list
	if(fighter_three_landmark)
		new /obj/docking_port/stationary/starfury_fighter/fighter_three(get_turf(fighter_one_landmark))

	// And finally, load in the corvette and its dock
	var/datum/map_template/shuttle/starfury/corvette/corvette = locate() in shuttles
	var/obj/effect/landmark/starfury_shuttle_dock/corvette/corvette_landmark = locate() in GLOB.landmarks_list
	if(corvette_landmark)
		var/obj/docking_port/stationary/starfury_corvette/corvette_dock = new(get_turf(corvette_landmark))
		SSshuttle.action_load(corvette, corvette_dock)

/obj/machinery/computer/shuttle/starfury/fighter
	name = "syndicate fighter control console"
	desc = "A control computer which controls a shuttle which operates from the SBC Starfury.."

/obj/machinery/computer/shuttle/starfury/fighter/fighter_one
	shuttleId = "SBC_fighter1"
	possible_destinations = "SBC_fighter1_custom;SBC_fighter1_bay;SBC_fighter2_bay;SBC_fighter3_bay;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s"

/obj/machinery/computer/shuttle/starfury/fighter/fighter_two
	shuttleId = "SBC_fighter2"
	possible_destinations = "SBC_fighter2_custom;SBC_fighter1_bay;SBC_fighter2_bay;SBC_fighter3_bay;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s"

/obj/machinery/computer/shuttle/starfury/fighter/fighter_three
	shuttleId = "SBC_fighter3"
	possible_destinations = "SBC_fighter3_custom;SBC_fighter1_bay;SBC_fighter2_bay;SBC_fighter3_bay;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s"

/obj/machinery/computer/shuttle/starfury/corvette
	name = "syndicate corvette control console"
	desc = "A control computer which controls a shuttle which operates from the SBC Starfury.."
	shuttleId = "SBC_corvette"
	possible_destinations = "SBC_corvette_custom;SBC_corvette_bay;syndicate_ne;syndicate_nw;syndicate_n;syndicate_se;syndicate_sw;syndicate_s"

/*
 * Summons the SBC Starfury, a large syndicate battlecruiser, in Deep Space.
 * It can be piloted into the station's area.
 */
/proc/summon_battlecruiser()

	var/list/candidates = poll_ghost_candidates("Do you wish to be considered for battlecruiser crew?", ROLE_TRAITOR)
	shuffle_inplace(candidates)

	var/list/shuttles = flatten_list(SSmapping.shuttle_templates)

	var/datum/map_template/shuttle/battlecruiser/starfury/ship = locate() in shuttles
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

	for(var/turf/open/spawned_turf as anything in ship.get_affected_turfs(battlecruiser_loading_turf)) //not as anything to filter out closed turfs
		for(var/obj/effect/mob_spawn/ghost_role/human/syndicate/battlecruiser/spawner in spawned_turf)
			if(candidates.len > 0)
				var/mob/our_candidate = candidates[1]
				spawner.create(our_candidate)
				candidates -= our_candidate
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
