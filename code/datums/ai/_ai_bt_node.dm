/**
 * Base class for all behavior tree nodes.
 *
 * All subtypes are singletons initialized by SSai_controllers on first fire.
 * Per-controller state is stored in assoc lists keyed by controller reference,
 * mirroring the pattern used by /datum/ai_movement.
 *
 * /datum/ai_behavior and /datum/ai_planning_subtree extend this type via
 * parent_type so they appear as BT nodes in a tree without changing their paths.
 */
/datum/bt_node
	/// How often (deciseconds) this node re-evaluates per controller. 0 = every planning tick.
	var/tick_rate = 0
	/// Per-controller last evaluation world.time. Keyed by controller ref. Only populated when tick_rate > 0.
	var/alist/tick_cooldowns = alist()
	/// Per-controller cached last BT_* result. Keyed by controller ref. Only populated when tick_rate > 0.
	var/alist/tick_results = alist()

/// Returns TRUE if enough time has elapsed for this node to be re-evaluated for the given controller.
/datum/bt_node/proc/should_tick(datum/ai_controller/controller)
	if(!tick_rate)
		return TRUE
	var/last = tick_cooldowns[controller]
	return isnull(last) || (last + tick_rate <= world.time)

/**
 * Called during ai_controller/SelectBehaviors(). Override in subtypes.
 * Returns BT_SUCCESS, BT_FAILURE, or BT_RUNNING.
 */
/datum/bt_node/proc/tick(datum/ai_controller/controller, seconds_per_tick)
	return BT_FAILURE

/// Called when a controller unpossesses its pawn, to prune stale per-controller entries.
/datum/bt_node/proc/reset_tick_state(datum/ai_controller/controller)
	tick_cooldowns -= controller
	tick_results -= controller

/**
 * Assigns pre-order depth-first execution indices to this node and its subtree.
 * Called once per controller type by ensure_execution_index_cache().
 * Leaf override: records exec_cache[src] = last_cache[src] = counter, returns counter + 1.
 * Composite/decorator subtypes override to recurse into children.
 */
/datum/bt_node/proc/assign_execution_indices(controller_type, counter, list/exec_cache, list/last_cache)
	exec_cache[src] = counter
	last_cache[src] = counter
	return counter + 1

/**
 * Apply a configuration list to this node instance by assigning vars directly.
 * Called by setup_bt_nodes() when creating configured (non-singleton) child instances
 * from children_typepaths assoc entries (typepath → config list).
 */
/datum/bt_node/proc/configure(list/config)
	for(var/var_name in config)
		vars[var_name] = config[var_name]

/**
 * Subtree node: a named, re-usable BT subgraph.
 *
 * Subtypes override New() to build an arbitrary internal tree and assign its root node
 * to `root`. tick() delegates entirely to root.tick() and returns whatever it returns.
 *
 * This decouples the subtree's identity (its type path) from any specific composite
 * semantics (selector/parallel/sequence). The root can be any node type.
 *
 * The controller's tree-walk helpers (setup_bt_observers, reset_bt_tick_states) descend
 * through the `root` pointer to reach all internal nodes.
 */
/datum/bt_node/subtree
	/// list built via BT_SELECTOR / BT_PARALLEL / etc. macros on the subtype definition.
	/// resolve_node_children() builds `root` from this during setup_bt_nodes().
	var/list/behavior_nodes = null
	/// The internal root node. Populated by resolve_node_children(). Do not set directly.
	var/datum/bt_node/root = null

/datum/bt_node/subtree/tick(datum/ai_controller/controller, seconds_per_tick)
	if(!root)
		return BT_FAILURE
	return root.tick(controller, seconds_per_tick)

/datum/bt_node/subtree/assign_execution_indices(controller_type, counter, list/exec_cache, list/last_cache)
	exec_cache[src] = counter
	counter++
	if(root)
		counter = root.assign_execution_indices(controller_type, counter, exec_cache, last_cache)
	last_cache[src] = counter - 1
	return counter
