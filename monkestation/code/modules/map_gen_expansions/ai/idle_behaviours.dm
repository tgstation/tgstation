/datum/idle_behavior/idle_random_walk/hide


/datum/idle_behavior/idle_random_walk/hide/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	// You can't move when you're hidden.
	if(controller.blackboard[BB_HIDING_HIDDEN])
		return FALSE

	return ..()
