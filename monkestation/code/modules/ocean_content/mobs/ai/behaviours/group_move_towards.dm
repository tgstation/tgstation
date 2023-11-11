/datum/ai_behavior/step_towards_turf/group_movement
	overwrites_main = TRUE

/datum/ai_behavior/step_towards_turf/group_movement/setup(datum/ai_controller/controller, turf_key)
	var/datum/group_planning/listed_group = controller.blackboard[BB_GROUP_DATUM]
	var/turf/target_turf = listed_group.target

	if(!target_turf)
		listed_group.decide_next_action()
		target_turf = listed_group.target
		if(!target_turf)
			return FALSE

	if (target_turf.z != controller.pawn.z)
		return FALSE

	var/turf/destination = plot_movement(controller, target_turf)
	if (!destination)
		return FALSE
	set_movement_target(controller, destination)
	return ..()


/datum/ai_behavior/step_towards_turf/group_movement/finish_action(datum/ai_controller/controller, succeeded, ...)
	. = ..()
	var/datum/group_planning/listed_group = controller.blackboard[BB_GROUP_DATUM]
	if(listed_group)
		listed_group.finish_action(controller)
