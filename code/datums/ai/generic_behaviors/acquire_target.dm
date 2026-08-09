///Baseline for target picking behaviors
/datum/bt_node/ai_behavior/acquire_target
	/// Blackboard key to write the found target into.
	var/target_key
	/// Either a /datum/targeting_strategy typepath (resolved directly) or a blackboard key string
	var/targeting_strategy = BB_TARGETING_STRATEGY
	/// Optional /datum/target_priority_strategy typepath or blackboard key string. Null means unranked selection.
	var/target_priority_strategy
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
	/// Strategy/range snapshot from the perform() that kicked off the current async search.
	VAR_PRIVATE/datum/targeting_strategy/search_strategy
	/// Optional selection strategy snapshot from the perform() that kicked off the current async search.
	VAR_PRIVATE/datum/target_priority_strategy/search_priority_strategy
	/// Range snapshot from the perform() that kicked off the current async search.
	VAR_PRIVATE/search_range

/datum/bt_node/ai_behavior/acquire_target/perform(seconds_per_tick, datum/ai_controller/controller)
	var/async_flags = handle_async()
	if(async_flags)
		return async_flags

	if(!can_search(controller))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/datum/targeting_strategy/strategy = get_targeting_strategy(controller)
	var/datum/target_priority_strategy/priority_strategy = get_target_priority_strategy(controller)
	var/resolved_vision_range = get_vision_range(controller)
	var/atom/current_target = controller.blackboard[target_key]

	if(should_keep_target(controller, strategy, priority_strategy, current_target, resolved_vision_range))
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED

	if(!must_be_reachable)
		return find_and_set_target(controller, strategy, priority_strategy, resolved_vision_range)

	// Kick off async reachability search.
	search_strategy = strategy
	search_priority_strategy = priority_strategy
	search_range = resolved_vision_range
	return start_async()

/datum/bt_node/ai_behavior/acquire_target/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	search_strategy = null
	search_priority_strategy = null
	search_range = null

/// Returns TRUE to abort the search before it starts (e.g. a detection field is already active).
/datum/bt_node/ai_behavior/acquire_target/proc/can_search(datum/ai_controller/controller)
	return TRUE

/// Returns TRUE if the current target is still good and we should skip the search.
/datum/bt_node/ai_behavior/acquire_target/proc/should_keep_target(
	datum/ai_controller/controller,
	datum/targeting_strategy/strategy,
	datum/target_priority_strategy/priority_strategy,
	atom/current_target,
	resolved_vision_range,
)
	switch(revalidation_mode)
		if(TARGET_KEEP_IF_SET)
			return !isnull(current_target)
		if(TARGET_REVALIDATE)
			return !isnull(current_target) && strategy.is_valid_target(controller.pawn, current_target, resolved_vision_range, controller)
		if(TARGET_RESELECT_WITH_SELECTION)
			return !isnull(current_target) \
				&& isnull(priority_strategy) \
				&& strategy.is_valid_target(controller.pawn, current_target, resolved_vision_range, controller)
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

/// Resolves the optional target priority strategy for this behavior.
/datum/bt_node/ai_behavior/acquire_target/proc/get_target_priority_strategy(datum/ai_controller/controller)
	if(!target_priority_strategy)
		return null
	if(ispath(target_priority_strategy))
		return GET_TARGET_PRIORITY_STRATEGY(target_priority_strategy)
	return GET_TARGET_PRIORITY_STRATEGY(controller.blackboard[target_priority_strategy])

/// Resolves a numeric vision range without mutating the behavior's configured value.
/datum/bt_node/ai_behavior/acquire_target/proc/get_vision_range(datum/ai_controller/controller)
	if(isnum(vision_range))
		return vision_range
	var/resolved_range = controller.blackboard[vision_range]
	if(!isnum(resolved_range))
		CRASH("No numeric vision range was supplied in blackboard key [vision_range] for [controller.pawn]")
	return resolved_range

///Actual behavior for collecting and filtering targets
/datum/bt_node/ai_behavior/acquire_target/proc/find_and_set_target(datum/ai_controller/controller, datum/targeting_strategy/targeting_strategy, datum/target_priority_strategy/priority_strategy, range)
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

	candidates = include_current_target(controller, candidates, targeting_strategy, priority_strategy, current_target, range)
	var/list/filtered = filter_candidates(controller, candidates, targeting_strategy, priority_strategy, current_target, range)

	if(!length(filtered))
		on_no_valid_candidates(controller, current_target)
		clear_stale_target(controller, current_target)
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	var/atom/target = pick_final_target(controller, filtered, priority_strategy, current_target)

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
	if(revalidation_mode == TARGET_KEEP_IF_SET || isnull(current_target))
		return
	controller.clear_blackboard_key(target_key)

///Fallback for no targets found.
/datum/bt_node/ai_behavior/acquire_target/proc/on_no_candidates(datum/ai_controller/controller, atom/current_target, datum/targeting_strategy/strategy, range)
	if(!target_loss_distance || !current_target)
		return list()
	if(strategy.can_keep_target(controller.pawn, current_target, target_loss_distance, controller))
		return list(current_target)
	return list()

