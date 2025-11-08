/// Validates status effect tick interval setup
/datum/unit_test/status_effect_ticks

/datum/unit_test/status_effect_ticks/Run()
	for(var/datum/status_effect/checking as anything in subtypesof(/datum/status_effect))
		if(initial(checking.id) == STATUS_EFFECT_ID_ABSTRACT)
			continue
		var/tick_speed = initial(checking.tick_interval)
		if(tick_speed == STATUS_EFFECT_NO_TICK)
			continue
		if(tick_speed < 0)
			TEST_FAIL("Status effect [checking] has tick_interval set to a negative value other than STATUS_EFFECT_NO_TICK, this is not how you prevent ticks - use tick_interval = STATUS_EFFECT_NO_TICK instead.")
			continue
		if(tick_speed == INFINITY)
			TEST_FAIL("Status effect [checking] has tick_interval set to INFINITY, this is not how you prevent ticks - use tick_interval = STATUS_EFFECT_NO_TICK instead.")
			continue
		switch(initial(checking.processing_speed))
			if(STATUS_EFFECT_FAST_PROCESS)
				if(tick_speed % SSfastprocess.wait != 0 && tick_speed != STATUS_EFFECT_AUTO_TICK)
					TEST_FAIL("Status effect [checking] has tick_interval set to [tick_speed], which is not a multiple of SSfastprocess wait time ([SSfastprocess.wait]).")
			if(STATUS_EFFECT_NORMAL_PROCESS)
				if(tick_speed % SSprocessing.wait != 0 && tick_speed != STATUS_EFFECT_AUTO_TICK)
					TEST_FAIL("Status effect [checking] has tick_interval set to [tick_speed], which is not a multiple of SSprocessing wait time ([SSprocessing.wait]).")
			if(STATUS_EFFECT_PRIORITY)
				var/priority_wait = world.tick_lag * SSpriority_effects.wait // SSpriority_effects has the SS_TICKER flag, so its wait is in ticks, so we have to convert it to deciseconds.
				if(tick_speed % priority_wait != 0 && tick_speed != STATUS_EFFECT_AUTO_TICK)
					TEST_FAIL("Status effect [checking] has tick_interval set to [tick_speed], which is not a multiple of SSpriority_effects wait time ([priority_wait]).")
			else
				TEST_FAIL("Invalid processing speed for status effect [checking] : [initial(checking.processing_speed)]")

/// Validates status effect duration setup
/datum/unit_test/status_effect_duration

/datum/unit_test/status_effect_duration/Run()
	for(var/datum/status_effect/checking as anything in subtypesof(/datum/status_effect))
		if(initial(checking.id) == STATUS_EFFECT_ID_ABSTRACT)
			continue
		var/duration = initial(checking.duration)
		if(duration == STATUS_EFFECT_PERMANENT)
			continue
		if(duration == INFINITY) // for some god forsaken reason, this is allowed
			continue
		if(duration < 0)
			TEST_FAIL("Status effect [checking] has duration set to a negative value other than STATUS_EFFECT_PERMANENT, this is not how you make effects last forever - use duration = STATUS_EFFECT_PERMANENT instead.")
			continue
		switch(initial(checking.processing_speed))
			if(STATUS_EFFECT_FAST_PROCESS)
				if(duration % SSfastprocess.wait != 0)
					TEST_FAIL("Status effect [checking] has duration set to [duration], which is not a multiple of SSfastprocess wait time ([SSfastprocess.wait]).")
			if(STATUS_EFFECT_NORMAL_PROCESS)
				if(duration % SSprocessing.wait != 0)
					TEST_FAIL("Status effect [checking] has duration set to [duration], which is not a multiple of SSprocessing wait time ([SSprocessing.wait]).")
			if(STATUS_EFFECT_PRIORITY)
				var/priority_wait = world.tick_lag * SSpriority_effects.wait // SSpriority_effects has the SS_TICKER flag, so its wait is in ticks, so we have to convert it to deciseconds.
				if(duration % priority_wait != 0)
					TEST_FAIL("Status effect [checking] has duration set to [duration], which is not a multiple of SSpriority_effects wait time ([priority_wait]).")
			else
				TEST_FAIL("Invalid processing speed for status effect [checking] : [initial(checking.processing_speed)]")

/// Validates that status effect tick counts are directly proportional to duration, and that seconds_between_ticks added up is equal to duration.
/datum/unit_test/status_effect_tick_counts

/datum/unit_test/status_effect_tick_counts/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human/consistent, run_loc_floor_bottom_left)

	var/datum/status_effect/unit_test_tick_counter/counter = user.apply_status_effect(/datum/status_effect/unit_test_tick_counter)

	// The 0.2 here and in the for loop is arbitrary and can be any value that divides evenly into the duration and tick interval of the unit test status effect.
	// I chose 0.2 specifically because it just happens to be the SSfastprocess.wait in seconds, which basically simulates this status effect running on SSfastprocess.
	var/ticks_required = counter.duration / 10 / 0.2 + 1

	for (var/i in 1 to ticks_required)
		if (!QDELETED(counter))
			counter.process(0.2)

	var/expected_tick_count = initial(counter.duration) / counter.tick_interval
	if (abs(counter.total_tick_count - expected_tick_count) > 0.01)
		TEST_FAIL("Status effect tick count is not directly proportional to duration. Expected [expected_tick_count] ticks, got [counter.total_tick_count] ticks.")

	var/expected_seconds = initial(counter.duration) / 10
	if (abs(counter.total_seconds - expected_seconds) > 0.01)
		TEST_FAIL("Status effect seconds_between_ticks accumulated together does not equal duration. Expected [expected_seconds] seconds, got [counter.total_seconds] seconds.")

	QDEL_NULL(counter)

/datum/status_effect/unit_test_tick_counter
	duration = 10 SECONDS
	tick_interval = 0.4 SECONDS

	id = "unit_test_tick_counter"
	alert_type = null

	var/total_tick_count = 0
	var/total_seconds = 0

/datum/status_effect/unit_test_tick_counter/tick(seconds_between_ticks)
	total_tick_count++
	total_seconds += seconds_between_ticks

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
