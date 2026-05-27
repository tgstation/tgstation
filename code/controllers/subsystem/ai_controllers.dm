/// The subsystem used to tick [/datum/ai_controllers] instances. Handling the re-checking of plans.
SUBSYSTEM_DEF(ai_controllers)
	name = "AI Controller Ticker"
	ss_flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	dependencies = list(
		/datum/controller/subsystem/movement/ai_movement,
	)
	wait = 0.1 SECONDS //Plan every 1/10th second if required. In theory your AI should not be planning this much, but its useful because we want planning to be responsive when a previous plan ends.
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	var/list/currentrun = list()
	///type of status we are interested in running
	var/planning_status = AI_STATUS_ON
	/// The average tick cost of all active AI, calculated on fire.
	var/our_cost
	/// The tick cost of all currently processed AI, being summed together
	var/summing_cost

	/// TRUE once setup_bt_nodes() has run at least once.
	var/bt_nodes_setup = FALSE
	/// Assoc list of list-identity → built /datum/bt_node for inline descriptor trees.
	/// Keyed by the descriptor list reference itself, so each unique list gets its own built subtree.
	var/alist/cached_descriptor_nodes = alist()

/datum/controller/subsystem/ai_controllers/Initialize()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/ai_controllers/stat_entry(msg)
	var/list/planning_list = GLOB.ai_controllers_by_status[planning_status]
	msg = "\n  Planning AIs:[length(planning_list)]/[round(our_cost,1)]%"
	return ..()

/datum/controller/subsystem/ai_controllers/fire(resumed)
	if(!resumed)
		if(!bt_nodes_setup)
			setup_bt_nodes()
		var/list/planning_list = GLOB.ai_controllers_by_status[planning_status]
		currentrun = planning_list.Copy()
		summing_cost = 0

	//cache for sanic speed (lists are references anyways)
	var/list/current_run = src.currentrun
	var/timer = TICK_USAGE_REAL
	while(length(current_run))
		var/datum/ai_controller/ai_controller = current_run[length(current_run)]
		current_run.len--
		ai_controller.SelectBehaviors(wait * 0.1)

		if(MC_TICK_CHECK)
			break

	summing_cost += TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer)
	if(MC_TICK_CHECK)
		return

	our_cost = MC_AVERAGE(our_cost, summing_cost)

///Creates all singleton instances of /datum/ai_planning_subtree subtypes (DEPRECATED registry).
/// This proc is intentionally a no-op; the ai_subtrees registry has been removed.
/// Legacy subtrees should be ported to /datum/bt_node/subtree.
/datum/controller/subsystem/ai_controllers/proc/setup_subtrees()
	return

/**
 * Creates singleton instances of all /datum/bt_node subtypes that are not behaviors or planning
 * subtrees (those are handled by SSai_behaviors and setup_subtrees() respectively).
 * Also resolves children for composites and decorators. Children declared as plain list entries
 * use singleton lookup; assoc entries (typepath = config list) create a fresh configured instance.
 *
 * Deferred to the first fire() call (not Initialize()) so that SSai_behaviors is guaranteed to have
 * populated its singleton registry before we attempt cross-registry child resolution.
 */
/datum/controller/subsystem/ai_controllers/proc/setup_bt_nodes()
	bt_nodes_setup = TRUE
	for(var/node_type in subtypesof(/datum/bt_node))
		if(ispath(node_type, /datum/bt_node/ai_behavior))
			continue // Handled by SSai_behaviors
		var/datum/bt_node/node = new node_type
		GLOB.bt_nodes[node_type] = node
	for(var/node_type in GLOB.bt_nodes)
		resolve_node_children(GLOB.bt_nodes[node_type])

/**
 * Resolves the children/child of a composite or decorator node, creating configured instances
 * for assoc children_typepaths entries and using singletons for plain entries.
 * Safe to call on any node type; non-composite/non-decorator nodes are a no-op.
 */
