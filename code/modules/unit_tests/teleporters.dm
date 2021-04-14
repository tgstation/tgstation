/datum/unit_test/auto_teleporter_linking/Run()
	// Put down the teleporter machinery
	var/obj/machinery/teleport/hub/hub = allocate(/obj/machinery/teleport/hub)
	var/obj/machinery/teleport/station/station = allocate(/obj/machinery/teleport/station, locate(run_loc_bottom_left.x + 1, run_loc_bottom_left.y, run_loc_bottom_left.z))
	var/obj/machinery/computer/teleporter/computer = allocate(/obj/machinery/computer/teleporter, locate(run_loc_bottom_left.x + 2, run_loc_bottom_left.y, run_loc_bottom_left.z))

	TEST_ASSERT_EQUAL(hub.power_station, station, "Hub didn't link to the station")
	TEST_ASSERT_EQUAL(station.teleporter_console, computer, "Station didn't link to the teleporter console")
	TEST_ASSERT_EQUAL(station.teleporter_hub, hub, "Station didn't link to the hub")
	TEST_ASSERT_EQUAL(computer.power_station, station, "Teleporter console didn't link to the hub")
