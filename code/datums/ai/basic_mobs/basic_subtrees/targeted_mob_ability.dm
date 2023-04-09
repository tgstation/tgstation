/// Attempts to use a mob ability on a target
/datum/ai_planning_subtree/targeted_mob_ability
	/// Blackboard key for the ability
	var/ability_key
	/// Blackboard key for where the target ref is stored
	var/target_key = BB_BASIC_MOB_CURRENT_TARGET
	/// Behaviour to perform using ability
	var/use_ability_behaviour = /datum/ai_behavior/targeted_mob_ability

/datum/ai_planning_subtree/targeted_mob_ability/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if (!ability_key)
		CRASH("You forgot to tell this mob where to find its ability")

	var/datum/weakref/weak_target = controller.blackboard[target_key]
	var/mob/living/target = weak_target?.resolve()
	if (QDELETED(target))
		return

	var/datum/weakref/weak_ability = controller.blackboard[ability_key]
	var/datum/action/cooldown/using_action = weak_ability?.resolve()
	if (!using_action || !using_action.IsAvailable())
		return

	controller.queue_behavior(use_ability_behaviour, ability_key, target_key)
	return SUBTREE_RETURN_FINISH_PLANNING
