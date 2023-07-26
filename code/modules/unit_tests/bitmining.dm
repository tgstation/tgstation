#define TEST_MAP "test_only"
#define TEST_MAP_EXPENSIVE "test_only_expensive"
#define TEST_MAP_MOBS "test_only_mobs"

/// The qserver and qconsole should find each other on init
/datum/unit_test/quantum_server_find_console/Run()
	var/obj/machinery/computer/quantum_console/console = allocate(/obj/machinery/computer/quantum_console)
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))

	TEST_ASSERT_NOTNULL(console.server_ref, "Quantum console did not set server_ref")
	TEST_ASSERT_NOTNULL(server.console_ref, "Quantum server did not set console_ref")

	var/obj/machinery/computer/quantum_console/connected_console = server.console_ref.resolve()
	var/obj/machinery/quantum_server/connected_server = console.server_ref.resolve()
	TEST_ASSERT_EQUAL(connected_console, console, "Quantum console did not set server_ref correctly")
	TEST_ASSERT_EQUAL(connected_server, server, "Quantum server did not set console_ref correctly")

/// Initializing virtual domain
/datum/unit_test/quantum_server_initialize_vdom/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)

	server.initialize_virtual_domain()
	TEST_ASSERT_NOTNULL(server.vdom_ref, "Did not initialize vdom")
	TEST_ASSERT_EQUAL(length(server.map_load_turf), 1, "There should only ever be ONE turf, the bottom left, in the map_load_turf list")
	TEST_ASSERT_EQUAL(length(server.safehouse_load_turf), 1, "There should only ever be ONE turf, the bottom left, in the safehouse_load_turf list")

/// Setting domains
/datum/unit_test/quantum_server_set_domain/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)

	var/datum/map_template/virtual_domain/domain = server.set_domain(TEST_MAP)
	TEST_ASSERT_EQUAL(domain.id, TEST_MAP, "Did not load test map correctly")

/// Loading maps onto the vdom
/datum/unit_test/quantum_server_load_domain/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)

	server.initialize_virtual_domain()
	TEST_ASSERT_NOTNULL(server.vdom_ref, "Sanity: Did not initialize vdom_ref")

	var/datum/map_template/virtual_domain/domain = server.set_domain(map_id = TEST_MAP)
	TEST_ASSERT_EQUAL(domain.id, TEST_MAP, "Sanity: Did not load test map correctly")

	server.load_domain(domain)
	TEST_ASSERT_NOTNULL(server.generated_safehouse, "Did not load generated_safehouse correctly")
	TEST_ASSERT_NOTNULL(server.generated_domain, "Did not load generated_domain correctly")
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "Did not load the correct domain")

/// Handles cases with stopping domains. The server should cool down & prevent stoppage with active mobs
/datum/unit_test/quantum_server_stop_domain/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)

	server.cold_boot_map(labrat, TEST_MAP)
	TEST_ASSERT_NOTNULL(server.vdom_ref, "Sanity: Did not initialize vdom_ref")
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "Sanity: Did not load test map correctly")

	server.stop_domain()
	TEST_ASSERT_NOTNULL(server.vdom_ref, "Should not erase vdom_ref on stop_domain()")
	TEST_ASSERT_NULL(server.generated_domain, "Did not stop domain")
	TEST_ASSERT_NULL(server.generated_safehouse, "Did not stop safehouse")
	TEST_ASSERT_EQUAL(server.get_ready_status(), FALSE, "Should cool down, but did not set ready status to FALSE")

	server.cold_boot_map(labrat, TEST_MAP)
	TEST_ASSERT_NULL(server.generated_domain, "Should prevent loading a new domain while cooling down")

	COOLDOWN_RESET(server, cooling_off)
	server.cold_boot_map(labrat, TEST_MAP)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "Should load a new domain after cooldown")

	var/datum/weakref/fake_mind_ref = WEAKREF(labrat)
	server.occupant_mind_refs += fake_mind_ref
	server.stop_domain()
	TEST_ASSERT_NULL(server.generated_domain, "Should force stop a domain even with occupants")

