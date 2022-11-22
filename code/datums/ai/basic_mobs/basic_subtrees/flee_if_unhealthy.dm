/// The mob will mark itself as trying to run away until its health is above a certain threshold
/// If this mob can't heal itself somehow after a certain point it will probably do that forever
/datum/ai_planning_subtree/flee_if_unhealthy

/datum/ai_planning_subtree/flee_if_unhealthy/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	controller.queue_behavior(/datum/ai_behavior/flee_until_healthy, BB_BASIC_MOB_FLEEING, BB_BASIC_MOB_FLEE_BELOW_HP_RATIO, BB_BASIC_MOB_STOP_FLEE_AT_HP_RATIO)

/datum/ai_behavior/flee_until_healthy

/datum/ai_behavior/flee_until_healthy/setup(datum/ai_controller/controller, fleeing_key, flee_below_key, stop_flee_above_key)
	if (!controller.blackboard[stop_flee_above_key])
		return FALSE
	if (!controller.blackboard[flee_below_key])
		return FALSE
	return ..()

/datum/ai_behavior/flee_until_healthy/perform(delta_time, datum/ai_controller/controller, fleeing_key, flee_below_key, stop_flee_above_key)
	controller.behavior_cooldowns[src] = world.time + action_cooldown
	var/mob/living/living_pawn = controller.pawn
	var/current_health_percentage = (living_pawn.health / living_pawn.maxHealth)
	if (controller.blackboard[fleeing_key])
		controller.blackboard[fleeing_key] = current_health_percentage < controller.blackboard[stop_flee_above_key]
		finish_action(controller, succeeded = TRUE)
		return
	controller.blackboard[fleeing_key] = current_health_percentage <= controller.blackboard[flee_below_key]
	finish_action(controller, succeeded = TRUE)
