/// Validates status effect tick interval setup
/datum/unit_test/status_effect_ticks

/datum/unit_test/status_effect_ticks/Run()
	for(var/datum/status_effect/checking as anything in subtypesof(/datum/status_effect))
		var/checking_tick = initial(checking.tick_interval)
		if(checking_tick == -1)
			continue
		if(checking_tick == INFINITY)
			TEST_FAIL("Status effect [checking] has tick_interval set to INFINITY, this is not how you prevent ticks - use tick_interval = -1 instead.")
			continue
		if(checking_tick == 0)
			TEST_FAIL("Status effect [checking] has tick_interval set to 0, this is not how you prevent ticks - use tick_interval = -1 instead.")
			continue
		switch(initial(checking.processing_speed))
			if(STATUS_EFFECT_FAST_PROCESS)
				if(checking_tick < SSfastprocess.wait)
					TEST_FAIL("Status effect [checking] has tick_interval set to [checking_tick], which is faster than SSfastprocess can tick ([SSfastprocess.wait]).")
			if(STATUS_EFFECT_NORMAL_PROCESS)
				if(checking_tick < SSprocessing.wait)
					TEST_FAIL("Status effect [checking] has tick_interval set to [checking_tick], which is faster than SSprocessing can tick ([SSprocessing.wait]).")
			else
				TEST_FAIL("Invalid processing speed for status effect [checking] : [initial(checking.processing_speed)]")