/// Handles the linking process to boot a domain from scratch
/datum/unit_test/quantum_server_cold_boot_map/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)
	labrat.mind_initialize()
	labrat.mock_client = new()

	server.cold_boot_map(labrat, map_id = TEST_MAP)
	TEST_ASSERT_NOTNULL(server.generated_domain, "Did not cold boot generated_domain correctly")

	server.cold_boot_map(labrat, map_id = TEST_MAP_EXPENSIVE)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "Should prevent loading multiple domains")

	server.stop_domain()
	COOLDOWN_RESET(server, cooling_off)
	var/datum/weakref/fake_mind_ref = WEAKREF(labrat)
	server.occupant_mind_refs += fake_mind_ref
	server.cold_boot_map(labrat, map_id = TEST_MAP)
	TEST_ASSERT_NULL(server.generated_domain, "Should prevent setting domains with occupants")

	server.stop_domain()
	COOLDOWN_RESET(server, cooling_off)
	server.occupant_mind_refs -= fake_mind_ref
	server.points = 3
	server.cold_boot_map(labrat, map_id = TEST_MAP_EXPENSIVE)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP_EXPENSIVE, "Sanity: Should've loaded expensive test map")
	TEST_ASSERT_EQUAL(server.points, 0, "Should've spent 3 points on loading a 3 point domain")

/// Tests the netchair's ability to buckle in and set refs
/datum/unit_test/netchair_buckle/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/obj/structure/netchair/chair = allocate(/obj/structure/netchair, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	labrat.mind_initialize()
	labrat.mock_client = new()

	chair.find_server() // buckle_mob calls this but i want to test it separately
	TEST_ASSERT_NOTNULL(chair.server_ref, "Did not set server_ref")

	var/obj/machinery/quantum_server/connected_server = chair.server_ref.resolve()
	TEST_ASSERT_EQUAL(connected_server, server, "Did not set server_ref correctly")

	server.set_domain(labrat, map_id = TEST_MAP)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "Sanity: Did not load test map correctly")

	chair.buckle_mob(labrat, check_loc = FALSE)
	TEST_ASSERT_NOTNULL(chair.occupant_ref, "Did not set occupant_ref")
	UNTIL(!isnull(chair.occupant_mind_ref))
	TEST_ASSERT_EQUAL(server.occupant_mind_refs[1], chair.occupant_mind_ref, "Did not add mind to server occupant_mind_refs")

	var/mob/living/labrat_resolved = chair.occupant_ref.resolve()
	TEST_ASSERT_EQUAL(labrat, labrat_resolved, "Did not set occupant_ref correctly")

