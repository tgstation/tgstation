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



/datum/controller/subsystem/ai_controllers/Initialize()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/ai_controllers/stat_entry(msg)
	var/list/planning_list = GLOB.ai_controllers_by_status[planning_status]
	msg = "\n  Planning AIs:[length(planning_list)]/[round(our_cost,1)]%"
	return ..()

/datum/controller/subsystem/ai_controllers/fire(resumed)
	if(!resumed)
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
		var/list/resolved_children = list()
		for(var/child_type in comp.children_typepaths)
			var/list/config = comp.children_typepaths[child_type]
			var/datum/bt_node/child = resolve_child_node(child_type, config)
			if(isnull(child))
				stack_trace("BT composite [node.type] references unknown child type [child_type]")
				continue
			resolved_children += child
		if(istype(comp, /datum/bt_node/composite/subplan) && length(resolved_children) > 1)
			var/datum/bt_node/composite/sequence/legacy_subplan_sequence = new
			legacy_subplan_sequence.children = resolved_children
			comp.children = list(legacy_subplan_sequence)
		else
			comp.children = resolved_children
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
		else if(!isnull(sub.behavior_tree_json) && isnull(sub.root))
			var/filename = copytext(sub.behavior_tree_json, findlasttext(sub.behavior_tree_json, "/") + 1)
			var/tree_name = copytext(filename, 1, length(filename) - 4)
			sub.root = load_tree_from_json(BT_COMPILED_PATH(tree_name))

// Always creates a fresh instance regardless of whether config is provided.
/datum/controller/subsystem/ai_controllers/proc/resolve_child_node(child_type, list/config)
	if(!ispath(child_type, /datum/bt_node))
		return null
	var/datum/bt_node/child = new child_type
	if(config)
		child.configure(config)
	resolve_node_children(child)
	return child

/**
 * Returns a freshly instantiated BT node for the given entry, which may be:
 *   - A typepath: creates a new instance and resolves its children.
 *   - A behavior node list (built via BT_SELECTOR / BT_SEQUENCE / BT_PARALLEL / BT_LEAF / BT_DECORATOR
 *     macros): builds a node tree from the descriptor. Never cached; always fresh per controller.
 */
/datum/controller/subsystem/ai_controllers/proc/get_or_build_node(entry)
	if(ispath(entry))
		if(!ispath(entry, /datum/bt_node))
			stack_trace("get_or_build_node() received non-BT typepath: [entry]")
			return null
		var/datum/bt_node/node = new entry
		resolve_node_children(node)
		return node
	if(islist(entry))
		return build_node_from_descriptor(entry)
	stack_trace("get_or_build_node() received unexpected entry type: [entry]")
	return null

///Loads and decodes a compiled JSON
/datum/controller/subsystem/ai_controllers/proc/load_tree_from_json(path)
	var/list/desc = json_decode(file2text(path))
	return build_node_from_descriptor(desc)

/**
 * Recursively builds a BT node tree from an inline descriptor list.
 * Descriptor keys BT_DESC_TYPE and BT_DESC_CHILDREN are consumed internally;
 * all other keys are written as vars directly onto the new node instance.
 * Supports both legacy DM-literal descriptors (typepath values) and JSON-decoded
 * descriptors (string typepaths resolved via text2path).
 */
/datum/controller/subsystem/ai_controllers/proc/build_node_from_descriptor(list/desc)
	var/raw_type = desc[BT_DESC_TYPE]
	var/node_type = ispath(raw_type) ? raw_type : text2path(raw_type)
	if(isnull(node_type))
		stack_trace("build_node_from_descriptor(): unknown typepath '[raw_type]'")
		return null
	var/datum/bt_node/node = new node_type
	// For subtree references with behavior_tree_compiled_json, this builds their internal root.
	resolve_node_children(node)
	for(var/key in desc)
		if(key == BT_DESC_TYPE || key == BT_DESC_CHILDREN)
			continue
		node.vars[key] = desc[key]
	var/list/children_descs = desc[BT_DESC_CHILDREN]
	if(LAZYLEN(children_descs))
		if(istype(node, /datum/bt_node/composite))
			var/datum/bt_node/composite/comp = node
			var/list/resolved_children = list()
			for(var/child_entry in children_descs)
				var/datum/bt_node/child_node = get_or_build_node(child_entry)
				if(!isnull(child_node))
					resolved_children += child_node
			if(istype(comp, /datum/bt_node/composite/subplan) && length(resolved_children) > 1)
				var/datum/bt_node/composite/sequence/legacy_subplan_sequence = new
				legacy_subplan_sequence.children = resolved_children
				comp.children = list(legacy_subplan_sequence)
			else
				comp.children = resolved_children
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
