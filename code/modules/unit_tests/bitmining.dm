/datum/unit_test/quantum_server_find_console/Run()
	var/obj/machinery/computer/quantum_console/console = allocate(/obj/machinery/computer/quantum_console)
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)

	console.find_server()

	TEST_ASSERT_NOTNULL(console.server_ref)
	TEST_ASSERT_NOTNULL(server.console_ref)


/datum/unit_test/netchair_find_server/Run()
	var/obj/machinery/quantum_server/server = allocate(/obj/machinery/quantum_server)
	var/obj/structure/netchair/chair = allocate(/obj/structure/netchair)

	chair.find_server()

	TEST_ASSERT_NOTNULL(chair.server_ref)