/datum/controller/subsystem/ai_controllers/proc/resolve_node_children(datum/bt_node/node)
	if(istype(node, /datum/bt_node/composite))
		var/datum/bt_node/composite/comp = node
		if(!LAZYLEN(comp.children_typepaths) || LAZYLEN(comp.children))
			return
		comp.children = list()
		for(var/child_type in comp.children_typepaths)
			var/list/config = comp.children_typepaths[child_type]
			var/datum/bt_node/child = resolve_child_node(child_type, config)
			if(isnull(child))
				stack_trace("BT composite [node.type] references unknown child type [child_type]")
				continue
			comp.children += child
	else if(istype(node, /datum/bt_node/decorator))
		var/datum/bt_node/decorator/dec = node
		if(isnull(dec.child_typepath) || !isnull(dec.child))
			return
		dec.child = resolve_child_node(dec.child_typepath, null)
		if(isnull(dec.child))
			stack_trace("BT decorator [node.type] references unknown child type [dec.child_typepath]")
	else if(istype(node, /datum/bt_node/subtree))
		var/datum/bt_node/subtree/sub = node
		if(!isnull(sub.behavior_nodes) && isnull(sub.root))
			sub.root = build_node_from_descriptor(sub.behavior_nodes)

/**
 * Returns the BT node to use for a given child_type + optional config.
 * - config is null: returns the singleton from GLOB.bt_nodes, GLOB.ai_subtrees, or SSai_behaviors.
 * - config is a list: creates a fresh instance, applies configure(config), then resolves its children.
 */
/datum/controller/subsystem/ai_controllers/proc/resolve_child_node(child_type, list/config)
	if(config)
		var/datum/bt_node/child = new child_type
		child.configure(config)
		resolve_node_children(child)
		return child
	return GLOB.bt_nodes[child_type] || SSai_behaviors.ai_behaviors[child_type]

/**
 * Returns a BT node for the given entry, which may be:
 *   - A typepath: returns the singleton from GLOB.bt_nodes / GLOB.ai_subtrees / SSai_behaviors.
 *   - A behavior node list (built via BT_SELECTOR / BT_SEQUENCE / BT_PARALLEL / BT_LEAF / BT_DECORATOR
 *     macros): builds and caches a node from the descriptor, keyed by list identity.
 */
/datum/controller/subsystem/ai_controllers/proc/get_or_build_node(entry)
	if(ispath(entry))
		if(!bt_nodes_setup)
			setup_bt_nodes()
		return GLOB.bt_nodes[entry] || SSai_behaviors.ai_behaviors[entry]
	if(islist(entry))
		var/datum/bt_node/cached = cached_descriptor_nodes[entry]
		if(!isnull(cached))
			return cached
		var/datum/bt_node/node = build_node_from_descriptor(entry)
		cached_descriptor_nodes[entry] = node
		return node
	stack_trace("get_or_build_node() received unexpected entry type: [entry]")
	return null

/**
 * Recursively builds a BT node tree from an inline descriptor list.
 * Descriptor keys BT_DESC_TYPE and BT_DESC_CHILDREN are consumed internally;
 * all other keys are written as vars directly onto the new node instance.
 */
/datum/controller/subsystem/ai_controllers/proc/build_node_from_descriptor(list/desc)
	var/node_type = desc[BT_DESC_TYPE]
	var/datum/bt_node/node = new node_type
	for(var/key in desc)
		if(key == BT_DESC_TYPE || key == BT_DESC_CHILDREN)
			continue
		node.vars[key] = desc[key]
	var/list/children_descs = desc[BT_DESC_CHILDREN]
	if(LAZYLEN(children_descs))
		if(istype(node, /datum/bt_node/composite))
			var/datum/bt_node/composite/comp = node
			comp.children = list()
			for(var/child_entry in children_descs)
				var/datum/bt_node/child_node = get_or_build_node(child_entry)
				if(!isnull(child_node))
					comp.children += child_node
		else if(istype(node, /datum/bt_node/decorator))
			var/datum/bt_node/decorator/dec = node
			dec.child = get_or_build_node(children_descs[1])
	return node

///Called when the max Z level was changed, updating our coverage.
/datum/controller/subsystem/ai_controllers/proc/on_max_z_changed()
	if(!length(GLOB.ai_controllers_by_zlevel))
		GLOB.ai_controllers_by_zlevel = new /list(world.maxz,0)
	while (GLOB.ai_controllers_by_zlevel.len < world.maxz)
		GLOB.ai_controllers_by_zlevel.len++
		GLOB.ai_controllers_by_zlevel[GLOB.ai_controllers_by_zlevel.len] = list()
