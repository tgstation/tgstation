///Baseline for target picking behaviors
/datum/bt_node/ai_behavior/acquire_target
	/// Blackboard key to write the found target into.
	var/target_key
	/// Either a /datum/targeting_strategy typepath (resolved directly) or a blackboard key string
	var/targeting_strategy = BB_TARGETING_STRATEGY
	/// Typepath of the /datum/target_source type used to gather candidates. turned into the singleton instance when used
	var/target_source = /datum/target_source/oview
	/// How far to scan for candidates (passed to the target source). Can be a key too.
	var/vision_range = 7
	/// How to behave when a target is already set. See TARGET_* defines in ai.dm.
	var/revalidation_mode = TARGET_REVALIDATE
	/// Extended range for retaining an existing target when candidates run dry. 0 = disabled.
	var/target_loss_distance = 12
	/// Optional blackboard key holding a lazylist of atoms to skip while filtering candidates.
	var/ignore_list_key
	/// If TRUE, only candidates the controller can path to are eligible; unreachable ones are reported via note_unreachable_target.
	var/must_be_reachable = FALSE
	/// Pathfinding distance limit used when must_be_reachable is set.
	var/reach_distance = 10
	/// How close the reachability path must get to the target (0 = onto/adjacent). Passed to can_reach_target when must_be_reachable is set.
	var/minimum_distance = 0
	/// Set while an async reachability search is happening (yea, its a path check :( )
	VAR_PRIVATE/is_finding_target = FALSE
	/// Result written by the async search proc before it clears is_finding_target: the found atom, or null for no result.
	VAR_PRIVATE/atom/async_target_result
	/// TRUE once the async search has written its result and is ready to be consumed.
	VAR_PRIVATE/async_search_done = FALSE

/datum/bt_node/ai_behavior/acquire_target/perform(seconds_per_tick, datum/ai_controller/controller)
	// Async reachability search in flight  stay RUNNING until it completes.
	if(is_finding_target)
		return AI_BEHAVIOR_DELAY

	// Async search just finished  consume the result.
	if(async_search_done)
		return AI_BEHAVIOR_DELAY | (isnull(async_target_result) ? AI_BEHAVIOR_FAILED : AI_BEHAVIOR_SUCCEEDED)

	if(!can_search(controller))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/datum/targeting_strategy/strategy = get_targeting_strategy(controller)
	var/atom/current_target = controller.blackboard[target_key]

	if(should_keep_target(controller, strategy, current_target))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	if(!isnum(vision_range)) //If there's a blackboard override, use that
		vision_range = controller.blackboard[vision_range] || vision_range

	if(!must_be_reachable)
		return find_and_set_target(controller, strategy, vision_range)

	// Kick off async reachability search.
	is_finding_target = TRUE
	INVOKE_ASYNC(src, PROC_REF(async_find_and_set_target), controller, strategy, vision_range)
	return AI_BEHAVIOR_DELAY

/datum/bt_node/ai_behavior/acquire_target/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	is_finding_target = FALSE
	async_search_done = FALSE
	async_target_result = null

/// Returns TRUE to abort the search before it starts (e.g. a detection field is already active).
/datum/bt_node/ai_behavior/acquire_target/proc/can_search(datum/ai_controller/controller)
	return TRUE

/// Returns TRUE if the current target is still good and we should skip the search.
/datum/bt_node/ai_behavior/acquire_target/proc/should_keep_target(datum/ai_controller/controller, datum/targeting_strategy/strategy, atom/current_target)
	switch(revalidation_mode)
		if(TARGET_KEEP_IF_SET)
			return !isnull(current_target)
		if(TARGET_REVALIDATE)
			return !isnull(current_target) && strategy.is_valid_target(controller.pawn, current_target, vision_range, controller)
	return FALSE

///Resolves the targeting strategy for this behavior
/datum/bt_node/ai_behavior/acquire_target/proc/get_targeting_strategy(datum/ai_controller/controller)
	if(!targeting_strategy)
		return GET_TARGETING_STRATEGY(/datum/targeting_strategy/anything)
	if(ispath(targeting_strategy))
		return GET_TARGETING_STRATEGY(targeting_strategy)
	var/datum/targeting_strategy/strategy = GET_TARGETING_STRATEGY(controller.blackboard[targeting_strategy])
	if(!strategy)
		CRASH("No targeting strategy was supplied in the blackboard for [controller.pawn]")
	return strategy


