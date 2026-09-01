/// Conveys all log_mapping messages as unit test failures, as they all indicate mapping problems.
/datum/unit_test/maptest_log_mapping
	test_flags = UNIT_TEST_MAP_TEST
	// Happen before all other tests, to make sure we only capture normal mapping logs.
	priority = TEST_PRE

/datum/unit_test/maptest_log_mapping/Run()
	for(var/log_entry in GLOB.unit_test_mapping_logs)
		TEST_FAIL(log_entry)
