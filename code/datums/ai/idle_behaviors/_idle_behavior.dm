/datum/idle_behavior

/datum/idle_behavior/proc/perform_idle_behavior(seconds_per_tick, datum/ai_controller/controller)
	set waitfor = FALSE
	SHOULD_CALL_PARENT(TRUE)
