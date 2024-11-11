/// Validates status effect tick interval setup
/datum/unit_test/status_effect_ticks

/datum/unit_test/status_effect_ticks/Run()
	for(var/datum/status_effect/checking as anything in subtypesof(/datum/status_effect))
		var/tick_speed = initial(checking.tick_interval)
		if(tick_speed == STATUS_EFFECT_NO_TICK)
			continue
		if(tick_speed == INFINITY)
			TEST_FAIL("Status effect [checking] has tick_interval set to INFINITY, this is not how you prevent ticks - use tick_interval = STATUS_EFFECT_NO_TICK instead.")
			continue
		if(tick_speed == 0)
			TEST_FAIL("Status effect [checking] has tick_interval set to 0, this is not how you prevent ticks - use tick_interval = STATUS_EFFECT_NO_TICK instead.")
			continue
		switch(initial(checking.processing_speed))
			if(STATUS_EFFECT_FAST_PROCESS)
				if(tick_speed < SSfastprocess.wait)
					TEST_FAIL("Status effect [checking] has tick_interval set to [tick_speed], which is faster than SSfastprocess can tick ([SSfastprocess.wait]).")
			if(STATUS_EFFECT_NORMAL_PROCESS)
				if(tick_speed < SSprocessing.wait)
					TEST_FAIL("Status effect [checking] has tick_interval set to [tick_speed], which is faster than SSprocessing can tick ([SSprocessing.wait]).")
			else
				TEST_FAIL("Invalid processing speed for status effect [checking] : [initial(checking.processing_speed)]")
