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
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	dummy.mock_client = new()

	server.set_domain(dummy, "test_only")
	TEST_ASSERT_NOTNULL(server.vdom_ref, "QServer did not initialize vdom_ref")
	TEST_ASSERT_NOTNULL(server.generated_domain, "QServer did not load generated_domain")
	TEST_ASSERT_EQUAL(server.generated_domain.id, "test_only", "QServer did not load generated_domain correctly")

	server.set_domain(dummy, id = "test_only")
	TEST_ASSERT_EQUAL(server.generated_domain.id, "test_only", "QServer should prevent loading multiple domains")

	var/datum/weakref/fake_mind_ref = WEAKREF(dummy)
	server.occupant_mind_refs += fake_mind_ref
	server.set_domain(dummy, id = "test_only")
	TEST_ASSERT_EQUAL(server.generated_domain.id, "test_only", "QServer should prevent stopping a domain with occupants")

	server.occupant_mind_refs -= fake_mind_ref
	server.stop_domain(dummy)
	TEST_ASSERT_NOTNULL(server.vdom_ref, "QServer erased vdom_ref on stop_domain()")
	TEST_ASSERT_NULL(server.generated_domain, "QServer did not stop domain")
	TEST_ASSERT_EQUAL(server.get_ready_status(), FALSE, "QServer did not set ready status to FALSE")

	server.set_domain(dummy, id = "test_only")
	TEST_ASSERT_NULL(server.generated_domain, "QServer should prevent loading a new domain")

	COOLDOWN_RESET(server, cooling_off)
	server.set_domain(dummy, id = "test_only")
	TEST_ASSERT_EQUAL(server.generated_domain.id, "test_only", "QServer should allow loading a new domain after cooldown")




