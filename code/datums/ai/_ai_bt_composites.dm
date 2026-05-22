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

/**
 * Sequence node: ticks children in order.
 * Returns BT_FAILURE on first child failure.
 * Returns BT_RUNNING on first child returning BT_RUNNING (stops further evaluation).
 * Returns BT_SUCCESS only if all children succeed.
 */
/datum/bt_node/composite/sequence

/datum/bt_node/composite/sequence/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick(controller))
		return tick_results[controller] || BT_RUNNING

	var/result = BT_SUCCESS
	for(var/datum/bt_node/child as anything in children)
		var/child_result = child.tick(controller, seconds_per_tick)
		if(child_result != BT_SUCCESS)
			result = child_result
			break

	if(tick_rate)
		tick_cooldowns[controller] = world.time
		tick_results[controller] = result
	return result

/**
 * Selector node: ticks children in order.
 * Returns the first non-BT_FAILURE result (BT_SUCCESS or BT_RUNNING), stopping further evaluation.
 * Returns BT_FAILURE only if all children fail.
 */
/datum/bt_node/composite/selector

/datum/bt_node/composite/selector/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick(controller))
		return tick_results[controller] || BT_FAILURE

	var/result = BT_FAILURE
	for(var/datum/bt_node/child as anything in children)
		var/child_result = child.tick(controller, seconds_per_tick)
		if(child_result != BT_FAILURE)
			result = child_result
			break

	if(tick_rate)
		tick_cooldowns[controller] = world.time
		tick_results[controller] = result
	return result

/**
 * Parallel node: ticks ALL children every planning cycle, regardless of intermediate results.
 * Success and failure are determined by the configurable success_policy and failure_policy.
 *
 * Intended use: run multiple independent branches simultaneously, e.g. locomotion + action.
 * Replaces AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION and AI_BEHAVIOR_MOVE_AND_PERFORM for new content.
 */
/datum/bt_node/composite/parallel
	/// BT_PARALLEL_SUCCESS_ONE: succeed when any child succeeds (default).
	/// BT_PARALLEL_SUCCESS_ALL: succeed only when all children succeed.
	var/success_policy = BT_PARALLEL_SUCCESS_ONE
	/// BT_PARALLEL_FAILURE_ONE: fail when any child fails (default).
	/// BT_PARALLEL_FAILURE_ALL: fail only when all children fail.
	var/failure_policy = BT_PARALLEL_FAILURE_ONE

/datum/bt_node/composite/parallel/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!should_tick(controller))
		return tick_results[controller] || BT_RUNNING

	var/succeeded = 0
	var/failed = 0
	var/total = length(children)

	for(var/datum/bt_node/child as anything in children)
		switch(child.tick(controller, seconds_per_tick))
			if(BT_SUCCESS)
				succeeded++
			if(BT_FAILURE)
				failed++
			// BT_RUNNING counts toward neither tally

	var/result
	if((failure_policy == BT_PARALLEL_FAILURE_ONE && failed > 0) || \
			(failure_policy == BT_PARALLEL_FAILURE_ALL && failed == total))
		result = BT_FAILURE
	else if((success_policy == BT_PARALLEL_SUCCESS_ONE && succeeded > 0) || \
			(success_policy == BT_PARALLEL_SUCCESS_ALL && succeeded == total))
		result = BT_SUCCESS
	else
		result = BT_RUNNING

	if(tick_rate)
		tick_cooldowns[controller] = world.time
		tick_results[controller] = result
	return result
