/datum/ai_planning_subtree/find_and_hunt_target
	var/list/hunt_targets = list(/obj/effect/decal/cleanable/ants)

/datum/ai_planning_subtree/find_and_hunt_target/New()
	. = ..()
	hunt_targets = typecacheof(hunt_targets)

/datum/ai_planning_subtree/find_and_hunt_target/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	if(controller.blackboard[BB_HUNTING_COOLDOWN] >= world.time)
		return
	if(!controller.blackboard[BB_CURRENT_HUNTING_TARGET])
		controller.AddBehavior(/datum/ai_behavior/find_hunt_target, BB_CURRENT_HUNTING_TARGET, hunt_targets)
	else
		controller.AddBehavior(/datum/ai_behavior/hunt_target, BB_CURRENT_HUNTING_TARGET, BB_HUNTING_COOLDOWN)
		return SUBTREE_RETURN_FINISH_PLANNING //If we're hunting we're too busy for anything else
