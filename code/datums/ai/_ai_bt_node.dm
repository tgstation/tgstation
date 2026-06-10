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
	///Owning controller for this node
	var/datum/ai_controller/owning_controller = null

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

/// Resets this node and all of its descendants, cancelling any behaviors still running in the subtree.
/datum/bt_node/proc/reset_subtree_tick_states()
	var/list/to_visit = list(src)
	var/index = 1
	while(index <= length(to_visit))
		var/datum/bt_node/node = to_visit[index++]
		node.reset_tick_state()
		node.collect_reset_children(to_visit)

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

/// Returns TRUE if this node or any descendant has an active (running) ai_behavior leaf.
/datum/bt_node/proc/has_active_descendants()
	return FALSE

/// Short display label for this node, stripping standard path prefixes.
/datum/bt_node/proc/get_label()
	var/t = "[type]"
	t = replacetext(t, "/datum/bt_node/decorator/", "")
	t = replacetext(t, "/datum/bt_node/ai_behavior/", "")
	t = replacetext(t, "/datum/ai_behavior/", "")
	t = replacetext(t, "/datum/bt_node/subtree/", "")
	t = replacetext(t, "/datum/ai_planning_subtree/", "")
	return t

/// Walks descendants to find the node with the given execution_index. Returns null if not found.
/datum/bt_node/proc/find_by_index(target_index)
	if(execution_index == target_index)
		return src
	var/list/ch = get_children()
	if(!ch)
		return null
	for(var/datum/bt_node/child as anything in ch)
		var/found = child.find_by_index(target_index)
		if(found)
			return found
	return null

/// Appends this node's active/upcoming state to lines for display. No-op for plain leaf nodes.
/datum/bt_node/proc/append_active_nodes(list/lines, indent)
	return

/// Called during finalize_tree() to set owning_controller, register overrides, and enqueue children.
/datum/bt_node/proc/finalize_node(datum/ai_controller/controller, list/to_visit)
	owning_controller = controller

/// Called during build_node_from_descriptor() to resolve and assign child nodes from JSON descriptors.
/datum/bt_node/proc/set_descriptor_children(list/children_descs, datum/ai_controller/controller)
	return

/// Returns a single-character status marker for display. Overridden by ai_behavior to check running.
/datum/bt_node/proc/get_status_marker()
	if(tick_rate > 0)
		if(world.time < tick_cooldown)
			return "-"
		if(tick_result == BT_SUCCESS)
			return "+"
		if(tick_result == BT_FAILURE)
			return "x"
	return "o"

/// Appends this node's full tree state (status + label + children) to lines for display.
/datum/bt_node/proc/append_full_tree_state(list/lines, indent)
	lines += "[indent][get_status_marker()] [get_label()]"

/// Adds all children that must be visited during reset to to_visit. No-op for leaf nodes.
/datum/bt_node/proc/collect_reset_children(list/to_visit)
	return

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
	/// Repo-relative path to the .bt.json source file for this subtree (e.g. "code/datums/ai/bots/bot_patrol.bt.json").
	/// resolve_node_children() derives the compiled path from this and loads the tree at runtime.
	var/behavior_tree_json = null
	/// list of BT node descriptors defining this subtree's root.
	/// resolve_node_children() builds `root` from this during tree construction.
	var/list/behavior_nodes = null
	/// The internal root node. Populated by resolve_node_children(). Do not set directly.
	var/datum/bt_node/root = null
	/// Set this to allow runtime overriding of this subtree, useful for things like pet commands!
	var/override_id = null
	/// Active override subtree. When set, tick() delegates to this node instead of root.
	/// Set to null to deactivate the override. Managed by set_behavior_tree_override() only.
	var/datum/bt_node/subtree/override_node = null
	///Any bindings this subtree has; assigned by the json
	var/list/bindings = null

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

/datum/bt_node/subtree/has_active_descendants()
	if(override_node)
		return override_node.has_active_descendants()
	return root && root.has_active_descendants()

/datum/bt_node/subtree/finalize_node(datum/ai_controller/controller, list/to_visit)
	..()
	if(!isnull(override_id))
		LAZYINITLIST(controller.override_slots)
		controller.override_slots[override_id] = src
	if(root)
		root.parent_node = src
		to_visit += root
	if(override_node)
		override_node.parent_node = src
		to_visit += override_node

/datum/bt_node/subtree/append_active_nodes(list/lines, indent)
	if(root && root.has_active_descendants())
		root.append_active_nodes(lines, indent)

/datum/bt_node/subtree/collect_reset_children(list/to_visit)
	if(root)
		to_visit += root
	if(override_node)
		to_visit += override_node

/datum/bt_node/subtree/append_full_tree_state(list/lines, indent)
	..()
	if(root)
		root.append_full_tree_state(lines, "[indent]  ")

/datum/bt_node/subtree/assign_execution_indices(counter)
	execution_index = counter
	counter++
	if(root)
		counter = root.assign_execution_indices(counter)
	if(override_node)
		counter = override_node.assign_execution_indices(counter)
	last_execution_index = counter - 1
	return counter
