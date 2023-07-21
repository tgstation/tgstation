#define TEST_MAP "test_only"
#define TEST_MAP_EXPENSIVE "test_only_expensive"

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

/// Loading virtual domain
/datum/unit_test/quantum_server_generate_vdom/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent, run_loc_floor_top_right)
	labrat.mock_client = new()
	var/obj/machinery/computer/quantum_console/console = allocate(/obj/machinery/computer/quantum_console, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))

	TEST_ASSERT_NOTNULL(server.console_ref, "Sanity: QServer did not find the console")

	server.generate_virtual_domain(labrat)
	TEST_ASSERT_NOTNULL(server.vdom_ref, "QServer did not generate vdom")
	TEST_ASSERT_EQUAL(length(server.map_load_turf), 1, "There should only ever be ONE turf, the bottom left, in the map_load_turf list")
	TEST_ASSERT_EQUAL(length(server.safehouse_load_turf), 1, "There should only ever be ONE turf, the bottom left, in the safehouse_load_turf list")

/// Handles cases with loading domains
/datum/unit_test/quantum_server_set_domain/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent, run_loc_floor_top_right)
	var/obj/machinery/computer/quantum_console/console = allocate(/obj/machinery/computer/quantum_console, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	labrat.mock_client = new()

	server.set_domain(labrat, id = TEST_MAP)
	TEST_ASSERT_NOTNULL(server.vdom_ref, "QServer did not initialize vdom_ref")
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "QServer did not load generated_domain correctly")

	server.set_domain(labrat, TEST_MAP_EXPENSIVE)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "QServer should prevent loading multiple domains")

	server.stop_domain()
	COOLDOWN_RESET(server, cooling_off)
	var/datum/weakref/fake_mind_ref = WEAKREF(labrat)
	server.occupant_mind_refs += fake_mind_ref
	server.set_domain(labrat, id = TEST_MAP)
	TEST_ASSERT_NULL(server.generated_domain, "QServer should prevent setting a domain with occupants")

	server.occupant_mind_refs -= fake_mind_ref
	server.points = 3
	server.set_domain(labrat, id = TEST_MAP_EXPENSIVE)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP_EXPENSIVE, "Sanity: Qserver should've loaded expensive test map")
	TEST_ASSERT_EQUAL(server.points, 0, "QServer should've spent 3 points on loading a 3 point domain")

/// Handles cases with stopping domains. The server should cool down & prevent stoppage with active mobs
/datum/unit_test/quantum_server_stop_domain/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)
	labrat.mock_client = new()

	server.set_domain(labrat, id = TEST_MAP)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "Sanity: QServer should've loaded test_only map")

	server.stop_domain()
	TEST_ASSERT_NOTNULL(server.vdom_ref, "QServer erased vdom_ref on stop_domain()")
	TEST_ASSERT_NULL(server.generated_domain, "QServer did not stop domain")
	TEST_ASSERT_EQUAL(server.get_ready_status(), FALSE, "QServer should cool down, but did not set ready status to FALSE")

	server.set_domain(labrat, id = TEST_MAP)
	TEST_ASSERT_NULL(server.generated_domain, "QServer should prevent loading a new domain while cooling down")

	COOLDOWN_RESET(server, cooling_off)
	server.set_domain(labrat, id = TEST_MAP)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "QServer should load a new domain after cooldown")

	var/datum/weakref/fake_mind_ref = WEAKREF(labrat)
	server.occupant_mind_refs += fake_mind_ref
	server.stop_domain()
	TEST_ASSERT_NULL(server.generated_domain, "QServer should force stop a domain even with occupants")

/// Tests the netchair's ability to buckle in and set refs
/datum/unit_test/netchair_buckle/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/obj/structure/netchair/chair = allocate(/obj/structure/netchair, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	labrat.mind_initialize()
	labrat.mock_client = new()

	chair.find_server() // buckle_mob calls this but i want to test it separately
	TEST_ASSERT_NOTNULL(chair.server_ref, "Netchair did not set server_ref")

	var/obj/machinery/quantum_server/connected_server = chair.server_ref.resolve()
	TEST_ASSERT_EQUAL(connected_server, server, "Netchair did not set server_ref correctly")

	server.set_domain(labrat, id = TEST_MAP)
	TEST_ASSERT_EQUAL(server.generated_domain.id, TEST_MAP, "Sanity: QServer did not load test map correctly")

	chair.buckle_mob(labrat, check_loc = FALSE)
	TEST_ASSERT_NOTNULL(chair.occupant_ref, "Netchair did not set occupant_ref")
	UNTIL(!isnull(chair.occupant_mind_ref))
	TEST_ASSERT_EQUAL(server.occupant_mind_refs[1], chair.occupant_mind_ref, "Netchair did not add mind to server occupant_mind_refs")

	var/mob/living/labrat_resolved = chair.occupant_ref.resolve()
	TEST_ASSERT_EQUAL(labrat, labrat_resolved, "Netchair did not set occupant_ref correctly")

/// Tests the netchair's ability to disconnect
/datum/unit_test/nerchair_disconnect/Run()
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
	var/obj/item/assembly/bitminer_trap/trap = allocate(/obj/item/assembly/bitminer_trap)
	var/area/test_area = get_area(labrat)
	labrat.mind_initialize()

	labrat.put_in_active_hand(trap, forced = TRUE)
	trap.attack_self(labrat)
	TEST_ASSERT_EQUAL(received, FALSE, "Trap should only be usable in the bit den")

	rename_area(test_area, "Bitmining Den")
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

#undef TEST_MAP
#undef TEST_MAP_EXPENSIVE
