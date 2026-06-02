// DEPRECATED — port to /datum/bt_node/ai_behavior/targeted_mob_ability
/datum/ai_behavior/targeted_mob_ability
	parent_type = /datum/bt_node/ai_behavior/targeted_mob_ability

/datum/ai_behavior/targeted_mob_ability/and_plan_execute

/datum/ai_behavior/targeted_mob_ability/and_clear_target

/// Minimum-range variant: does not fire when already adjacent to target (set by mob files)
/datum/ai_behavior/targeted_mob_ability/min_range

/datum/ai_behavior/targeted_mob_ability/min_range/short

/// Tries to use a specified ability on the current target
/datum/bt_node/ai_behavior/targeted_mob_ability
	/// Maximum distance at which the ability can fire; override in subclasses.
	var/required_distance = 0

/// Variant for abilities that require adjacency (distance ≤ 1).
/datum/bt_node/ai_behavior/targeted_mob_ability/melee
	required_distance = 1

/datum/bt_node/ai_behavior/targeted_mob_ability/perform(seconds_per_tick, datum/ai_controller/controller, ability_key, target_key)
	var/datum/action/cooldown/ability = controller.blackboard[ability_key]
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(ability) || QDELETED(target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(required_distance && get_dist(controller.pawn, target) > required_distance)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(!ability.IsAvailable())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	var/mob/pawn = controller.pawn
	pawn.face_atom(target)
	var/result = ability.Trigger(target = target)
	if(result)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/datum/bt_node/ai_behavior/targeted_mob_ability/and_plan_execute

/datum/bt_node/ai_behavior/targeted_mob_ability/and_plan_execute/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	controller.set_blackboard_key(BB_BASIC_MOB_EXECUTION_TARGET, controller.blackboard[target_key])
	return ..()

/datum/bt_node/ai_behavior/targeted_mob_ability/and_clear_target

/datum/bt_node/ai_behavior/targeted_mob_ability/and_clear_target/finish_action(datum/ai_controller/controller, succeeded, ability_key, target_key)
	. = ..()
	controller.clear_blackboard_key(target_key)


