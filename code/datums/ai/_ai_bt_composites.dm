/**
 * Base composite node. Holds an ordered list of child bt_node instances.
 *
 * Set children_typepaths on your subtype definition to declare children.
 * SSai_controllers resolves them into instances when the controller's tree is built.
 */
/datum/bt_node/composite
	/// Typepaths of child nodes declared on the type. Resolved to instances at tree construction.
	var/list/children_typepaths = null
	/// Resolved child instances. Populated at tree construction. Do not set directly.
	var/list/children = null

/datum/bt_node/composite/get_children()
	return children

/datum/bt_node/composite/assign_execution_indices(counter)
	execution_index = counter
	counter++
	for(var/datum/bt_node/c in children)
		counter = c.assign_execution_indices(counter)
	last_execution_index = counter - 1
	return counter

/**
 * Sequence node: ticks children in order.
 * Returns BT_FAILURE on first child failure.
 * Returns BT_RUNNING on first child returning BT_RUNNING (stops further evaluation).
 * Returns BT_SUCCESS only if all children succeed.
 *
 * Resumes from the last RUNNING child index rather than restarting from child 1.
 */
/datum/bt_node/composite/sequence
	node_type = BT_NODE_SEQUENCE
	/// Index of the child that last returned BT_RUNNING.
	var/running_child_index = 0

/datum/bt_node/composite/sequence/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick())
		return tick_result || BT_RUNNING

	var/result = BT_SUCCESS
	var/start = running_child_index || 1
	for(var/i in start to length(children))
		var/datum/bt_node/child = children[i]
		var/child_result = child.tick(controller, seconds_per_tick)
		if(child_result != BT_SUCCESS)
			result = child_result
			if(child_result == BT_RUNNING)
				running_child_index = i
			else
				running_child_index = 0
			if(tick_rate)
				tick_cooldown = world.time
				tick_result = result
			return result

	running_child_index = 0
	if(tick_rate)
		tick_cooldown = world.time
		tick_result = result
	return result

/datum/bt_node/composite/sequence/reset_tick_state()
	. = ..()
	running_child_index = 0

/**
 * Selector node: ticks children in order.
 * Returns the first non-BT_FAILURE result (BT_SUCCESS or BT_RUNNING), stopping further evaluation.
 * Returns BT_FAILURE only if all children fail.
 *
 * Resumes from the last RUNNING child index rather than restarting from child 1.

 */
/datum/bt_node/composite/selector
	node_type = BT_NODE_SELECTOR
	/// Index of the child that last returned BT_RUNNING.
	var/running_child_index = 0

/datum/bt_node/composite/selector/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick())
		return tick_result || BT_FAILURE

	var/result = BT_FAILURE
	var/start = running_child_index || 1
	for(var/i in start to length(children))
		var/datum/bt_node/child = children[i]
		var/child_result = child.tick(controller, seconds_per_tick)
		if(child_result != BT_FAILURE)
			result = child_result
			if(child_result == BT_RUNNING)
				running_child_index = i
			else
				running_child_index = 0
			if(tick_rate)
				tick_cooldown = world.time
				tick_result = result
			return result

	running_child_index = 0
	if(tick_rate)
		tick_cooldown = world.time
		tick_result = result
	return result

/datum/bt_node/composite/selector/reset_tick_state()
	. = ..()
	running_child_index = 0

/**
 * Subplan node: Runs child and applies configurable restart policies
 * when the child completes instead of propagating completion directly.
 *
 * success_policy:
 *   BT_SUBPLAN_SUCCEED_ON_SUCCESS (default) — propagates BT_SUCCESS when all children succeed.
 *   BT_SUBPLAN_LOOP_ON_SUCCESS              — resets all children and returns BT_RUNNING, restarting next tick.
 *
 * failure_policy:
 *   BT_SUBPLAN_FAIL_ON_FAILURE (default) — propagates BT_FAILURE when a child fails.
 *   BT_SUBPLAN_LOOP_ON_FAILURE           — resets all children and returns BT_RUNNING, restarting next tick.
 *
 * Combining both loop policies creates an infinite loop that only exits via an external observer abort or CancelActions(), so be careful pls
 */
/datum/bt_node/composite/subplan
	node_type = BT_NODE_SUBPLAN
	/// BT_SUBPLAN_SUCCEED_ON_SUCCESS: propagate success (default). BT_SUBPLAN_LOOP_ON_SUCCESS: restart.
	var/success_policy = BT_SUBPLAN_SUCCEED_ON_SUCCESS
	/// BT_SUBPLAN_FAIL_ON_FAILURE: propagate failure (default). BT_SUBPLAN_LOOP_ON_FAILURE: restart.
	var/failure_policy = BT_SUBPLAN_FAIL_ON_FAILURE

