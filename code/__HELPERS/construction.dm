/// Produces a new RCD result from the given one if it can be calculated that
/// the RCD should speed up with the remembered form.
/proc/rcd_result_with_memory(list/defaults, turf/place, expected_memory)
	if (place?.rcd_memory == expected_memory)
		return defaults + list(
			"cost" = defaults["cost"] / RCD_MEMORY_COST_BUFF,
			"delay" = defaults["delay"] / RCD_MEMORY_SPEED_BUFF,
			RCD_RESULT_BYPASS_FREQUENT_USE_COOLDOWN = TRUE,
		)
	else
		return defaults