/// Includes a retainable current target in priority-aware reselection even if the target source omitted it.
/datum/bt_node/ai_behavior/acquire_target/proc/include_current_target(datum/ai_controller/controller,list/candidates, datum/targeting_strategy/strategy, datum/target_priority_strategy/priority_strategy, atom/current_target, range)
	if(isnull(priority_strategy) || isnull(current_target) || (current_target in candidates))
		return candidates
	if(!strategy.can_keep_target(controller.pawn, current_target, target_loss_distance || range, controller))
		return candidates
	var/list/candidates_with_current = candidates.Copy()
	candidates_with_current += current_target
	return candidates_with_current

/// Filters the candidate list to valid targets and excludes candidates ranked below a retainable current target.
/datum/bt_node/ai_behavior/acquire_target/proc/filter_candidates(datum/ai_controller/controller, list/candidates, datum/targeting_strategy/strategy, datum/target_priority_strategy/priority_strategy, atom/current_target, range)
	var/mob/living/pawn = controller.pawn
	var/list/ignore_list = ignore_list_key ? controller.blackboard[ignore_list_key] : null
	var/current_priority
	if(priority_strategy && current_target && !LAZYACCESS(ignore_list, current_target))
		if(strategy.can_keep_target(pawn, current_target, target_loss_distance || range, controller))
			current_priority = priority_strategy.get_target_priority(controller, current_target)
	var/list/filtered = list()
	for(var/atom/candidate as anything in candidates)
		if(LAZYACCESS(ignore_list, candidate))
			continue
		var/is_retained_current = candidate == current_target \
			&& target_loss_distance \
			&& strategy.can_keep_target(pawn, candidate, target_loss_distance, controller)
		if(!is_retained_current && !strategy.is_valid_target(pawn, candidate, range, controller))
			continue
		if(!isnull(current_priority) && priority_strategy.get_target_priority(controller, candidate) < current_priority)
			continue
		filtered += candidate
	return filtered

/// Called when filter_candidates produces nothing. Override to trigger side effects (e.g. spawning a detection field).
/datum/bt_node/ai_behavior/acquire_target/proc/on_no_valid_candidates(datum/ai_controller/controller, atom/current_target)
	return

/// Called after a target is selected and written to the blackboard. Override for post-selection side effects.
/datum/bt_node/ai_behavior/acquire_target/proc/on_target_found(datum/ai_controller/controller, atom/target, datum/targeting_strategy/strategy)
	return

/// Picks the final target and keeps the current target on policy-defined ties.
/datum/bt_node/ai_behavior/acquire_target/proc/pick_final_target(datum/ai_controller/controller, list/filtered_targets, datum/target_priority_strategy/priority_strategy, atom/current_target)
	var/atom/selected_target = priority_strategy \
		? priority_strategy.select_target(controller, filtered_targets) \
		: pick(filtered_targets)
	if(isnull(priority_strategy) || isnull(current_target) || selected_target == current_target)
		return selected_target
	if(!(current_target in filtered_targets) || priority_strategy.can_replace_target(controller, current_target, selected_target))
		return selected_target
	return current_target

/// perform_async(): selects candidates in policy order, checking reachability until one succeeds.
/datum/bt_node/ai_behavior/acquire_target/perform_async(datum/ai_controller/controller)
	var/datum/targeting_strategy/strategy = search_strategy
	var/datum/target_priority_strategy/priority_strategy = search_priority_strategy
	var/range = search_range
	var/mob/living/living_mob = controller.pawn
	var/datum/target_source/source = GET_TARGET_SOURCE(target_source)
	var/atom/current_target = controller.blackboard[target_key]
	var/list/candidates = source.collect_candidates(living_mob, controller, range)
	if(!length(candidates))
		candidates = on_no_candidates(controller, current_target, strategy, range)
	candidates = include_current_target(controller, candidates, strategy, priority_strategy, current_target, range)
	var/list/filtered = filter_candidates(controller, candidates, strategy, priority_strategy, current_target, range)
	var/atom/target
	while(length(filtered))
		var/atom/candidate = pick_final_target(controller, filtered, priority_strategy, current_target)
		if(isnull(candidate))
			break
		filtered -= candidate
		// get_path_to may sleep here  check abort flag after it returns.
		if(controller.can_reach_target(candidate, reach_distance, minimum_distance))
			target = candidate
			break
		if(!async_still_valid())
			return
		controller.note_unreachable_target(candidate)
	// If finish_action fired while we were sleeping, bail without touching anything.
	if(!async_still_valid())
		return
	if(!isnull(target))
		if(target != controller.blackboard[target_key])
			controller.set_blackboard_key(target_key, target)
		on_target_found(controller, target, strategy)
	else
		on_no_valid_candidates(controller, current_target)
		clear_stale_target(controller, current_target)
	finish_async(isnull(target) ? AI_BEHAVIOR_FAILED : AI_BEHAVIOR_SUCCEEDED)

///Finds a nearby target to interact with, used as a baseline for behaviors that need to interact with something nearby.
/datum/bt_node/ai_behavior/acquire_target/update_interaction_target
	target_source = /datum/target_source/oview
	revalidation_mode = TARGET_REVALIDATE
	time_between_perform = 2 SECONDS
