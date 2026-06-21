/// Tries to use a specified ability on the current target
/datum/bt_node/ai_behavior/targeted_mob_ability
	var/ability_key = BB_GENERIC_ACTION
	var/target_key
	/// Maximum distance at which the ability can fire (inclusive cuz this is tg :) )
	var/maximum_distance = 0
	///Does this require adjacency?
	var/require_adjacency = FALSE
	/// Set while Trigger() is blastin
	VAR_PRIVATE/is_triggering = FALSE
	/// TRUE once the async Trigger() has written its result.
	VAR_PRIVATE/async_trigger_done = FALSE
	/// Whether Trigger() returned a truthy value.
	VAR_PRIVATE/async_trigger_succeeded = FALSE

/datum/bt_node/ai_behavior/targeted_mob_ability/perform(seconds_per_tick, datum/ai_controller/controller)
	if(is_triggering)
		return AI_BEHAVIOR_DELAY

	if(async_trigger_done)
		return async_trigger_succeeded ? (AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED) : (AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED)

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
	is_triggering = TRUE
	INVOKE_ASYNC(src, PROC_REF(async_trigger), ability, target)
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/targeted_mob_ability/proc/async_trigger(datum/action/cooldown/ability, atom/target)
	var/result = ability.Trigger(target = target)
	if(!is_triggering)
		return
	async_trigger_succeeded = !!result
	async_trigger_done = TRUE
	is_triggering = FALSE

/datum/bt_node/ai_behavior/targeted_mob_ability/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	is_triggering = FALSE
	async_trigger_done = FALSE
	async_trigger_succeeded = FALSE

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


