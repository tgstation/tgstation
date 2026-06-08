/// Triggers a mob ability stored in a blackboard key. Returns INSTANT SUCCESS if triggered, INSTANT FAILURE if unavailable or trigger fails.
/datum/bt_node/ai_behavior/use_mob_ability

/datum/bt_node/ai_behavior/use_mob_ability/perform(seconds_per_tick, datum/ai_controller/controller, ability_key = BB_GENERIC_ACTION)
	var/datum/action/using_action = controller.blackboard[ability_key]
	if(QDELETED(using_action) || !using_action.IsAvailable())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(using_action.Trigger())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED

/// Triggers a shapeshift ability, picking a random shape if none has been selected yet (AI can't use context wheels).
/datum/bt_node/ai_behavior/use_mob_ability/shapeshift

/datum/bt_node/ai_behavior/use_mob_ability/shapeshift/perform(seconds_per_tick, datum/ai_controller/controller, ability_key = BB_SHAPESHIFT_ACTION)
	var/datum/action/cooldown/spell/shapeshift/using_action = controller.blackboard[ability_key]
	if(QDELETED(using_action) || !using_action.IsAvailable())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(isnull(using_action.shapeshift_type))
		using_action.shapeshift_type = pick(using_action.possible_shapes)
	return ..(seconds_per_tick, controller, ability_key)
