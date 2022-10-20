/datum/ai_controller/basic_controller/hugglebipper
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic/hugglebipper(),
	)

	ai_movement = /datum/ai_movement/basic_avoidance

	planning_subtrees = list(
		/datum/ai_planning_subtree/hugglebipper_dropoff,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/hugglebipper_stalking,
	)

/datum/ai_planning_subtree/hugglebipper_dropoff

/datum/ai_planning_subtree/hugglebipper_dropoff/SelectBehaviors(datum/ai_controller/controller, delta_time)

	var/datum/weakref/weak_dropoff = controller.blackboard[BB_HUGGLEBIPPER_DROPOFF]
	var/turf/dropoff = weak_dropoff?.resolve()
	if(!dropoff)
		return //nowhere to run to so just go to stalking

	controller.queue_behavior(/datum/ai_behavior/dropoff_buckled_mobs, BB_HUGGLEBIPPER_DROPOFF)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/hugglebipper_stalking

/datum/ai_planning_subtree/hugglebipper_stalking/SelectBehaviors(datum/ai_controller/controller, delta_time)

	var/datum/weakref/weak_target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	var/mob/living/target = weak_target?.resolve()

	if(controller.blackboard[BB_HUGGLEBIPPER_STOP_STALKING])
		//we need to stop stalking and act!
		controller.queue_behavior(
			/datum/ai_behavior/basic_melee_attack/hugglebipper,
			BB_BASIC_MOB_CURRENT_TARGET,
			BB_TARGETTING_DATUM,
			BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION
		)
		return SUBTREE_RETURN_FINISH_PLANNING

	if(!target || QDELETED(target))
		return SUBTREE_RETURN_FINISH_PLANNING //also stop because if we have no target we have nothing to do after stalking

	controller.queue_behavior(/datum/ai_behavior/hugglebipper_stalking, BB_BASIC_MOB_CURRENT_TARGET)

	return SUBTREE_RETURN_FINISH_PLANNING //focus on stalking

/datum/targetting_datum/basic/hugglebipper
	//metal, but in reality it will only poke the body once
	beat_them_to = DEAD

/datum/targetting_datum/basic/hugglebipper/new_target(datum/ai_controller/controller)
	controller.blackboard[BB_HUGGLEBIPPER_STOP_STALKING] = FALSE
