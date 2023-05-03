/**
 * Lightzone test
 *
 * Checks to see if a controller can find a lightzone in a given hour.
 */
/datum/unit_test/lightzones

/datum/unit_test/lightzones/Run()
	for(var/datum/day_night_controller/iterating_controller as anything in subtypesof(/datum/lightzone))
		iterating_controller = allocate(iterating_controller)
		for(var/hour in 0 to 23)
			var/found_lightzone
			for(var/datum/lightzone/iterating_lightzone as anything in iterating_controller.lightzone_cache)
				if((hour >= iterating_lightzone.start_hour) && (hour < (!iterating_lightzone.end_hour ? 24 : iterating_lightzone.end_hour)))
					found_lightzone = iterating_lightzone
			TEST_ASSERT(!found_lightzone, "Error while finding a lightzone in slot [hour] for [iterating_controller]!")
