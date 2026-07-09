/// Tries to use a specified ability on the current target
/datum/bt_node/ai_behavior/targeted_mob_ability
	var/ability_key = BB_GENERIC_ACTION
	var/target_key
	/// Maximum distance at which the ability can fire (inclusive cuz this is tg :) )
	var/maximum_distance = 0
	///Does this require adjacency?
	var/require_adjacency = FALSE

/datum/bt_node/ai_behavior/targeted_mob_ability/perform(seconds_per_tick, datum/ai_controller/controller)
	var/async_flags = handle_async()
	if(async_flags)
		return async_flags

	var/datum/action/cooldown/ability = controller.blackboard[ability_key]
	var/mob/living/target = controller.blackboard[target_key]
	if(QDELETED(ability) || QDELETED(target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(maximum_distance && get_dist(controller.pawn, target) > maximum_distance)
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(require_adjacency && !controller.pawn.Adjacent(target))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(!ability.IsAvailable())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

	var/mob/pawn_mob = controller.pawn
	pawn_mob.face_atom(target)
	return start_async()

/datum/bt_node/ai_behavior/targeted_mob_ability/perform_async(datum/ai_controller/controller)
	var/datum/action/cooldown/ability = controller.blackboard[ability_key]
	var/atom/target = controller.blackboard[target_key]
	var/result = ability.Trigger(target = target)
	if(!async_still_valid())
		return
	finish_async(result ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)

/// Variant for abilities that require adjacency (distance ≤ 1).
/datum/bt_node/ai_behavior/targeted_mob_ability/melee
	require_adjacency = TRUE


/datum/bt_node/ai_behavior/targeted_mob_ability/and_plan_execute

/datum/bt_node/ai_behavior/targeted_mob_ability/and_plan_execute/finish_action(datum/ai_controller/controller, succeeded)
	controller.set_blackboard_key(BB_BASIC_MOB_EXECUTION_TARGET, controller.blackboard[target_key])
	return ..()

/datum/bt_node/ai_behavior/targeted_mob_ability/and_clear_target

/datum/bt_node/ai_behavior/targeted_mob_ability/and_clear_target/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	controller.clear_blackboard_key(target_key)