/// Tests the netchair's ability to disconnect
/datum/unit_test/netchair_disconnect/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/obj/structure/netchair/chair = allocate(/obj/structure/netchair, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/datum/weakref/server_ref = WEAKREF(server)
	var/datum/weakref/labrat_ref = WEAKREF(labrat)

	labrat.mind_initialize()
	labrat.mock_client = new()
	labrat.mind.key = "fake_mind"
	labrat.key = "fake_mind" // Original body gets a fake mind
	var/datum/mind/real_mind = WEAKREF(labrat.mind)

	chair.find_server()
	TEST_ASSERT_NOTNULL(chair.server_ref, "Sanity: Netchair did not set server_ref")

	chair.server_ref = null // We can use this to see if the disconnect was successful
	chair.disconnect_occupant(labrat.mind)
	TEST_ASSERT_NULL(chair.server_ref, "Should've prevented disconnect with no occupant")

	var/datum/mind/wrong_mind = new("wrong_mind") // 'another player'
	chair.occupant_mind_ref = real_mind
	chair.occupant_ref = labrat_ref
	chair.disconnect_occupant(wrong_mind)
	TEST_ASSERT_NULL(chair.server_ref, "Should've prevented disconnect with wrong mind destination")

	var/mob/living/occupant = chair.occupant_ref.resolve()
	chair.disconnect_occupant(labrat.mind)
	TEST_ASSERT_EQUAL(chair.server_ref, server_ref, "Should disconnect with CORRECT mind dest")
	TEST_ASSERT_EQUAL(occupant.get_organ_loss(ORGAN_SLOT_BRAIN), 0, "Should not have taken brain damage on disconnect")
	TEST_ASSERT_NOTNULL(chair.occupant_ref, "Should NOT clear occupant_ref, unbuckle only")
	TEST_ASSERT_NULL(chair.occupant_mind_ref, "Should've cleared occupant_mind_ref")

	/// Testing force disconn
	chair.server_ref = null
	chair.occupant_mind_ref = real_mind
	chair.occupant_ref = labrat_ref
	chair.disconnect_occupant(labrat.mind , forced = TRUE)
	TEST_ASSERT_NOTNULL(chair.server_ref, "Sanity: Chair didn't set server")
	TEST_ASSERT_EQUAL(occupant.get_organ_loss(ORGAN_SLOT_BRAIN), 60, "Should've taken brain damage on force disconn")

/// Tests cases where the netchair is destroyed or the occupant unbuckled
/datum/unit_test/netchair_unbuckle_or_qdel/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/obj/structure/netchair/chair = allocate(/obj/structure/netchair, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	labrat.mind_initialize()
	labrat.mock_client = new()
	labrat.mind.key = "fake_mind"
	var/datum/weakref/real_mind = WEAKREF(labrat.mind)

	server.set_domain(labrat, map_id = TEST_MAP)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "Sanity: Did not load test map correctly")

	chair.buckle_mob(labrat, check_loc = FALSE)
	UNTIL(!isnull(chair.occupant_mind_ref))
	TEST_ASSERT_EQUAL(chair.occupant_mind_ref, real_mind, "Sanity: Chair didn't set mind")

	chair.unbuckle_mob(labrat)
	TEST_ASSERT_NULL(chair.occupant_ref, "Should've cleared occupant_ref")
	TEST_ASSERT_EQUAL(labrat.get_organ_loss(ORGAN_SLOT_BRAIN), 60, "Should have taken brain damage on unbuckle")

	labrat.fully_heal()
	chair.buckle_mob(labrat, check_loc = FALSE)
	UNTIL(!isnull(chair.occupant_mind_ref))
	TEST_ASSERT_EQUAL(chair.occupant_mind_ref, real_mind, "Sanity: Chair didn't set mind")

	qdel(chair)
	TEST_ASSERT_EQUAL(labrat.get_organ_loss(ORGAN_SLOT_BRAIN), 60, "Should have taken brain damage on chair deletion")

/// Tests the connection between avatar and pilot
/datum/unit_test/avatar_connection/Run()
	var/obj/structure/netchair/chair = allocate(/obj/structure/netchair)
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human/consistent)

	labrat.mind_initialize()
	labrat.mock_client = new()
	labrat.mind.key = "test_key"

	var/datum/weakref/labrat_ref = WEAKREF(labrat)
	var/datum/weakref/initial_mind = labrat.mind
	var/datum/weakref/labrat_mind_ref = WEAKREF(labrat.mind)
	chair.occupant_mind_ref = labrat_mind_ref
	chair.occupant_ref = labrat_ref

	labrat.mind.initial_avatar_connection(labrat, target, chair, server)
	TEST_ASSERT_NOTNULL(target.mind, "Couldn't transfer mind to target")
	TEST_ASSERT_EQUAL(target.mind, initial_mind, "New mind is different from original")
	TEST_ASSERT_NOTNULL(target.mind.pilot_ref, "Could not set avatar_ref")
	TEST_ASSERT_NOTNULL(target.mind.netchair_ref, "Could not set netchair_ref")

	var/mob/living/carbon/human/labrat_resolved = target.mind.pilot_ref.resolve()
	TEST_ASSERT_EQUAL(labrat, labrat_resolved, "Wrong pilot ref")

	var/obj/structure/netchair/connected_chair = target.mind.netchair_ref.resolve()
	TEST_ASSERT_EQUAL(connected_chair, chair, "Wrong netchair ref")

	target.apply_damage(10, damagetype = BURN, def_zone = BODY_ZONE_HEAD, blocked = 0, forced = TRUE)
	TEST_ASSERT_EQUAL(labrat.getFireLoss(), 10, "Damage was not transferred to pilot")
	TEST_ASSERT_NOTNULL(locate(/obj/item/bodypart/head) in labrat.get_damaged_bodyparts(burn = TRUE), "Pilot did not get damaged bodypart")


	TEST_ASSERT_EQUAL(target.mind.pilot_ref.resolve(), labrat, "Pilot ref should not have changed")
	target.apply_damage(999, forced = TRUE, spread_damage = TRUE)
	TEST_ASSERT_EQUAL(target.stat, DEAD, "Target should have died on lethal damage")
	TEST_ASSERT_EQUAL(labrat.stat, DEAD, "Pilot should have died on lethal damage")
	TEST_ASSERT_EQUAL(initial_mind, labrat.mind, "Pilot should have been transferred back to initial mind")

	var/mob/living/carbon/human/to_gib = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/pincushion = allocate(/mob/living/carbon/human/consistent)
	pincushion.mind_initialize()
	pincushion.mock_client = new()
	pincushion.mind.key = "gibbed_key"
	var/datum/mind/pincushion_mind = pincushion.mind
	chair.occupant_mind_ref = WEAKREF(pincushion.mind)
	chair.occupant_ref = WEAKREF(pincushion)

	pincushion.mind.initial_avatar_connection(pincushion, to_gib, chair, server)
	TEST_ASSERT_EQUAL(to_gib.mind, pincushion_mind, "Pincushion mind should have been transferred to the gib target")

	to_gib.gib()
	TEST_ASSERT_EQUAL(pincushion_mind, pincushion.mind, "Pilot should have been transferred back on avatar gib")
	TEST_ASSERT_EQUAL(pincushion.get_organ_loss(ORGAN_SLOT_BRAIN), 60, "Pilot should have taken brain dmg on gib disconnect")

