/// Triggers a mob ability stored in a blackboard key. Returns INSTANT SUCCESS if triggered, INSTANT FAILURE if unavailable or trigger fails.
/datum/bt_node/ai_behavior/use_mob_ability
	var/ability_key = BB_GENERIC_ACTION
	/// Set while Trigger() is happening
	var/is_triggering = FALSE
	/// TRUE once the async Trigger() has written its result.
	var/async_trigger_done = FALSE
	/// Whether Trigger() returned a truthy value.
	var/async_trigger_succeeded = FALSE

/datum/bt_node/ai_behavior/use_mob_ability/perform(seconds_per_tick, datum/ai_controller/controller)
	if(is_triggering)
		return AI_BEHAVIOR_DELAY

	if(async_trigger_done)
		return async_trigger_succeeded ? (AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED) : (AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED)

	var/datum/action/using_action = controller.blackboard[ability_key]
	if(QDELETED(using_action) || !using_action.IsAvailable())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	is_triggering = TRUE
	INVOKE_ASYNC(src, PROC_REF(async_trigger), using_action)
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/use_mob_ability/proc/async_trigger(datum/action/using_action)
	var/result = using_action.Trigger()
	if(!is_triggering)
		return
	async_trigger_succeeded = !!result
	async_trigger_done = TRUE
	is_triggering = FALSE

/datum/bt_node/ai_behavior/use_mob_ability/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	is_triggering = FALSE
	async_trigger_done = FALSE
	async_trigger_succeeded = FALSE

/// Triggers a shapeshift ability, picking a random shape if none has been selected yet (AI can't use context wheels).
/datum/bt_node/ai_behavior/use_mob_ability/shapeshift
	ability_key = BB_SHAPESHIFT_ACTION

/datum/bt_node/ai_behavior/use_mob_ability/shapeshift/perform(seconds_per_tick, datum/ai_controller/controller)
	var/datum/action/cooldown/spell/shapeshift/using_action = controller.blackboard[ability_key]
	if(QDELETED(using_action) || !using_action.IsAvailable())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(isnull(using_action.shapeshift_type))
		using_action.shapeshift_type = pick(using_action.possible_shapes)
	return ..()
