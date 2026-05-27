/**
 * Base composite node. Holds an ordered list of child bt_node singletons.
 *
 * Set children_typepaths on your subtype definition to declare children.
 * SSai_controllers/proc/setup_bt_nodes() resolves them to singleton refs before first use,
 * looking up from GLOB.bt_nodes, GLOB.ai_subtrees, and SSai_behaviors.ai_behaviors.
 */
/datum/bt_node/composite
	/// Typepaths of child nodes declared on the type. Resolved to singleton refs at subsystem init.
	var/list/children_typepaths = null
	/// Resolved singleton child references. Populated by setup_bt_nodes(). Do not set directly.
	var/list/children = null

/datum/bt_node/composite/assign_execution_indices(controller_type, counter, list/exec_cache, list/last_cache)
	exec_cache[src] = counter
	counter++
	for(var/datum/bt_node/c in children)
		counter = c.assign_execution_indices(controller_type, counter, exec_cache, last_cache)
	last_cache[src] = counter - 1
	return counter

/**
 * Sequence node: ticks children in order.
 * Returns BT_FAILURE on first child failure.
 * Returns BT_RUNNING on first child returning BT_RUNNING (stops further evaluation).
 * Returns BT_SUCCESS only if all children succeed.
 *
 * Memory: resumes from the last RUNNING child index rather than restarting from child 1.
 * The observer/interrupt system resets this via CancelActions() when conditions change.
 */
/datum/bt_node/composite/sequence
	/// Per-controller index of the child that last returned BT_RUNNING. 1-based. Keyed by controller ref.
	var/alist/running_child_index = alist()

/datum/bt_node/composite/sequence/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick(controller))
		return tick_results[controller] || BT_RUNNING

	var/result = BT_SUCCESS
	var/start = running_child_index[controller] || 1
	for(var/i in start to length(children))
		var/datum/bt_node/child = children[i]
		var/child_result = child.tick(controller, seconds_per_tick)
		if(child_result != BT_SUCCESS)
			result = child_result
			if(child_result == BT_RUNNING)
				running_child_index[controller] = i
			else
				running_child_index -= controller
			if(tick_rate)
				tick_cooldowns[controller] = world.time
				tick_results[controller] = result
			return result

	running_child_index -= controller
	if(tick_rate)
		tick_cooldowns[controller] = world.time
		tick_results[controller] = result
	return result

/datum/bt_node/composite/sequence/reset_tick_state(datum/ai_controller/controller)
	. = ..()
	running_child_index -= controller

/**
 * Selector node: ticks children in order.
 * Returns the first non-BT_FAILURE result (BT_SUCCESS or BT_RUNNING), stopping further evaluation.
 * Returns BT_FAILURE only if all children fail.
 *
 * Memory: resumes from the last RUNNING child index rather than restarting from child 1.
 * The observer/interrupt system resets this via CancelActions() when conditions change.
 */
/datum/bt_node/composite/selector
	/// Per-controller index of the child that last returned BT_RUNNING. 1-based. Keyed by controller ref.
	var/alist/running_child_index = alist()

/datum/bt_node/composite/selector/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick(controller))
		return tick_results[controller] || BT_FAILURE

	var/result = BT_FAILURE
	var/start = running_child_index[controller] || 1
	for(var/i in start to length(children))
		var/datum/bt_node/child = children[i]
		var/child_result = child.tick(controller, seconds_per_tick)
		if(child_result != BT_FAILURE)
			result = child_result
			if(child_result == BT_RUNNING)
				running_child_index[controller] = i
			else
				running_child_index -= controller
			if(tick_rate)
				tick_cooldowns[controller] = world.time
				tick_results[controller] = result
			return result

	running_child_index -= controller
	if(tick_rate)
		tick_cooldowns[controller] = world.time
		tick_results[controller] = result
	return result

/datum/bt_node/composite/selector/reset_tick_state(datum/ai_controller/controller)
	. = ..()
	running_child_index -= controller

/**
 * Subplan node: runs children like a sequence (stops on first failure or running child),
 * but applies configurable restart policies when the run completes instead of propagating
 * the result directly.
 *
 * success_policy:
 *   BT_SUBPLAN_SUCCEED_ON_SUCCESS (default) — propagates BT_SUCCESS when all children succeed.
 *   BT_SUBPLAN_LOOP_ON_SUCCESS              — resets all children and returns BT_RUNNING, restarting next tick.
 *
 * failure_policy:
 *   BT_SUBPLAN_FAIL_ON_FAILURE (default) — propagates BT_FAILURE when a child fails.
 *   BT_SUBPLAN_LOOP_ON_FAILURE           — resets all children and returns BT_RUNNING, restarting next tick.
 *
 * Combining both loop policies creates an infinite loop that only exits via an external
 * observer abort or CancelActions().
 */