/// Tests the signals sent when the server is destroyed, mobs step on a loaded tile, etc
/datum/unit_test/bitmining_signals
	var/received = FALSE

/datum/unit_test/bitmining_signals/proc/on_proximity(datum/source, mob/living/intruder)
	SIGNAL_HANDLER
	received = TRUE

/datum/unit_test/bitmining_signals/proc/on_disconnect()
	SIGNAL_HANDLER
	received = TRUE

/datum/unit_test/bitmining_signals/Run()
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/obj/item/bitminer_trap/trap = allocate(/obj/item/bitminer_trap)
	var/area/test_area = get_area(labrat)
	labrat.mind_initialize()

	labrat.put_in_active_hand(trap, forced = TRUE)
	trap.attack_self(labrat)
	TEST_ASSERT_EQUAL(received, FALSE, "Trap should only be usable in the bit den")

	rename_area(test_area, "Bitmining: Den")
	trap.attack_self(labrat)
	TEST_ASSERT_EQUAL(trap.used, TRUE, "Trap did not activate")

	RegisterSignal(SSdcs, COMSIG_GLOB_BITMINING_PROXIMITY, PROC_REF(on_proximity))
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_BITMINING_PROXIMITY, labrat)
	TEST_ASSERT_EQUAL(received, TRUE, "Global bitmining prox signal was not received")

	received = FALSE
	labrat.forceMove(run_loc_floor_top_right)
	labrat.forceMove(run_loc_floor_bottom_left)
	TEST_ASSERT_EQUAL(received, TRUE, "Signal chain: Didn't receive bitmining_proximity signal from armed tile")

	received = FALSE
	RegisterSignal(server, COMSIG_QSERVER_DISCONNECTED, PROC_REF(on_disconnect))
	qdel(server)
	TEST_ASSERT_EQUAL(received, TRUE, "Signal chain: Didn't receive qserver_disconnected signal from qserver deletion")

