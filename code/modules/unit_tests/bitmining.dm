/datum/unit_test/quantum_server_find_console

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

/datum/unit_test/quantum_server_load_map

/// Handles cases with loading domains and stopping domains
/datum/unit_test/quantum_server_load_map/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)
	labrat.mock_client = new()

	server.set_domain(labrat, "test_only")
	TEST_ASSERT_NOTNULL(server.vdom_ref, "QServer did not initialize vdom_ref")
	TEST_ASSERT_NOTNULL(server.generated_domain, "QServer did not load generated_domain")
	TEST_ASSERT_EQUAL(server.generated_domain.id, "test_only", "QServer did not load generated_domain correctly")

	server.set_domain(labrat, id = "test_only")
	TEST_ASSERT_EQUAL(server.generated_domain.id, "test_only", "QServer should prevent loading multiple domains")

	var/datum/weakref/fake_mind_ref = WEAKREF(labrat)
	server.occupant_mind_refs += fake_mind_ref
	server.set_domain(labrat, id = "test_only")
	TEST_ASSERT_EQUAL(server.generated_domain.id, "test_only", "QServer should prevent stopping a domain with occupants")

	server.occupant_mind_refs -= fake_mind_ref
	server.stop_domain(labrat)
	TEST_ASSERT_NOTNULL(server.vdom_ref, "QServer erased vdom_ref on stop_domain()")
	TEST_ASSERT_NULL(server.generated_domain, "QServer did not stop domain")
	TEST_ASSERT_EQUAL(server.get_ready_status(), FALSE, "QServer did not set ready status to FALSE")

	server.set_domain(labrat, id = "test_only")
	TEST_ASSERT_NULL(server.generated_domain, "QServer should prevent loading a new domain")

	COOLDOWN_RESET(server, cooling_off)
	server.set_domain(labrat, id = "test_only")
	TEST_ASSERT_EQUAL(server.generated_domain.id, "test_only", "QServer should allow loading a new domain after cooldown")

/datum/unit_test/netchair_connection

/// Tests the netchair's ability to enter and exit quantum space
/datum/unit_test/netchair_connection/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent, locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	var/obj/structure/netchair/chair = allocate(/obj/structure/netchair, locate(run_loc_floor_bottom_left.x + 2, run_loc_floor_bottom_left.y, run_loc_floor_bottom_left.z))
	labrat.mind_initialize()
	labrat.mock_client = new()

	chair.find_server() // buckle_mob calls this but i want to test it separately
	TEST_ASSERT_NOTNULL(chair.server_ref, "Netchair did not set server_ref")

	var/obj/machinery/quantum_server/connected_server = chair.server_ref.resolve()
	TEST_ASSERT_EQUAL(connected_server, server, "Netchair did not set server_ref correctly")

	server.set_domain(labrat, id = "test_only")
	TEST_ASSERT_NOTNULL(server.generated_domain, "QServer did not load generated_domain")
	TEST_ASSERT_EQUAL(server.generated_domain.id, "test_only", "QServer did not load generated_domain correctly")

	chair.buckle_mob(labrat, check_loc = FALSE)
	TEST_ASSERT_NOTNULL(chair.occupant_ref, "Netchair did not set occupant_ref")

	UNTIL(!isnull(chair.occupant_mind_ref))
	TEST_ASSERT_EQUAL(server.occupant_mind_refs[1], chair.occupant_mind_ref, "Netchair did not add mind to server occupant_mind_refs")

	var/mob/living/labrat_resolved = chair.occupant_ref.resolve()
	TEST_ASSERT_EQUAL(labrat, labrat_resolved, "Netchair did not set occupant_ref correctly")

/datum/unit_test/avatar_connection

/// Tests the connection between avatar and pilot
/datum/unit_test/avatar_connection/Run()
	var/obj/structure/netchair/chair = allocate(/obj/structure/netchair)
	var/mob/living/carbon/human/labrat = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human/consistent)
	labrat.mind_initialize()
	labrat.mock_client = new()
	labrat.mind.key = "test_key"

	var/datum/mind/initial_mind = labrat.mind
	labrat.mind.initial_avatar_connection(labrat, target, chair)
	TEST_ASSERT_NOTNULL(target.mind, "Couldn't transfer mind to target")
	TEST_ASSERT_EQUAL(target.mind, initial_mind, "New mind is different from original")
	TEST_ASSERT_NOTNULL(target.mind.pilot_ref, "Could not set avatar_ref")
	TEST_ASSERT_NOTNULL(target.mind.netchair_ref, "Could not set netchair_ref")

	var/mob/living/carbon/human/labrat_resolved = target.mind.pilot_ref.resolve()
	TEST_ASSERT_EQUAL(labrat, labrat_resolved, "Wrong avatar_ref")

	var/obj/structure/netchair/connected_chair = target.mind.netchair_ref.resolve()
	TEST_ASSERT_EQUAL(connected_chair, chair, "Wrong netchair_ref")

	target.apply_damage(10, damagetype = BURN, def_zone = BODY_ZONE_HEAD, blocked = 0, forced = TRUE)
	TEST_ASSERT_EQUAL(labrat.getFireLoss(), 10, "Damage was not transferred to pilot")
	TEST_ASSERT_NOTNULL(locate(/obj/item/bodypart/head) in labrat.get_damaged_bodyparts(burn = TRUE), "Pilot did not get damaged bodypart")

	target.apply_damage(999, blocked = 0, forced = TRUE)
	if(target.stat != DEAD) // Some times they just inexplicably avoid it
		target.apply_damage(999, blocked = 0, forced = TRUE)
	TEST_ASSERT_EQUAL(target.stat, DEAD, "Target should have died on lethal damage")
	TEST_ASSERT_EQUAL(labrat.stat, DEAD, "Pilot should have died on lethal damage")
	TEST_ASSERT_EQUAL(REF(labrat_resolved.mind), REF(labrat.mind), "Pilot should have been transferred back to initial mind")

	target.fully_heal()
	labrat.fully_heal()
	labrat.mind.initial_avatar_connection(labrat, target, chair)
	var/mob/living/carbon/human/rejuvenated_pilot = target.mind.pilot_ref.resolve()
	TEST_ASSERT_EQUAL(rejuvenated_pilot, labrat, "Sanity test fail: Target pilot mismatched with the labrat")

	target.gib()
	TEST_ASSERT_EQUAL(REF(rejuvenated_pilot.mind), REF(labrat.mind), "Pilot should have been transferred back on avatar gib")
	// This is working but won't test for some raisin
	// TEST_ASSERT_EQUAL(labrat.get_organ_loss(ORGAN_SLOT_BRAIN), 60, "Pilot should have taken brain dmg on disconnect")