///Actual behavior for collecting and filtering targets
/datum/bt_node/ai_behavior/acquire_target/proc/find_and_set_target(datum/ai_controller/controller, datum/targeting_strategy/targeting_strategy, range)
	var/mob/living/living_mob = controller.pawn
	var/datum/target_source/source = GET_TARGET_SOURCE(target_source)
	if(!source)
		CRASH("No target source found for type [target_source] on [controller.pawn]")

	var/atom/current_target = controller.blackboard[target_key]
	var/list/candidates = source.collect_candidates(living_mob, controller, range)

	if(!length(candidates))
		candidates = on_no_candidates(controller, current_target, targeting_strategy, range)
		if(!length(candidates))
			clear_stale_target(controller, current_target)
			return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/list/filtered = filter_candidates(controller, candidates, targeting_strategy, current_target)

	if(!length(filtered))
		on_no_valid_candidates(controller, current_target)
		clear_stale_target(controller, current_target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/atom/target = pick_final_target(controller, filtered)

	if(isnull(target))
		on_no_valid_candidates(controller, current_target)
		clear_stale_target(controller, current_target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	EVLOG_MAPTEXT(controller, EVLOG_CATEGORY_AI_TARGETING, "[controller.pawn] has selected [target] as a target for blackboard key [target_key]! Behavior: [src]", get_turf(target), "Target: [target]")
	EVLOG_LINES(controller, EVLOG_CATEGORY_AI_TARGETING, "Line to target", get_turf(controller.pawn), get_turf(target))

	if(target != current_target)
		controller.set_blackboard_key(target_key, target)

	on_target_found(controller, target, targeting_strategy)

	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

/// Clears the target key when revalidating and the search turned up nothing, so a stale target doesn't linger.
/datum/bt_node/ai_behavior/acquire_target/proc/clear_stale_target(datum/ai_controller/controller, atom/current_target)
	if(revalidation_mode != TARGET_REVALIDATE || isnull(current_target))
		return
	controller.clear_blackboard_key(target_key)

///Fallback for no targets found.
/datum/bt_node/ai_behavior/acquire_target/proc/on_no_candidates(datum/ai_controller/controller, atom/current_target, datum/targeting_strategy/strategy, range)
	if(!target_loss_distance || !current_target)
		return list()
	if(strategy.can_keep_target(controller.pawn, current_target, target_loss_distance))
		return list(current_target)
	return list()

/// Filters the candidate list to valid targets. Override to add priority filtering or other per-candidate criteria.
/datum/bt_node/ai_behavior/acquire_target/proc/filter_candidates(datum/ai_controller/controller, list/candidates, datum/targeting_strategy/strategy, atom/current_target)
	var/mob/living/pawn = controller.pawn
	var/list/ignore_list = ignore_list_key ? controller.blackboard[ignore_list_key] : null
	var/list/filtered = list()
	for(var/atom/candidate as anything in candidates)
		if(LAZYACCESS(ignore_list, candidate))
			continue
		if(!strategy.is_valid_target(pawn, candidate, vision_range, controller))
			continue
		filtered += candidate
	return filtered

/// Called when filter_candidates produces nothing. Override to trigger side effects (e.g. spawning a detection field).
/datum/bt_node/ai_behavior/acquire_target/proc/on_no_valid_candidates(datum/ai_controller/controller, atom/current_target)
	return

/// Called after a target is selected and written to the blackboard. Override for post-selection side effects.
/datum/bt_node/ai_behavior/acquire_target/proc/on_target_found(datum/ai_controller/controller, atom/target, datum/targeting_strategy/strategy)
	return

/// Picks the final target from filtered candidates. Only valid for the non-reachable path; the reachable path goes async.
/datum/bt_node/ai_behavior/acquire_target/proc/pick_final_target(datum/ai_controller/controller, list/filtered_targets)
	return pick(filtered_targets)

/// Async proc: walks filtered candidates checking reachability (may sleep), then writes the result and sets async_search_done.
/datum/bt_node/ai_behavior/acquire_target/proc/async_find_and_set_target(datum/ai_controller/controller, datum/targeting_strategy/strategy, range)
	var/mob/living/living_mob = controller.pawn
	var/datum/target_source/source = GET_TARGET_SOURCE(target_source)
	var/atom/current_target = controller.blackboard[target_key]
	var/list/candidates = source.collect_candidates(living_mob, controller, range)
	if(!length(candidates))
		candidates = on_no_candidates(controller, current_target, strategy, range)
	var/list/filtered = filter_candidates(controller, candidates, strategy, current_target)
	var/atom/target
	for(var/atom/candidate as anything in filtered)
		// get_path_to may sleep here  check abort flag after it returns.
		if(controller.can_reach_target(candidate, reach_distance, minimum_distance))
			target = candidate
			break
		controller.note_unreachable_target(candidate)
	// If finish_action fired while we were sleeping, bail without touching anything.
	if(!is_finding_target || QDELETED(controller) || QDELETED(controller.pawn))
		return
	if(!isnull(target))
		if(target != controller.blackboard[target_key])
			controller.set_blackboard_key(target_key, target)
		on_target_found(controller, target, strategy)
	else
		on_no_valid_candidates(controller, current_target)
		clear_stale_target(controller, current_target)
	async_target_result = target
	async_search_done = TRUE
	is_finding_target = FALSE

///Finds a nearby target to interact with, used as a baseline for behaviors that need to interact with something nearby.
/datum/bt_node/ai_behavior/acquire_target/update_interaction_target
	target_source = /datum/target_source/oview
	revalidation_mode = TARGET_REVALIDATE
	time_between_perform = 2 SECONDS
