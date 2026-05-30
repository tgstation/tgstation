/**
 * Base class for all behavior tree nodes.
 *
 * Each controller builds its own tree of node instances, so all state lives
 * directly on the instance rather than in assoc lists keyed by controller.
 */
/datum/bt_node
	/// Node type identifier for the BT viewer. One of the BT_NODE_* defines.
	var/node_type = BT_NODE_LEAF
	/// How often (deciseconds) this node re-evaluates. 0 = every planning tick.
	var/tick_rate = 0
	/// world.time of last evaluation. Only meaningful when tick_rate > 0.
	var/tick_cooldown = 0
	/// Cached last BT_* result. Only meaningful when tick_rate > 0.
	var/tick_result = BT_FAILURE
	/// Pre-order depth-first index of this node in the tree. Assigned by finalize_tree().
	var/execution_index = 0
	/// Index of the last descendant node in this subtree. Equal to execution_index for leaves.
	var/last_execution_index = 0
	/// Reference to this node's parent in the resolved tree. Set by ai_controller/finalize_tree().
	/// Null for root-level nodes.
	var/datum/bt_node/parent_node = null

/// Returns TRUE if enough time has elapsed for this node to be re-evaluated.
/datum/bt_node/proc/should_tick()
	if(!tick_rate)
		return TRUE
	return tick_cooldown + tick_rate <= world.time

/**
 * Called during ai_controller/SelectBehaviors(). Override in subtypes.
 * Returns BT_SUCCESS, BT_FAILURE, or BT_RUNNING.
 */
/datum/bt_node/proc/tick(datum/ai_controller/controller, seconds_per_tick)
	return BT_FAILURE

/// Resets tick timing and cached result for this node instance.
/datum/bt_node/proc/reset_tick_state()
	tick_cooldown = 0
	tick_result = BT_FAILURE

/**
 * Assigns pre-order depth-first execution indices to this node and its subtree.
 * Called once per controller tree by finalize_tree().
 */
/datum/bt_node/proc/assign_execution_indices(counter)
	execution_index = counter
	last_execution_index = counter
	return counter + 1

/// Apply a configuration list to this node instance by assigning vars directly.
/datum/bt_node/proc/configure(list/config)
	for(var/var_name in config)
		vars[var_name] = config[var_name]

/**
 * Returns the list of direct child bt_node instances for tree traversal.
 * Returns null for leaf nodes (default). Overridden in composites, decorators, and subtrees.
 */
/datum/bt_node/proc/get_children()
	return null

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
	node_type = BT_NODE_SUBTREE
	/// Path to the .bt.json file that is the source of truth for this subtree's behavior_nodes.
	/// Consumed by the VS Code BT editor extension; not used at runtime.
	var/behavior_tree_json = null
	/// list of BT node descriptors defining this subtree's root.
	/// resolve_node_children() builds `root` from this during tree construction.
	var/list/behavior_nodes = null
	/// The internal root node. Populated by resolve_node_children(). Do not set directly.
	var/datum/bt_node/root = null
	/// If non-null, this subtree acts as a runtime override slot. The string is a
	/// SUBPLAN_ID_* constant. ai_controller.set_behavior_tree_override() finds the slot
	/// by this ID and sets override_node on it.
	var/override_id = null
	/// Active override subtree. When set, tick() delegates to this node instead of root.
	/// Set to null to deactivate the override. Managed by set_behavior_tree_override() only.
	var/datum/bt_node/subtree/override_node = null

/datum/bt_node/subtree/tick(datum/ai_controller/controller, seconds_per_tick)
	if(override_node)
		return override_node.tick(controller, seconds_per_tick)
	if(!root)
		return BT_FAILURE
	return root.tick(controller, seconds_per_tick)

/datum/bt_node/subtree/get_children()
	if(override_node)
		return override_node.root ? list(override_node.root) : null
	return root ? list(root) : null

/datum/bt_node/subtree/assign_execution_indices(counter)
	execution_index = counter
	counter++
	if(root)
		counter = root.assign_execution_indices(counter)
	if(override_node)
		counter = override_node.assign_execution_indices(counter)
	last_execution_index = counter - 1
	return counter
