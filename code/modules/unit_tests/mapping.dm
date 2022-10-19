/// Conveys all log_mapping messages as unit test failures, as they all indicate mapping problems.
/datum/unit_test/log_mapping
	// Happen before all other tests, to make sure we only capture normal mapping logs.
	priority = TEST_PRE

/datum/unit_test/log_mapping/Run()
	var/static/regex/test_areacoord_regex = regex(@"\(-?\d+,-?\d+,(-?\d+)\)")

	for(var/log_entry in GLOB.unit_test_mapping_logs)
		// Only fail if AREACOORD was conveyed, and it's a station or mining z-level.
		// This is due to mapping errors don't have coords being impossible to diagnose as a unit test,
		// and various ruins frequently intentionally doing non-standard things.
		if(!test_areacoord_regex.Find(log_entry))
			continue
		var/z = text2num(test_areacoord_regex.group[1])
		if(!is_station_level(z) && !is_mining_level(z))
			continue

		TEST_FAIL(log_entry)
