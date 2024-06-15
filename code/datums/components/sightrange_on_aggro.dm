
/**
 * Changes aggro range of the attached mob while it has a target, stores old value for reset
 */
/datum/component/sightrange_on_aggro
	/// Blackboard key to search for a target
	var/target_key
	/// aggro range key
	var/aggro_key
	/// aggro range when aggroed
	var/aggro_range
	/// old aggro range
	var/old_range

/datum/component/sightrange_on_aggro/Initialize(target_key = BB_BASIC_MOB_CURRENT_TARGET, aggro_key = BB_AGGRO_RANGE, aggro_range = /datum/ai_behavior/find_potential_targets::vision_range)
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.target_key = target_key
	src.aggro_key = aggro_key
	src.aggro_range = aggro_range

/datum/component/sightrange_on_aggro/RegisterWithParent()
	RegisterSignal(parent, COMSIG_AI_BLACKBOARD_KEY_SET(target_key), PROC_REF(on_set_target))
	RegisterSignal(parent, COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key), PROC_REF(on_clear_target))

/datum/component/sightrange_on_aggro/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_AI_BLACKBOARD_KEY_SET(target_key), COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_key)))

/datum/component/sightrange_on_aggro/proc/on_set_target(mob/living/source)
	SIGNAL_HANDLER

	if (isnull(source.ai_controller.blackboard[target_key]))
		return
	old_range = source.ai_controller.blackboard[aggro_key]
	source.ai_controller.set_blackboard_key(aggro_key, aggro_range)

/datum/component/sightrange_on_aggro/Destroy()
	var/mob/living/living = parent
	if (!isnull(living.ai_controller?.blackboard[target_key]))
		living.ai_controller.set_blackboard_key(aggro_key, old_range)
	return ..()

/datum/component/sightrange_on_aggro/proc/on_clear_target(atom/source)
	SIGNAL_HANDLER
	source.ai_controller.set_blackboard_key(aggro_key, old_range)
