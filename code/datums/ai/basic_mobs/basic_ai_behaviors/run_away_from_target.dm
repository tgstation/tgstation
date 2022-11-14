/// Move to a position further away from your current target
/datum/ai_behavior/run_away_from_target
	required_distance = 0
	action_cooldown = 0
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/run_away_from_target/setup(datum/ai_controller/controller, target_key, hiding_location_key)
	if (!take_step_away(controller, target_key, hiding_location_key))
		return FALSE
	return ..()

/datum/ai_behavior/run_away_from_target/perform(delta_time, datum/ai_controller/controller, target_key, hiding_location_key)
	. = ..()
	if (!continue_fleeing(controller))
		finish_action(controller, FALSE)
		return
	if (!take_step_away(controller, target_key, hiding_location_key))
		finish_action(controller, FALSE)

/datum/ai_behavior/run_away_from_target/proc/continue_fleeing(datum/ai_controller/controller)
	return TRUE

/datum/ai_behavior/run_away_from_target/proc/take_step_away(datum/ai_controller/controller, target_key, hiding_location_key)
	var/datum/weakref/weak_target = controller.blackboard[hiding_location_key] || controller.blackboard[target_key]
	var/atom/target = weak_target?.resolve()
	if(!target)
		return FALSE
	var/atom/flee_target = get_step_away(controller.pawn, get_turf(target))
	if (!flee_target)
		return FALSE
	controller.current_movement_target = flee_target
	return TRUE

/// Stops running away if you get above a certain health ratio
/datum/ai_behavior/run_away_from_target/while_unhealthy
	var/health_ratio_key

/datum/ai_behavior/run_away_from_target/while_unhealthy/setup(datum/ai_controller/controller, target_key, hiding_location_key, health_ratio_key)
	. = ..()
	if (!.)
		return
	src.health_ratio_key = health_ratio_key

/datum/ai_behavior/run_away_from_target/while_unhealthy/continue_fleeing(datum/ai_controller/controller)
	var/mob/living/living_pawn = controller.pawn
	var/current_health_ratio = (living_pawn.health / living_pawn.maxHealth)
	return current_health_ratio < controller.blackboard[health_ratio_key]
