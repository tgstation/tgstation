/// Tests the SUPPOSED TO BE TEMPORARY byond_status() proc for a useful format
TEST_FOCUS(/datum/unit_test/byond_status)

/datum/unit_test/byond_status/Run()
	if (world.system_type != UNIX)
		return

	var/status = byond_status()
	if (!("Sleeping procs" in status))
		TEST_FAIL("Invalid byond_status: [status]")
