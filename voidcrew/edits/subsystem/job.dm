/**
 * This sets the overflow role, and maxes out its job positions.
 * We instead use the job overflow to show what is the 'Captain' job of the roundstart template.
 * Therefore, we don't want to use this, we instead manually set it on `/datum/job/map_check()`
 */
/datum/controller/subsystem/job/set_overflow_role(new_overflow_role)
	return
