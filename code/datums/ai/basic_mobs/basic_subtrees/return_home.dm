/// Will try to return to an area if not already inside it
/datum/ai_planning_subtree/return_home
	/// Blackboard tag where you can find the home location
	var/area_key = BB_MOB_HOME_AREA
	/// Blackboard key to store a weakref to a specific turf inside, to avoid unnecessary recalculation
	var/turf_key = BB_MOB_HOME_TURF

/datum/ai_planning_subtree/return_home/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	var/area/home_area = controller.blackboard[area_key]
	if (!home_area)
		return
	if (get_area(controller.pawn) == home_area)
		return
	controller.queue_behavior(/datum/ai_behavior/step_towards_turf/in_area, turf_key, area_key)
	return SUBTREE_RETURN_FINISH_PLANNING
