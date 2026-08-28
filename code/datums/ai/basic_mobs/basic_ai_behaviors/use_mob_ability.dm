/// Triggers a mob ability stored in a blackboard key. Returns INSTANT SUCCESS if triggered, INSTANT FAILURE if unavailable or trigger fails.
/datum/bt_node/ai_behavior/use_mob_ability
	var/ability_key = BB_GENERIC_ACTION

/datum/bt_node/ai_behavior/use_mob_ability/perform(seconds_per_tick, datum/ai_controller/controller)
	var/async_flags = handle_async()
	if(async_flags)
		return async_flags

	var/datum/action/using_action = get_valid_ability(controller)
	if(QDELETED(using_action))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	return start_async()

/// Returns the action to trigger, or null if it isn't available. Override to prep the action before it fires.
/datum/bt_node/ai_behavior/use_mob_ability/proc/get_valid_ability(datum/ai_controller/controller)
	var/datum/action/using_action = controller.blackboard[ability_key]
	if(QDELETED(using_action) || !using_action.IsAvailable())
		return null
	return using_action

/datum/bt_node/ai_behavior/use_mob_ability/perform_async(datum/ai_controller/controller)
	var/datum/action/using_action = controller.blackboard[ability_key]
	var/result = using_action.Trigger()
	if(!async_still_valid())
		return
	finish_async(result ? AI_BEHAVIOR_SUCCEEDED : AI_BEHAVIOR_FAILED)

/// Triggers a shapeshift ability, picking a random shape if none has been selected yet (AI can't use context wheels).
/datum/bt_node/ai_behavior/use_mob_ability/shapeshift
	ability_key = BB_SHAPESHIFT_ACTION

/datum/bt_node/ai_behavior/use_mob_ability/shapeshift/get_valid_ability(datum/ai_controller/controller)
	var/datum/action/cooldown/spell/shapeshift/using_action = ..()
	if(QDELETED(using_action))
		return null
	if(isnull(using_action.shapeshift_type))
		using_action.shapeshift_type = pick(using_action.possible_shapes)
	return using_action
