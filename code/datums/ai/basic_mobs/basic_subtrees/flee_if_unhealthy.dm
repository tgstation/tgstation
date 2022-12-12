/// The mob will mark itself as trying to run away until its health is above a certain threshold
/// If this mob can't heal itself somehow then it will probably do that forever
/datum/ai_planning_subtree/flee_if_unhealthy

/datum/ai_planning_subtree/flee_if_unhealthy/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()

	var/mob/living/living_pawn = controller.pawn
	var/current_health_percentage = living_pawn.health / living_pawn.maxHealth

	if (controller.blackboard[BB_BASIC_MOB_FLEEING])
		var/stop_above = controller.blackboard[BB_BASIC_MOB_STOP_FLEE_AT_HP_RATIO]
		if (!stop_above)
			return
		if (current_health_percentage < stop_above)
			return
		controller.queue_behavior(/datum/ai_behavior/stop_fleeing, BB_BASIC_MOB_FLEEING)
		return

	var/start_below = controller.blackboard[BB_BASIC_MOB_FLEE_BELOW_HP_RATIO]
	if (!start_below)
		return
	if (current_health_percentage > start_below)
		return
	controller.queue_behavior(/datum/ai_behavior/start_fleeing, BB_BASIC_MOB_FLEEING)
