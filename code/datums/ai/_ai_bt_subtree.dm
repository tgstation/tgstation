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

/datum/bt_node/subtree/Destroy()
	QDEL_NULL(root)
	QDEL_NULL(override_node)
	return ..()

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