/// Tests the server's ability to buff and nerf mobs
/datum/unit_test/quantum_server_difficulty/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)
	var/datum/weakref/labrat_mind_ref = WEAKREF(labrat.mind)


	server.cold_boot_map(labrat, map_id = TEST_MAP_MOBS)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP_MOBS, "Sanity: Didn't load test map correctly")
	var/mob/living/basic/pet/dog/corgi/pupper = locate(/mob/living/basic/pet/dog/corgi) in server.generated_domain.created_atoms
	TEST_ASSERT_NOTNULL(pupper, "Sanity: Couldn't find mobs in vdom")

	var/base_health = pupper.health
	server.client_connect(labrat_mind_ref)
	TEST_ASSERT_EQUAL(pupper.health, base_health, "QServer shouldn't buff mobs on first bitminer connect")

	server.client_connect(labrat_mind_ref)
	TEST_ASSERT_EQUAL(pupper.health, base_health * server.difficulty_coeff, "QServer should buff mobs 1.5x on second bitminer connect")

	server.client_connect(labrat_mind_ref)
	TEST_ASSERT_EQUAL(pupper.health, base_health * server.difficulty_coeff * server.difficulty_coeff, "QServer should buff mobs 1.5x on third bitminer connect")

	server.client_disconnect(labrat_mind_ref)
	TEST_ASSERT_EQUAL(pupper.health, base_health * server.difficulty_coeff, "QServer should nerf mobs 1.5x on first bitminer disconnect")

	server.client_disconnect(labrat_mind_ref)
	TEST_ASSERT_EQUAL(pupper.health, base_health, "QServer should nerf mobs 1.5x on second bitminer disconnect")

	server.client_disconnect(labrat_mind_ref)
	TEST_ASSERT_EQUAL(pupper.health, base_health, "QServer should not nerf mobs below base health")

/// Server side randomization of domains
/datum/unit_test/quantum_server_get_random_domain_id/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/datum/map_template/virtual_domain/selected

	var/id = server.get_random_domain_id()
	TEST_ASSERT_NULL(id, "Shouldn't return a random domain with no points")

	server.points = 3
	id = server.get_random_domain_id()
	TEST_ASSERT_NOTNULL(id, "Should return a random domain with points")

	/// Can't truly test the randomization past this

/// Tests getting list of domain generated mobs for antag targets
/datum/unit_test/quantum_server_get_valid_domain_mobs/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)

	server.cold_boot_map(labrat, map_id = TEST_MAP_MOBS)
	TEST_ASSERT_NOTNULL(server.generated_domain, "Sanity: Did not load test map correctly")

	server.occupant_mind_refs += WEAKREF(labrat.mind)
	var/list/mobs = server.get_valid_domain_targets()
	TEST_ASSERT_EQUAL(length(mobs), 1, "Should return a list of mobs")

	var/mob/living/basic/pet/dog/corgi/pupper = locate(/mob/living/basic/pet/dog/corgi) in mobs
	TEST_ASSERT_NOTNULL(pupper, "Should be a corgi on test map")

	pupper.key = "fake_mind"
	mobs = server.get_valid_domain_targets()
	TEST_ASSERT_EQUAL(length(mobs), 0, "Should not return mobs with keys")

#undef TEST_MAP
#undef TEST_MAP_EXPENSIVE
#undef TEST_MAP_MOBS
