/**
 * Base behavior for all target-acquisition behaviors.
 *
 * Pipeline: revalidation check → collect_candidates (via target_source) → is_valid_target filter
 * → pick_final_target (via target_priority_strategy) → set blackboard keys.
 *
 * Subtypes:
 *   update_targets             — enemy scanning via hearers + detection field
 *   update_interaction_target  — nearby atom scanning via oview
 */
/datum/bt_node/ai_behavior/acquire_target
	/// Blackboard key to write the found target into.
	var/target_key
	/// Typepath of a /datum/targeting_strategy to use directly, bypassing the blackboard.
	/// Takes priority over targeting_strategy_key. Leave null to read from the blackboard instead.
	var/targeting_strategy
	/// Blackboard key holding the /datum/targeting_strategy typepath for candidate validation.
	/// Only used when targeting_strategy var is null. Defaults to /datum/targeting_strategy/anything if also null.
	var/targeting_strategy_key
	/// Typepath of the /datum/target_source singleton used to gather candidates.
	var/target_source = /datum/target_source/oview
	/// How far to scan for candidates (passed to the target source).
	var/vision_range = 7
	/// How to behave when a target is already set. See TARGET_* defines in ai.dm.
	var/revalidation_mode = TARGET_REVALIDATE

/datum/bt_node/ai_behavior/acquire_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/mob/living/living_mob = controller.pawn
	var/datum/targeting_strategy/targeting_strategy = get_targeting_strategy(controller)

	var/atom/current_target = controller.blackboard[target_key]
	switch(revalidation_mode)
		if(TARGET_KEEP_IF_SET)
			if(!isnull(current_target))
				return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED
		if(TARGET_REVALIDATE)
			if(!isnull(current_target) && targeting_strategy.is_valid_target(living_mob, current_target, vision_range))
				return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	return find_and_set_target(controller, targeting_strategy, vision_range)

/// Resolves the targeting strategy for this controller.
/// Checks the direct targeting_strategy var first, then the blackboard key, then falls back to targeting_strategy/anything.
/datum/bt_node/ai_behavior/acquire_target/proc/get_targeting_strategy(datum/ai_controller/controller)
	if(targeting_strategy)
		return GET_TARGETING_STRATEGY(targeting_strategy)
	if(!targeting_strategy_key)
		return GET_TARGETING_STRATEGY(/datum/targeting_strategy/anything)
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy_key])
	if(!strategy)
		CRASH("No targeting strategy was supplied in the blackboard for [controller.pawn]")
	return strategy

/**
 * Core candidate pipeline: collect → filter → select → set blackboard keys.
 * Called by perform() after the revalidation check passes.
 * Override collect or filter steps by overriding get_targeting_strategy / pick_final_target.
 */
/datum/bt_node/ai_behavior/acquire_target/proc/find_and_set_target(datum/ai_controller/controller, datum/targeting_strategy/targeting_strategy, range)
	var/mob/living/living_mob = controller.pawn
	var/datum/target_source/source = GET_TARGET_SOURCE(target_source)
	if(!source)
		CRASH("No target source found for type [target_source] on [controller.pawn]")

	var/list/candidates = source.collect_candidates(living_mob, controller, range)
	var/list/filtered = list()
	for(var/atom/candidate as anything in candidates)
		if(!targeting_strategy.is_valid_target(living_mob, candidate))
			continue
		filtered += candidate

	if(!length(filtered))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/atom/target = pick_final_target(controller, filtered)

	EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_TARGETING, "[controller.pawn] has selected [target] as a target for blackboard key [target_key]! Behavior: [src]", get_turf(target), "Target: [target]")
	EVLOG_LINES(controller, EVLOG_CATEGORY_AI_TARGETING, "Line to target", get_turf(controller.pawn), get_turf(target))

	if(target != controller.blackboard[target_key])
		controller.set_blackboard_key(target_key, target)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Picks the final target from filtered candidates.
/// Override in subtypes to change selection behavior (e.g. pick nearest, pick most wounded, use priority strategy).
/datum/bt_node/ai_behavior/acquire_target/proc/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	return pick(filtered_targets)

///Finds a nearby target to interact with, used as a baseline for behaviors that need to interact with something nearby.
/datum/bt_node/ai_behavior/acquire_target/update_interaction_target
	target_source = /datum/target_source/oview
	revalidation_mode = TARGET_REVALIDATE
	time_between_perform = 2 SECONDS
