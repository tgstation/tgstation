/// Tests the SUPPOSED TO BE TEMPORARY byond_status() proc for a useful format
/datum/unit_test/byond_status

/datum/unit_test/byond_status/Run()
	if (system_type != UNIX)
		return

	var/status = byond_status()
	if (!("Sleeping procs") in status)
		log_test("Invalid byond_status: [status]")