/datum/bt_node/composite/subplan/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick())
		return tick_result || BT_RUNNING

	var/datum/bt_node/child = LAZYACCESS(children, 1)
	if(isnull(child))
		if(tick_rate)
			tick_cooldown = world.time
			tick_result = BT_FAILURE
		return BT_FAILURE

	var/child_result = child.tick(controller, seconds_per_tick)
	if(child_result == BT_RUNNING)
		if(tick_rate)
			tick_cooldown = world.time
			tick_result = BT_RUNNING
		return BT_RUNNING

	if(child_result == BT_FAILURE)
		var/result
		if(failure_policy == BT_SUBPLAN_LOOP_ON_FAILURE)
			child.reset_tick_state()
			result = BT_RUNNING
		else
			result = BT_FAILURE
		if(tick_rate)
			tick_cooldown = world.time
			tick_result = result
		return result

	var/result
	if(success_policy == BT_SUBPLAN_LOOP_ON_SUCCESS)
		child.reset_tick_state()
		result = BT_RUNNING
	else
		result = BT_SUCCESS
	if(tick_rate)
		tick_cooldown = world.time
		tick_result = result
	return result

/**
 * Parallel node: ticks ALL children every planning cycle, regardless of intermediate results.
 * Success and failure are determined by the configurable success_policy and failure_policy.
 *
 * Intended use: run multiple independent branches simultaneously, e.g. locomotion + action.
 */
/datum/bt_node/composite/parallel
	node_type = BT_NODE_PARALLEL
	/// BT_PARALLEL_SUCCESS_CHILD_ONE: succeed when child 1 succeeds (default).
	/// BT_PARALLEL_SUCCESS_ALL: succeed only when all children succeed.
	var/success_policy = BT_PARALLEL_SUCCESS_CHILD_ONE
	/// BT_PARALLEL_FAILURE_CHILD_ONE: fail when child 1 fails (default).
	/// BT_PARALLEL_FAILURE_ANY: fail when any child fails.
	var/failure_policy = BT_PARALLEL_FAILURE_CHILD_ONE
	/// If TRUE, children 2+ that complete are reset and reticked
	var/repeat_secondary = FALSE
	/// Minimum delay before a repeat_secondary child can be re-ticked after completing. 0 = immediate (default).
	var/repeat_secondary_delay = 0
	/// world.time values for when each secondary child is next allowed to tick. Null when no delays are active.
	var/list/secondary_ready_at = null
	/// If TRUE, when child 1 finishes (non-RUNNING), all children 2+ are cancelled and the parallel immediately returns child 1's result.
	var/finish_on_primary = FALSE

/datum/bt_node/composite/parallel/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick())
		return tick_result || BT_RUNNING

	var/succeeded = 0
	var/failed = 0
	var/primary_result

	for(var/i in 1 to length(children))
		var/datum/bt_node/child = children[i]

		if(i > 1 && repeat_secondary && repeat_secondary_delay > 0 && LAZYACCESS(secondary_ready_at, i) > world.time)
			continue // secondary child is waiting out its repeat delay

		var/child_result = child.tick(controller, seconds_per_tick)

		if(i == 1)
			primary_result = child_result
			if(child_result == BT_SUCCESS)
				succeeded++
			else if(child_result == BT_FAILURE)
				failed++
		else if(repeat_secondary && child_result != BT_RUNNING)
			child.reset_tick_state()
			if(repeat_secondary_delay > 0)
				if(length(secondary_ready_at) < i)
					LAZYSETLEN(secondary_ready_at, i)
				secondary_ready_at[i] = world.time + repeat_secondary_delay
		else
			if(child_result == BT_SUCCESS)
				succeeded++
			else if(child_result == BT_FAILURE)
				failed++

	if(finish_on_primary && primary_result != BT_RUNNING)
		for(var/i in 2 to length(children))
			var/datum/bt_node/child = children[i]
			child.reset_tick_state()
		if(tick_rate)
			tick_cooldown = world.time
			tick_result = primary_result
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
		tick_cooldown = world.time
		tick_result = result
	return result

/datum/bt_node/composite/parallel/reset_tick_state()
	. = ..()
	secondary_ready_at = null
