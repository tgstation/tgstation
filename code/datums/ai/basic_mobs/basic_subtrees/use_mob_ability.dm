/**
 * Simple behaviours which simply try to use an ability whenever it is available.
 * For something which wants a target try `targeted_mob_ability`.
 */
/datum/ai_planning_subtree/use_mob_ability
	/// Blackboard key for the ability
	var/ability_key = BB_GENERIC_ACTION
	/// Behaviour to perform using ability
	var/use_ability_behaviour = /datum/ai_behavior/use_mob_ability
	/// If true we terminate planning after trying to use the ability.
	var/finish_planning = FALSE

/datum/ai_planning_subtree/use_mob_ability/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if (!ability_key)
		CRASH("You forgot to tell this mob where to find its ability")

	var/datum/action/using_action = controller.blackboard[ability_key]
	if (!using_action?.IsAvailable())
		return

	controller.queue_behavior(use_ability_behaviour, ability_key)
	if (finish_planning)
		return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_behavior/use_mob_ability

/datum/ai_behavior/use_mob_ability/perform(seconds_per_tick, datum/ai_controller/controller, ability_key)
	var/datum/action/using_action = controller.blackboard[ability_key]
	if (QDELETED(using_action))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
	if(using_action.Trigger())
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_FAILED
