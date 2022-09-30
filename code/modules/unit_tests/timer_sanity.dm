/datum/unit_test/timer_sanity/Run()
	TEST_ASSERT(SStimer.bucket_count >= 0,
		"SStimer is going into negative bucket count from something")
