/// Tests the SUPPOSED TO BE TEMPORARY byond_status() proc for a useful format
/datum/unit_test/byond_status

/datum/unit_test/byond_status/Run()
	if (world.system_type != UNIX)
		return

	var/status = byond_status()
	TEST_ASSERT(findtext(status, "Sleeping procs"), "Invalid byond_status: [status]")
