/// Validates status effect tick interval setup
/datum/unit_test/status_effect_ticks

/datum/unit_test/status_effect_ticks/Run()
	for(var/datum/status_effect/checking as anything in subtypesof(/datum/status_effect))
		if(initial(checking.id) == STATUS_EFFECT_ID_ABSTRACT)
			continue
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
			if(STATUS_EFFECT_PRIORITY)
				var/priority_wait = world.tick_lag * SSpriority_effects.wait // SSpriority_effects has the SS_TICKER flag, so its wait is in ticks, so we have to convert it to deciseconds.
				if(tick_speed < priority_wait)
					TEST_FAIL("Status effect [checking] has tick_interval set to [tick_speed], which is faster than SSpriority_effects can tick ([priority_wait]).")
			else
				TEST_FAIL("Invalid processing speed for status effect [checking] : [initial(checking.processing_speed)]")

/// Validates status effect alert type setup
/datum/unit_test/status_effect_alert

/datum/unit_test/status_effect_alert/Run()
	// The base typepath is used to indicate "I didn't set an alert type"
	var/bad_alert_type = /datum/status_effect::alert_type
	TEST_ASSERT_NOTNULL(bad_alert_type, "No alert type defined in /datum/status_effect - This test may be redundant now.")

	for(var/datum/status_effect/checking as anything in subtypesof(/datum/status_effect))
		if(initial(checking.id) == STATUS_EFFECT_ID_ABSTRACT)
			continue
		if(initial(checking.alert_type) != bad_alert_type)
			continue
		TEST_FAIL("[checking] has not set alert_type. If you don't want an alert, set alert_type = null - \
			Otherwise, give it an alert subtype.")

/// Validates status effect id setup
/datum/unit_test/status_effect_ids

/datum/unit_test/status_effect_ids/Run()
	// The base id is used to indicate "I didn't set an id"
	var/bad_id = /datum/status_effect::id
	TEST_ASSERT_NOTNULL(bad_id, "No id defined in /datum/status_effect - This test may be redundant now.")

	for(var/datum/status_effect/checking as anything in subtypesof(/datum/status_effect))
		if(initial(checking.id) == STATUS_EFFECT_ID_ABSTRACT)
			// we are just assuming that a child of an abstract should not be abstract.
			// of course in practice, this may not always be the case - but if you're
			// structuring a status effect like this, you can just change the parent id to anything else
			var/datum/status_effect/checking_parent = initial(checking.parent_type)
			if(initial(checking_parent.id) != STATUS_EFFECT_ID_ABSTRACT)
				continue
		if(initial(checking.id) != bad_id)
			continue
		TEST_FAIL("[checking] has not set an id. This is required for status effects.")