/datum/bt_node/composite/subplan
	/// BT_SUBPLAN_SUCCEED_ON_SUCCESS: propagate success (default). BT_SUBPLAN_LOOP_ON_SUCCESS: restart.
	var/success_policy = BT_SUBPLAN_SUCCEED_ON_SUCCESS
	/// BT_SUBPLAN_FAIL_ON_FAILURE: propagate failure (default). BT_SUBPLAN_LOOP_ON_FAILURE: restart.
	var/failure_policy = BT_SUBPLAN_FAIL_ON_FAILURE
	/// Per-controller index of the child that last returned BT_RUNNING. 1-based. Keyed by controller ref.
	var/alist/running_child_index = alist()

/datum/bt_node/composite/subplan/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick(controller))
		return tick_results[controller] || BT_RUNNING

	var/start = running_child_index[controller] || 1
	for(var/i in start to length(children))
		var/datum/bt_node/child = children[i]
		var/child_result = child.tick(controller, seconds_per_tick)
		if(child_result == BT_RUNNING)
			running_child_index[controller] = i
			if(tick_rate)
				tick_cooldowns[controller] = world.time
				tick_results[controller] = BT_RUNNING
			return BT_RUNNING
		if(child_result == BT_FAILURE)
			running_child_index -= controller
			var/result
			if(failure_policy == BT_SUBPLAN_LOOP_ON_FAILURE)
				for(var/datum/bt_node/c in children)
					c.reset_tick_state(controller)
				result = BT_RUNNING
			else
				result = BT_FAILURE
			if(tick_rate)
				tick_cooldowns[controller] = world.time
				tick_results[controller] = result
			return result

	// All children succeeded
	running_child_index -= controller
	var/result
	if(success_policy == BT_SUBPLAN_LOOP_ON_SUCCESS)
		for(var/datum/bt_node/c in children)
			c.reset_tick_state(controller)
		result = BT_RUNNING
	else
		result = BT_SUCCESS
	if(tick_rate)
		tick_cooldowns[controller] = world.time
		tick_results[controller] = result
	return result

/datum/bt_node/composite/subplan/reset_tick_state(datum/ai_controller/controller)
	. = ..()
	running_child_index -= controller

/**
 * Parallel node: ticks ALL children every planning cycle, regardless of intermediate results.
 * Success and failure are determined by the configurable success_policy and failure_policy.
 *
 * Intended use: run multiple independent branches simultaneously, e.g. locomotion + action.
 */
/datum/bt_node/composite/parallel
	/// BT_PARALLEL_SUCCESS_CHILD_ONE: succeed when child 1 succeeds (default).
	/// BT_PARALLEL_SUCCESS_ALL: succeed only when all children succeed.
	var/success_policy = BT_PARALLEL_SUCCESS_CHILD_ONE
	/// BT_PARALLEL_FAILURE_CHILD_ONE: fail when child 1 fails (default).
	/// BT_PARALLEL_FAILURE_ANY: fail when any child fails.
	var/failure_policy = BT_PARALLEL_FAILURE_CHILD_ONE
	/// If TRUE, children 2+ that complete (non-RUNNING) are reset and reticked rather than counted toward tallies.
	var/repeat_secondary = FALSE
	/// If TRUE, when child 1 finishes (non-RUNNING), all children 2+ are cancelled and the parallel immediately returns child 1's result.
	var/finish_on_primary = FALSE

/datum/bt_node/composite/parallel/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick(controller))
		return tick_results[controller] || BT_RUNNING

	var/succeeded = 0
	var/failed = 0
	var/primary_result

	for(var/i in 1 to length(children))
		var/datum/bt_node/child = children[i]
		var/child_result = child.tick(controller, seconds_per_tick)

		if(i == 1)
			primary_result = child_result
			if(child_result == BT_SUCCESS)
				succeeded++
			else if(child_result == BT_FAILURE)
				failed++
		else if(repeat_secondary && child_result != BT_RUNNING)
			child.reset_tick_state(controller)
		else
			if(child_result == BT_SUCCESS)
				succeeded++
			else if(child_result == BT_FAILURE)
				failed++

	if(finish_on_primary && primary_result != BT_RUNNING)
		for(var/i in 2 to length(children))
			var/datum/bt_node/child = children[i]
			child.reset_tick_state(controller)
		if(tick_rate)
			tick_cooldowns[controller] = world.time
			tick_results[controller] = primary_result
		return primary_result

	var/result
	if((failure_policy == BT_PARALLEL_FAILURE_CHILD_ONE && primary_result == BT_FAILURE) || \
			(failure_policy == BT_PARALLEL_FAILURE_ANY && failed > 0))
		result = BT_FAILURE
	else if((success_policy == BT_PARALLEL_SUCCESS_CHILD_ONE && primary_result == BT_SUCCESS) || \
			(success_policy == BT_PARALLEL_SUCCESS_ALL && succeeded == length(children)))
		result = BT_SUCCESS
	else
		result = BT_RUNNING

	if(tick_rate)
		tick_cooldowns[controller] = world.time
		tick_results[controller] = result
	return result
