/*
AI controllers are a datumized form of AI that simulates the input a player would otherwise give to a atom. What this means is that these datums
have ways of interacting with a specific atom and control it. They posses a blackboard with the information the AI knows and has, and will plan behaviors it will try to execute through
multiple modular subtrees with behaviors
*/

/datum/ai_controller
	///The atom this controller is controlling
	var/atom/pawn
	/**
	 * This is a list of variables the AI uses and can be mutated by actions.
	 *
	 * When an action is performed you pass this list and any relevant keys for the variables it can mutate.
	 *
	 * DO NOT set values in the blackboard directly, and especially not if you're adding a datum reference to this!
	 * Use the setters, this is important for reference handing.
	 */
	var/alist/blackboard = alist()

	///Bitfield of traits for this AI to handle extra behavior
	var/ai_traits = DEFAULT_AI_FLAGS
	// DEPRECATED queue-based behavior vars — kept for compile compatibility of legacy subtrees.
	// These are never populated by the new BT execution model.
	var/alist/planned_behaviors = alist()
	var/alist/current_behaviors = alist()
	var/alist/behavior_cooldowns = alist()
	// DEPRECATED idle behavior — port idle logic to a BT_SELECTOR tail entry.
	var/datum/idle_behavior/idle_behavior = null
	///Current status of AI (OFF/ON)
	var/ai_status
	///Current movement target of the AI, generally set by decision making.
	var/atom/current_movement_target
	///Identifier for what last touched our movement target, so it can be cleared conditionally
	var/movement_target_source
	///Tracks recent pathing attempts, if we fail too many in a row we fail our current plans.
	var/consecutive_pathing_attempts
	///Can the AI remain in control if there is a client?
	var/continue_processing_when_client = FALSE
	///distance to give up on target
	var/max_target_distance = 14
	/// Repo-relative path to the .bt.json source file for this controller (e.g. "code/datums/ai/basic_mobs/cleanbot.bt.json").
	/// initialize_behavior_tree() derives the compiled path from this and loads the BT tree at runtime.
	var/behavior_tree_json = null
	///All behavior_nodes for the BT tree; populated on init from typepaths or BT_* descriptors.
	var/list/behavior_nodes
	/// Execution index of the leaf node currently returning BT_RUNNING. 0 = nothing active.
	var/active_execution_index = 0
	/// Set to TRUE by CancelActions() when it fires mid-tick. Checked by composites to abort the current tick loop early, preventing running_child_index from being re-established after a reset. Cleared at the start of SelectBehaviors().
	var/cancelled_during_tick = FALSE
	/// Draining log of all leaf execution indices that fired since the last bt_viewer poll. Null when no viewer is attached.
	var/list/bt_execution_log = null
	/// assoc list of override_id -> /datum/bt_node/subtree for runtime subtree replacement.
	/// Populated by finalize_tree() when subtrees with override_id are found. Null until then.
	var/list/override_slots = null
	/// Decorators in polling mode (observer_abort set, no signal registered). Iterated after each SelectBehaviors tick so their condition is re-evaluated even when skipped by composite resume logic.
	var/list/polling_observers = null
	///our current cell grid
	var/datum/cell_tracker/our_cells

	// Movement related things here
	///Reference to the movement datum we use. Is a type on initialize but becomes a ref afterwards.
	var/datum/ai_movement/ai_movement = /datum/ai_movement/dumb
	///Delay between movements. This is on the controller so we can keep the movement datum singleton
	var/movement_delay = 0.1 SECONDS

	// The variables below are fucking stupid and should be put into the blackboard at some point.
	///AI paused time
	var/paused_until = 0
	///Can this AI idle?
	var/can_idle = TRUE
	///What distance should we be checking for interesting things when considering idling/deidling? Defaults to AI_DEFAULT_INTERESTING_DIST
	var/interesting_dist = AI_DEFAULT_INTERESTING_DIST
	/// TRUE if we're able to run, FALSE if we aren't
	/// Should not be set manually, override get_able_to_run() instead
	/// Make sure you hook update_able_to_run() in setup_able_to_run() to whatever parameters changing that you added
	/// Otherwise we will not pay attention to them changing
	var/able_to_run = FALSE

	///Can run even if no clients are on the zlevel, used by
	var/can_run_without_clients_on_zlevel = FALSE

/datum/ai_controller/New(atom/new_pawn)
	change_ai_movement_type(ai_movement)
	initialize_behavior_tree()

	if(!isnull(new_pawn)) // unit tests need the ai_controller to exist in isolation due to list schenanigans i hate it here
		PossessPawn(new_pawn)

/datum/ai_controller/Destroy(force)
	UnpossessPawn(FALSE)
	if(ai_status)
		GLOB.ai_controllers_by_status[ai_status] -= src
		for(var/datum/controller/subsystem/ai_controllers/controller_subsystem in Master.subsystems)
			if(controller_subsystem.planning_status == ai_status)
				controller_subsystem.currentrun -= src
				break
	our_cells = null
	set_movement_target(type, null)
	if(ai_movement.moving_controllers[src])
		ai_movement.stop_moving_towards(src)
	return ..()

///Sets the current movement target, with an optional param to override the movement behavior
/datum/ai_controller/proc/set_movement_target(source, atom/target, datum/ai_movement/new_movement)
	if(current_movement_target)
		UnregisterSignal(current_movement_target, list(COMSIG_MOVABLE_MOVED, COMSIG_PREQDELETED))
	if(!isnull(target) && !isatom(target))
		stack_trace("[pawn]'s current movement target is not an atom, rather a [target.type]! Did you accidentally set it to a weakref?")
		CancelActions()
		return
	movement_target_source = source
	current_movement_target = target
	if(!isnull(current_movement_target))
		RegisterSignal(current_movement_target, COMSIG_MOVABLE_MOVED, PROC_REF(on_movement_target_move))
		RegisterSignal(current_movement_target, COMSIG_PREQDELETED, PROC_REF(on_movement_target_delete))
	if(new_movement)
		change_ai_movement_type(new_movement)

///Overrides the current ai_movement of this controller with a new one
/datum/ai_controller/proc/change_ai_movement_type(datum/ai_movement/new_movement)
	ai_movement = SSai_movement.movement_types[new_movement]

///Completely replaces the behavior_nodes with a new set based on argument provided.
/datum/ai_controller/proc/replace_behavior_nodes(list/typepaths_of_new_subtrees)
	behavior_nodes = typepaths_of_new_subtrees
	initialize_behavior_tree()

/// Resolves the children/child of a composite or decorator node, creating configured instances.
/// Safe to call on any node type; non-composite/non-decorator nodes are a no-op.
/datum/ai_controller/proc/resolve_node_children(datum/bt_node/node)
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
			var/list/raw_desc = json_decode(file2text(BT_COMPILED_PATH(tree_name)))
			if(LAZYLEN(sub.bindings) || !isnull(raw_desc[BT_DESC_BINDINGS]))
				raw_desc = apply_bindings_to_descriptor(raw_desc, sub.bindings)
			sub.root = build_node_from_descriptor(raw_desc)

// Always creates a fresh instance regardless of whether config is provided.
/datum/ai_controller/proc/resolve_child_node(child_type, list/config)
	if(!ispath(child_type, /datum/bt_node))
		return null
	var/datum/bt_node/child = new child_type
	if(config)
		child.configure(config)
	resolve_node_children(child)
	return child

/datum/ai_controller/proc/get_or_build_node(entry)
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

///Loads and decodes a compiled BT JSON file into a node tree.
/datum/ai_controller/proc/load_tree_from_json(path)
	var/list/desc = json_decode(file2text(path))
	return build_node_from_descriptor(desc)

/**
 * Merges call-site binding overrides with the subtree's declared defaults,
 * then substitutes all $name placeholders in the descriptor tree.
 * Returns a new descriptor with BT_DESC_BINDINGS stripped and placeholders resolved.
 */
/datum/ai_controller/proc/apply_bindings_to_descriptor(list/desc, list/call_site_bindings)
	var/list/merged = list()
	var/list/declared = desc[BT_DESC_BINDINGS]
	for(var/name in declared)
		merged[name] = declared[name]["default"]
	for(var/name in call_site_bindings)
		merged[name] = call_site_bindings[name]
	return _substitute_bindings(desc, merged)

/// Recursively walks a descriptor list, replacing "$name" strings with their bound values.
/datum/ai_controller/proc/_substitute_bindings(list/desc, list/merged)
	var/list/out = list()
	for(var/key in desc)
		if(key == BT_DESC_BINDINGS)
			continue
		var/value = desc[key]
		if(islist(value))
			var/list/resolved_list = list()
			for(var/item in value)
				if(islist(item))
					resolved_list += list(_substitute_bindings(item, merged))
				else if(istext(item) && copytext(item, 1, 2) == "$")
					var/binding_name = copytext(item, 2)
					resolved_list += isnull(merged[binding_name]) ? item : merged[binding_name]
				else
					resolved_list += item
			out[key] = resolved_list
		else if(istext(value) && copytext(value, 1, 2) == "$")
			var/binding_name = copytext(value, 2)
			out[key] = isnull(merged[binding_name]) ? value : merged[binding_name]
		else
			out[key] = value
	return out

/**
 * Recursively builds a BT node tree from a descriptor list.
 * BT_DESC_TYPE and BT_DESC_CHILDREN are consumed internally; all other keys are written
 * as vars onto the node. String values starting with "/" are resolved via text2path so
 * typepath args (e.g. "/datum/ai_movement/basic_avoidance") arrive as actual types.
 */
/datum/ai_controller/proc/build_node_from_descriptor(list/desc)
	var/raw_type = desc[BT_DESC_TYPE]
	if(!raw_type) // This can happen if we have an overriden type with no binding. (e.g. subtrees not being overriden and default to null)
		return null
	var/node_type = ispath(raw_type) ? raw_type : text2path(raw_type)
	if(isnull(node_type))
		stack_trace("build_node_from_descriptor(): unknown typepath '[raw_type]'")
		return null
	var/datum/bt_node/node = new node_type
	for(var/key in desc)
		if(key == BT_DESC_TYPE || key == BT_DESC_CHILDREN || key == BT_DESC_BINDINGS)
			continue
		var/value = desc[key]
		if(islist(value))
			var/list/resolved = value
			for(var/i in 1 to length(resolved))
				if(istext(resolved[i]))
					var/as_path = text2path(resolved[i])
					if(!isnull(as_path))
						resolved[i] = as_path
		else if(istext(value))
			var/as_path = text2path(value)
			if(!isnull(as_path))
				value = as_path
		node.vars[key] = value
	resolve_node_children(node)
	var/list/children_descs = desc[BT_DESC_CHILDREN]
	if(LAZYLEN(children_descs))
		node.set_descriptor_children(children_descs, src)
	return node

/// Builds the per-controller BT node tree from behavior_nodes typepaths or descriptors, then finalizes it.
/datum/ai_controller/proc/initialize_behavior_tree()
	if(!isnull(behavior_tree_json) && !LAZYLEN(behavior_nodes))

		///This kind of sucks to do every time, but I don't know if there's a nicer way to inject .compiled into the path?
		var/filename = copytext(behavior_tree_json, findlasttext(behavior_tree_json, "/") + 1) // Find the filename
		var/tree_name = copytext(filename, 1, length(filename) - 4) //Remove the .json extension
		var/compiled_path = BT_COMPILED_PATH(tree_name) //Find the compiled version of this BT
		var/datum/bt_node/root = load_tree_from_json(compiled_path)
		if(isnull(root))
			stack_trace("[type] failed to load behavior tree from compiled JSON: [compiled_path]")
			return
		behavior_nodes = list(root)
		finalize_tree()
		return
	if(!LAZYLEN(behavior_nodes))
		return
	var/list/temp_subtree_list = list()
	if(!isnull(behavior_nodes[BT_DESC_TYPE]))
		var/datum/bt_node/node_instance = get_or_build_node(behavior_nodes)
		if(isnull(node_instance))
			stack_trace("[type]'s behavior_nodes BT descriptor could not be built")
		else
			temp_subtree_list += node_instance
	else
		for(var/entry in behavior_nodes)
			var/datum/bt_node/node_instance = get_or_build_node(entry)
			if(isnull(node_instance))
				stack_trace("[type]'s behavior_nodes contains unknown entry: [entry]")
				continue
			temp_subtree_list += node_instance
	behavior_nodes = temp_subtree_list
	finalize_tree()

/// Walks the resolved tree to set owning_controller and parent_node on all nodes, populates
/// override_slots, and assigns pre-order execution indices. Called after initialize_behavior_tree() and
/// after set_behavior_tree_override() installs or removes an override node.
/datum/ai_controller/proc/finalize_tree()
	if(!LAZYLEN(behavior_nodes))
		return
	override_slots = null
	var/list/to_visit = behavior_nodes.Copy()
	for(var/datum/bt_node/root in behavior_nodes)
		root.parent_node = null
	var/index = 1
	while(index <= length(to_visit))
		var/datum/bt_node/node = to_visit[index++]
		node.finalize_node(src, to_visit)
	var/counter = 1
	for(var/datum/bt_node/root in behavior_nodes)
		counter = root.assign_execution_indices(counter)

///Proc to move from one pawn to another, this will destroy the target's existing controller.
/datum/ai_controller/proc/PossessPawn(atom/new_pawn)
	SHOULD_CALL_PARENT(TRUE)
	if(pawn) //Reset any old signals
		UnpossessPawn(FALSE)

	if(istype(new_pawn.ai_controller)) //Existing AI, kill it.
		QDEL_NULL(new_pawn.ai_controller)

	if(TryPossessPawn(new_pawn) & AI_CONTROLLER_INCOMPATIBLE)
		qdel(src)
		CRASH("[src] attached to [new_pawn] but these are not compatible!")

	pawn = new_pawn
	pawn.ai_controller = src

	var/turf/pawn_turf = get_turf(pawn)
	if(pawn_turf)
		GLOB.ai_controllers_by_zlevel[pawn_turf.z] += src

	SEND_SIGNAL(src, COMSIG_AI_CONTROLLER_POSSESSED_PAWN)

	reset_ai_status()
	RegisterSignal(pawn, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_changed_z_level))
	RegisterSignal(pawn, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_changed))
	RegisterSignal(pawn, COMSIG_MOB_LOGIN, PROC_REF(on_sentience_gained))
	RegisterSignal(pawn, COMSIG_QDELETING, PROC_REF(on_pawn_qdeleted))
	RegisterSignal(pawn, COMSIG_EVLOGGING_ENABLED, PROC_REF(on_pawn_evlogging_enabled))
	RegisterSignal(pawn, COMSIG_EVLOGGING_DISABLED, PROC_REF(on_pawn_evlogging_disabled))
	update_able_to_run()
	setup_able_to_run()

	our_cells = new(interesting_dist, interesting_dist, 1)
	set_new_cells()

	RegisterSignal(pawn, COMSIG_MOVABLE_MOVED, PROC_REF(update_grid))

/datum/ai_controller/proc/update_grid(datum/source, datum/spatial_grid_cell/new_cell)
	SIGNAL_HANDLER

	set_new_cells()
	if(current_movement_target)
		check_target_max_distance()

/datum/ai_controller/proc/on_movement_target_move(atom/source)
	SIGNAL_HANDLER
	check_target_max_distance()

/datum/ai_controller/proc/on_movement_target_delete(atom/source)
	SIGNAL_HANDLER
	set_movement_target(source = type, target = null)

/datum/ai_controller/proc/check_target_max_distance()
	if(get_dist(current_movement_target, pawn) > max_target_distance)
		CancelActions()

/datum/ai_controller/proc/set_new_cells()
	if(isnull(our_cells))
		return

	var/turf/our_turf = get_turf(pawn)

	if(isnull(our_turf))
		return

	var/list/cell_collections = our_cells.recalculate_cells(our_turf)

	for(var/datum/old_grid as anything in cell_collections[2])
		UnregisterSignal(old_grid, list(SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), SPATIAL_GRID_CELL_EXITED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS)))

	for(var/datum/spatial_grid_cell/new_grid as anything in cell_collections[1])
		RegisterSignal(new_grid, SPATIAL_GRID_CELL_ENTERED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), PROC_REF(on_client_enter))
		RegisterSignal(new_grid, SPATIAL_GRID_CELL_EXITED(SPATIAL_GRID_CONTENTS_TYPE_CLIENTS), PROC_REF(on_client_exit))

	recalculate_idle()

/datum/ai_controller/proc/should_idle()
	if(!can_idle || isnull(our_cells))
		return FALSE
	for(var/datum/spatial_grid_cell/grid as anything in our_cells.member_cells)
		if(locate(/mob/living) in grid.client_contents)
			return FALSE
	return TRUE

/datum/ai_controller/proc/recalculate_idle(datum/exited)
	if(ai_status == AI_STATUS_OFF)
		return

	var/distance = INFINITY
	if(islist(exited))
		var/list/exited_list = exited
		distance = get_dist(pawn, exited_list[1])
	else if(isatom(exited))
		var/atom/exited_atom = exited
		distance = get_dist(pawn, exited_atom)

	if(distance <= interesting_dist) //is our target in between interesting cells?
		return

	if(should_idle())
		set_ai_status(AI_STATUS_IDLE)

/datum/ai_controller/proc/on_client_enter(datum/source, list/target_list)
	SIGNAL_HANDLER

	if (!(locate(/mob/living) in target_list))
		return

	if(ai_status == AI_STATUS_IDLE)
		set_ai_status(AI_STATUS_ON)

/datum/ai_controller/proc/on_client_exit(datum/source, datum/exited)
	SIGNAL_HANDLER

	recalculate_idle(exited)

/// Sets the AI on or off based on current conditions, call to reset after you've manually disabled it somewhere
/datum/ai_controller/proc/reset_ai_status()
	set_ai_status(get_expected_ai_status())

/**
 * Gets the AI status we expect the AI controller to be on at this current moment.
 * Returns AI_STATUS_OFF if it's inhabited by a Client and shouldn't be, if it's dead and cannot act while dead, or is on a z level without clients.
 * Returns AI_STATUS_ON otherwise.
 */
/datum/ai_controller/proc/get_expected_ai_status()
	if (isnull(get_turf(pawn)))
		return AI_STATUS_OFF

	if (!ismob(pawn))
		return AI_STATUS_ON

	var/mob/living/mob_pawn = pawn
	if(!continue_processing_when_client && mob_pawn.client)
		return AI_STATUS_OFF

	if(mob_pawn.stat == DEAD)
		if(ai_traits & CAN_ACT_WHILE_DEAD)
			return AI_STATUS_ON
		return AI_STATUS_OFF

	var/turf/pawn_turf = get_turf(mob_pawn)
#ifdef TESTING
	if(!pawn_turf)
		CRASH("AI controller [src] controlling pawn ([pawn]) is not on a turf.")
#endif
	if((!length(SSmobs.clients_by_zlevel[pawn_turf.z]) && !can_run_without_clients_on_zlevel)|| !able_to_run)
		return AI_STATUS_OFF
	if(should_idle())
		return AI_STATUS_IDLE
	return AI_STATUS_ON

///Called when the AI controller pawn changes z levels, we check if there's any clients on the new one and wake up the AI if there is.
/datum/ai_controller/proc/on_changed_z_level(atom/source, turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	SIGNAL_HANDLER
	if (ismob(pawn))
		var/mob/mob_pawn = pawn
		if((mob_pawn?.client && !continue_processing_when_client))
			return
	if(old_turf)
		GLOB.ai_controllers_by_zlevel[old_turf.z] -= src
	if(isnull(new_turf))
		return
	GLOB.ai_controllers_by_zlevel[new_turf.z] += src
	reset_ai_status()

///Abstract proc for initializing the pawn to the new controller
/datum/ai_controller/proc/TryPossessPawn(atom/new_pawn)
	return

///Proc for deinitializing the pawn to the old controller
/datum/ai_controller/proc/UnpossessPawn(destroy)
	SHOULD_CALL_PARENT(TRUE)
	if(isnull(pawn))
		return // instantiated without an applicable pawn, fine

	SEND_SIGNAL(src, COMSIG_AI_CONTROLLER_UNPOSSESSED_PAWN)
	reset_bt_tick_states()
	set_ai_status(AI_STATUS_OFF)
	UnregisterSignal(pawn, list(COMSIG_MOVABLE_Z_CHANGED, COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT, COMSIG_MOB_STATCHANGE, COMSIG_QDELETING, COMSIG_EVLOGGING_ENABLED))
	clear_able_to_run()
	if(ai_movement.moving_controllers[src])
		ai_movement.stop_moving_towards(src)
	var/turf/pawn_turf = get_turf(pawn)
	if(pawn_turf)
		GLOB.ai_controllers_by_zlevel[pawn_turf.z] -= src
	pawn.ai_controller = null
	pawn = null
	if(destroy)
		qdel(src)

///Call reset tick state on every node in the tree
/datum/ai_controller/proc/reset_bt_tick_states()
	if(!LAZYLEN(behavior_nodes))
		return
	var/list/to_visit = behavior_nodes.Copy()
	var/index = 1
	while(index <= length(to_visit))
		var/datum/bt_node/node = to_visit[index++]
		node.reset_tick_state()
		node.collect_reset_children(to_visit)

/**
 * Installs or removes a runtime override on the subtree slot registered with the given id.
 *
 * id          — a SUBPLAN_ID_* constant matching a subtree node's override_id in this tree.
 * datum_type  — the /datum/bt_node/subtree subtype to install, or null to clear the override.
 */
/datum/ai_controller/proc/set_behavior_tree_override(id, datum_type)
	var/datum/bt_node/subtree/slot = LAZYACCESS(override_slots, id)
	if(isnull(slot))
		return

	var/current_type = isnull(slot.override_node) ? null : slot.override_node.type
	if(current_type == datum_type)
		return



	if(isnull(datum_type))
		slot.override_node = null
		finalize_tree()
		SEND_SIGNAL(pawn, COMSIG_AI_OVERRIDE_SLOT_CHANGED(id), null)
		return

	var/datum/bt_node/subtree/new_node = new datum_type
	resolve_node_children(new_node)
	slot.override_node = new_node
	finalize_tree()
	CancelActions() // Reset, not ideal; Maybe later on we can do this more gracefully.
	SEND_SIGNAL(pawn, COMSIG_AI_OVERRIDE_SLOT_CHANGED(id), datum_type)

/datum/ai_controller/proc/setup_able_to_run()
	// paused_until is handled by PauseAi() manually
	RegisterSignals(pawn, list(SIGNAL_ADDTRAIT(TRAIT_AI_PAUSED), SIGNAL_REMOVETRAIT(TRAIT_AI_PAUSED)), PROC_REF(update_able_to_run))

/datum/ai_controller/proc/clear_able_to_run()
	UnregisterSignal(pawn, list(SIGNAL_ADDTRAIT(TRAIT_AI_PAUSED), SIGNAL_REMOVETRAIT(TRAIT_AI_PAUSED)))

/datum/ai_controller/proc/update_able_to_run()
	SIGNAL_HANDLER
	var/run_flags = get_able_to_run()
	if(run_flags & AI_UNABLE_TO_RUN)
		able_to_run = FALSE
		GLOB.move_manager.stop_looping(pawn) //stop moving
	else
		able_to_run = TRUE
	set_ai_status(get_expected_ai_status(), run_flags)

///Returns TRUE if the ai controller can actually run at the moment, FALSE otherwise
/datum/ai_controller/proc/get_able_to_run()
	if(HAS_TRAIT(pawn, TRAIT_AI_PAUSED))
		return AI_UNABLE_TO_RUN
	if(world.time < paused_until)
		return AI_UNABLE_TO_RUN
	return NONE

///Can this pawn interact with objects?
/datum/ai_controller/proc/ai_can_interact()
	SHOULD_CALL_PARENT(TRUE)
	return !QDELETED(pawn)

///Interact with objects
/datum/ai_controller/proc/ai_interact(target, combat_mode, list/modifiers)
	if(!ai_can_interact())
		return FALSE

	var/atom/final_target = isdatum(target) ? target : blackboard[target] //incase we got a blackboard key instead

	if(QDELETED(final_target))
		return FALSE
	var/params = list2params(modifiers)
	var/mob/living/living_pawn = pawn
	if(isnull(combat_mode))
		living_pawn.ClickOn(final_target, params)
		return TRUE

	var/old_combat_mode = living_pawn.combat_mode
	living_pawn.set_combat_mode(combat_mode)
	living_pawn.ClickOn(final_target, params)
	living_pawn.set_combat_mode(old_combat_mode)
	return TRUE

///This is where you decide what actions are taken by the AI.
/datum/ai_controller/proc/SelectBehaviors(seconds_per_tick)
	SHOULD_NOT_SLEEP(TRUE)
	cancelled_during_tick = FALSE
	if(LAZYLEN(polling_observers))
		for(var/datum/bt_node/decorator/dec as anything in polling_observers.Copy())
			dec.poll_condition(src)
	for(var/datum/bt_node/node as anything in behavior_nodes)
		if(node.tick(src, seconds_per_tick) == BT_RUNNING)
			break

///This proc handles changing ai status and updates the planning subsystem list.
/datum/ai_controller/proc/set_ai_status(new_ai_status, additional_flags = NONE)
	if(ai_status == new_ai_status)
		return FALSE //no change

	//remove old status, if we've got one
	if(ai_status)
		GLOB.ai_controllers_by_status[ai_status] -= src
		for(var/datum/controller/subsystem/ai_controllers/controller_subsystem in Master.subsystems)
			if(controller_subsystem.planning_status == ai_status)
				controller_subsystem.currentrun -= src
				break
	ai_status = new_ai_status
	GLOB.ai_controllers_by_status[new_ai_status] += src
	if(ai_status == AI_STATUS_OFF)
		if(!(additional_flags & AI_PREVENT_CANCEL_ACTIONS))
			CancelActions()

/datum/ai_controller/proc/PauseAi(time)
	paused_until = world.time + time
	update_able_to_run()
	addtimer(CALLBACK(src, PROC_REF(update_able_to_run)), time)

/// DEPRECATED — modify_cooldown is kept for compile compat with legacy ai_target_tracking code.
/datum/ai_controller/proc/modify_cooldown(datum/ai_behavior/behavior, new_cooldown)
	behavior_cooldowns[behavior] = new_cooldown

/// DEPRECATED — queue_behavior is a no-op. Behaviors execute directly via BT tick().
/datum/ai_controller/proc/queue_behavior(behavior_type, ...)
	return

/// DEPRECATED — dequeue_behavior is a no-op. Behaviors finish via BT tick() returning BT_SUCCESS/FAILURE.
/datum/ai_controller/proc/dequeue_behavior(datum/ai_behavior/behavior)
	return

/datum/ai_controller/proc/CancelActions()
	active_execution_index = 0
	cancelled_during_tick = TRUE
	reset_bt_tick_states()

/// Turn the controller on or off based on if you're alive, we only register to this if the flag is present so don't need to check again
/datum/ai_controller/proc/on_stat_changed(mob/living/source, new_stat)
	SIGNAL_HANDLER
	reset_ai_status()
	update_able_to_run()

/datum/ai_controller/proc/on_sentience_gained()
	SIGNAL_HANDLER
	UnregisterSignal(pawn, COMSIG_MOB_LOGIN)
	if(!continue_processing_when_client)
		set_ai_status(AI_STATUS_OFF) //Can't do anything while player is connected
	RegisterSignal(pawn, COMSIG_MOB_LOGOUT, PROC_REF(on_sentience_lost))

/datum/ai_controller/proc/on_sentience_lost()
	SIGNAL_HANDLER
	UnregisterSignal(pawn, COMSIG_MOB_LOGOUT)
	set_ai_status(AI_STATUS_IDLE) //Can't do anything while player is connected
	RegisterSignal(pawn, COMSIG_MOB_LOGIN, PROC_REF(on_sentience_gained))

// Turn the controller off if the pawn has been qdeleted
/datum/ai_controller/proc/on_pawn_qdeleted()
	SIGNAL_HANDLER
	set_ai_status(AI_STATUS_OFF)
	set_movement_target(type, null)
	if(ai_movement.moving_controllers[src])
		ai_movement.stop_moving_towards(src)

/// Use this proc to define how your controller defines what access the pawn has for the sake of pathfinding. Return the access list you want to use
/datum/ai_controller/proc/get_access()
	if(!isliving(pawn))
		return
	var/mob/living/living_pawn = pawn
	return living_pawn.get_access()

/// Returns TRUE if the pawn can path to the target. minimum_distance is how close the path must get (0 = onto/adjacent to the target's turf); searches pass it from their own acquire_target leaf.
/datum/ai_controller/proc/can_reach_target(atom/target, distance = 10, minimum_distance = 0)
	if(!isdatum(target)) //we dont need to check if its not a datum!
		return TRUE
	if(get_turf(pawn) == get_turf(target))
		return TRUE
	var/list/path = get_path_to(pawn, target, simulated_only = !HAS_TRAIT(pawn, TRAIT_SPACEWALK), mintargetdist = minimum_distance, max_distance = distance, access = get_access())
	return (!!length(path))


/// Called when a target was found but couldn't be reached. Base no-op; override to record the target (e.g. add it to an ignore list).
/datum/ai_controller/proc/note_unreachable_target(atom/target)
	return

/// Returns true if we have a blackboard key with the provided key and it is not qdeleting
/datum/ai_controller/proc/blackboard_key_exists(key)
	var/datum/key_value = blackboard[key]
	if (isdatum(key_value))
		return !QDELETED(key_value)
	if (islist(key_value))
		return length(key_value) > 0
	return !!key_value

/**
 * Used to manage references to datum by AI controllers
 *
 * * tracked_datum - something being added to an ai blackboard
 * * key - the associated key
 */
#define TRACK_AI_DATUM_TARGET(tracked_datum, key) do { \
	if(isweakref(tracked_datum)) { \
		var/datum/weakref/_bad_weakref = tracked_datum; \
		stack_trace("Weakref (Actual datum: [_bad_weakref.resolve()]) found in ai datum blackboard! \
			This is an outdated method of ai reference handling, please remove it."); \
	}; \
	else if(isdatum(tracked_datum)) { \
		var/datum/_tracked_datum = tracked_datum; \
		if(QDELETED(_tracked_datum)) { \
			stack_trace("Tried to track a qdeleted datum ([_tracked_datum]) in ai datum blackboard (key: [key])! \
				Please ensure that we are not doing this by adding handling where necessary."); \
			return; \
		}; \
		else if(!HAS_TRAIT_FROM(_tracked_datum, TRAIT_AI_TRACKING, "[REF(src)]_[key]")) { \
			RegisterSignal(_tracked_datum, COMSIG_QDELETING, PROC_REF(sig_remove_from_blackboard), override = TRUE); \
			ADD_TRAIT(_tracked_datum, TRAIT_AI_TRACKING, "[REF(src)]_[key]"); \
		}; \
	}; \
} while(FALSE)

/**
 * Used to clear previously set reference handing by AI controllers
 *
 * * tracked_datum - something being removed from an ai blackboard
 * * key - the associated key
 */
#define CLEAR_AI_DATUM_TARGET(tracked_datum, key) do { \
	if(isdatum(tracked_datum)) { \
		var/datum/_tracked_datum = tracked_datum; \
		REMOVE_TRAIT(_tracked_datum, TRAIT_AI_TRACKING, "[REF(src)]_[key]"); \
		if(!HAS_TRAIT(_tracked_datum, TRAIT_AI_TRACKING)) { \
			UnregisterSignal(_tracked_datum, COMSIG_QDELETING); \
		}; \
	}; \
} while(FALSE)

/// Used for above to track all the keys that have registered a signal
#define TRAIT_AI_TRACKING "tracked_by_ai"

/**
 * Sets the key to the passed "thing".
 *
 * * key - A blackboard key
 * * thing - a value to set the blackboard key to.
 */
/datum/ai_controller/proc/set_blackboard_key(key, thing)
	// Assume it is an error when trying to set a value overtop a list
	if(islist(blackboard[key]))
		CRASH("set_blackboard_key attempting to set a blackboard value to key [key] when it's a list!")
	// Don't do anything if it's already got this value
	if (blackboard[key] == thing)
		return

	// Clear existing values
	if(!isnull(blackboard[key]))
		clear_blackboard_key(key)

	TRACK_AI_DATUM_TARGET(thing, key)
	blackboard[key] = thing
	post_blackboard_key_set(key)

/**
 * Helper to force a key to be a certain thing no matter what's already there
 *
 * Useful for if you're overriding a list with a new list entirely,
 * as otherwise it would throw a runtime error from trying to override a list
 *
 * Not necessary to use if you aren't dealing with lists, as set_blackboard_key will clear the existing value
 * in that case already, but may be useful for clarity.
 *
 * * key - A blackboard key
 * * thing - a value to set the blackboard key to.
 */
/datum/ai_controller/proc/override_blackboard_key(key, thing)
	if(blackboard[key] == thing)
		return

	clear_blackboard_key(key)
	set_blackboard_key(key, thing)

/**
 * Sets the key at index thing to the passed value
 *
 * Assumes the key value is already a list, if not throws an error.
 *
 * * key - A blackboard key, with its value set to a list
 * * thing - a value which becomes the inner list value's key
 * * value - what to set the inner list's value to
 */
/datum/ai_controller/proc/set_blackboard_key_assoc(key, thing, value)
	if(!islist(blackboard[key]))
		CRASH("set_blackboard_key_assoc called on non-list key [key]!")
	// Don't do anything if it's already got this value
	if (blackboard[key][thing] == value)
		return

	TRACK_AI_DATUM_TARGET(thing, key)
	TRACK_AI_DATUM_TARGET(value, key)
	blackboard[key][thing] = value
	post_blackboard_key_set(key)

/**
 * Similar to [proc/set_blackboard_key_assoc] but operates under the assumption the key is a lazylist (so it will create a list)
 * More dangerous / easier to override values, only use when you want to use a lazylist
 *
 * * key - A blackboard key, with its value set to a list
 * * thing - a value which becomes the inner list value's key
 * * value - what to set the inner list's value to
 */
/datum/ai_controller/proc/set_blackboard_key_assoc_lazylist(key, thing, value)
	LAZYINITLIST(blackboard[key])
	// Don't do anything if it's already got this value
	if (blackboard[key][thing] == value)
		return

	TRACK_AI_DATUM_TARGET(thing, key)
	TRACK_AI_DATUM_TARGET(value, key)
	blackboard[key][thing] = value
	post_blackboard_key_set(key)

/**
 * Called after we set a blackboard key, forwards signal information.
 */
/datum/ai_controller/proc/post_blackboard_key_set(key)
	if (isnull(pawn))
		return
	SEND_SIGNAL(pawn, COMSIG_AI_BLACKBOARD_KEY_SET(key), key)

/**
 * Adds the passed "thing" to the associated key
 *
 * Works with lists or numbers, but not lazylists.
 *
 * * key - A blackboard key
 * * thing - a value to set the blackboard key to.
 */
/datum/ai_controller/proc/add_blackboard_key(key, thing)
	TRACK_AI_DATUM_TARGET(thing, key)
	blackboard[key] += thing

/**
 * Similar to [proc/add_blackboard_key], but performs an insertion rather than an add
 * Throws an error if the key is not a list already, intended only for use with lists
 *
 * * key - A blackboard key, with its value set to a list
 * * thing - a value to set the blackboard key to.
 */
/datum/ai_controller/proc/insert_blackboard_key(key, thing)
	if(!islist(blackboard[key]))
		CRASH("insert_blackboard_key called on non-list key [key]!")
	TRACK_AI_DATUM_TARGET(thing, key)
	blackboard[key] |= thing

/**
 * Adds the passed "thing" to the associated key, assuming key is intended to be a lazylist (so it will create a list)
 * More dangerous / easier to override values, only use when you want to use a lazylist
 *
 * * key - A blackboard key
 * * thing - a value to set the blackboard key to.
 */
/datum/ai_controller/proc/add_blackboard_key_lazylist(key, thing)
	LAZYINITLIST(blackboard[key])
	TRACK_AI_DATUM_TARGET(thing, key)
	blackboard[key] += thing

/**
 * Similar to [proc/insert_blackboard_key_lazylist], but performs an insertion / or rather than an add
 *
 * * key - A blackboard key
 * * thing - a value to set the blackboard key to.
 */
/datum/ai_controller/proc/insert_blackboard_key_lazylist(key, thing)
	LAZYINITLIST(blackboard[key])
	TRACK_AI_DATUM_TARGET(thing, key)
	blackboard[key] |= thing
	post_blackboard_key_set(key)

/**
 * Adds the value to the inner list at key with the inner key set to "thing"
 * Throws an error if the key is not a list already, intended only for use with lists
 *
 * * key - A blackboard key, with its value set to a list
 * * thing - a value which becomes the inner list value's key
 * * value - what to set the inner list's value to
 */
/datum/ai_controller/proc/add_blackboard_key_assoc(key, thing, value)
	if(!islist(blackboard[key]))
		CRASH("add_blackboard_key_assoc called on non-list key [key]!")
	TRACK_AI_DATUM_TARGET(thing, key)
	TRACK_AI_DATUM_TARGET(value, key)
	blackboard[key][thing] += value


/**
 * Similar to [proc/add_blackboard_key_assoc], assuming key is intended to be a lazylist (so it will create a list)
 * More dangerous / easier to override values, only use when you want to use a lazylist
 *
 * * key - A blackboard key, with its value set to a list
 * * thing - a value which becomes the inner list value's key
 * * value - what to set the inner list's value to
 */
/datum/ai_controller/proc/add_blackboard_key_assoc_lazylist(key, thing, value)
	LAZYINITLIST(blackboard[key])
	TRACK_AI_DATUM_TARGET(thing, key)
	TRACK_AI_DATUM_TARGET(value, key)
	blackboard[key][thing] += value

/**
 * Clears the passed key, resetting it to null
 *
 * Not intended for use with list keys - use [proc/remove_thing_from_blackboard_key] if you are removing a value from a list at a key
 *
 * * key - A blackboard key
 */
/datum/ai_controller/proc/clear_blackboard_key(key)
	if(isnull(blackboard[key]))
		return
	if(pawn && (SEND_SIGNAL(pawn, COMSIG_AI_BLACKBOARD_KEY_PRECLEAR(key))))
		return
	CLEAR_AI_DATUM_TARGET(blackboard[key], key)
	blackboard[key] = null
	if(isnull(pawn))
		return
	SEND_SIGNAL(pawn, COMSIG_AI_BLACKBOARD_KEY_CLEARED(key), key)

/**
 * Remove the passed thing from the associated blackboard key
 *
 * Intended for use with lists, if you're just clearing a reference from a key use [proc/clear_blackboard_key]
 *
 * * key - A blackboard key
 * * thing - a value to set the blackboard key to.
 */
/datum/ai_controller/proc/remove_thing_from_blackboard_key(key, thing)
	var/associated_value = blackboard[key]
	if(isnull(associated_value))
		return
	if(thing == associated_value)
		stack_trace("remove_thing_from_blackboard_key was called un-necessarily in a situation where clear_blackboard_key would suffice. ")
		clear_blackboard_key(key)
		return

	if(!islist(associated_value))
		CRASH("remove_thing_from_blackboard_key called with an invalid \"thing\" argument ([thing]). \
			(The associated value of the passed key is not a list and is also not the passed thing, meaning it is clearing an unintended value.)")

	for(var/inner_key in associated_value)
		if(inner_key == thing)
			// flat list
			CLEAR_AI_DATUM_TARGET(thing, key)
			associated_value -= thing
			return
		else if(associated_value[inner_key] == thing)
			// assoc list
			CLEAR_AI_DATUM_TARGET(thing, key)
			associated_value -= inner_key
			return

	CRASH("remove_thing_from_blackboard_key called with an invalid \"thing\" argument ([thing]). \
		(The passed value is not tracked in the passed list.)")

///removes a tracked object from a lazylist
/datum/ai_controller/proc/remove_from_blackboard_lazylist_key(key, thing)
	var/lazylist = blackboard[key]
	if(isnull(lazylist))
		return
	for(var/key_index in lazylist)
		if(thing == key_index || lazylist[key_index] == thing)
			CLEAR_AI_DATUM_TARGET(thing, key)
			lazylist -= key_index
			break
	if(!LAZYLEN(lazylist))
		clear_blackboard_key(key)

/// Signal proc to go through every key and remove the datum from all keys it finds
/datum/ai_controller/proc/sig_remove_from_blackboard(datum/source)
	SIGNAL_HANDLER

	var/list/list/remove_queue = list(blackboard)
	var/index = 1
	while(index <= length(remove_queue))
		var/list/next_to_clear = remove_queue[index]
		for(var/inner_value in next_to_clear)
			var/associated_value = next_to_clear[inner_value]
			// We are a lists of lists, add the next value to the queue so we can handle references in there
			// (But we only need to bother checking the list if it's not empty.)
			if(islist(inner_value) && length(inner_value))
				UNTYPED_LIST_ADD(remove_queue, inner_value)

			// We found the value that's been deleted. Clear it out from this list
			else if(inner_value == source)
				next_to_clear -= inner_value

			// We are an assoc lists of lists, the list at the next value so we can handle references in there
			// (But again, we only need to bother checking the list if it's not empty.)
			if(islist(associated_value) && length(associated_value))
				UNTYPED_LIST_ADD(remove_queue, associated_value)

			// We found the value that's been deleted, it was an assoc value. Clear it out entirely
			else if(associated_value == source)
				next_to_clear -= inner_value
				SEND_SIGNAL(pawn, COMSIG_AI_BLACKBOARD_KEY_CLEARED(inner_value))

		index += 1

/// When the pawn gets DF_EVLOGGING, propagate it to this controller too.
/datum/ai_controller/proc/on_pawn_evlogging_enabled(datum/source)
	SIGNAL_HANDLER
	enable_evlogging(pawn)

/// When the pawn gets DF_EVLOGGING disabled, propagate it to this controller too.
/datum/ai_controller/proc/on_pawn_evlogging_disabled(datum/source)
	SIGNAL_HANDLER
	disable_evlogging(pawn)

///Register for an event being added so we can update track info
/datum/ai_controller/enable_evlogging()
	. = ..()
	RegisterSignal(src, COMSIG_EVLOG_EVENT_ADDED, PROC_REF(on_evlog_event_added))

///Unregister the evlog event added event, as we're no longer updating track info
/datum/ai_controller/disable_evlogging()
	. = ..()
	UnregisterSignal(src, COMSIG_EVLOG_EVENT_ADDED)


/// Called whenever an event is logged for this controller. Attaches a snapshot of current behaviors and blackboard state to the event via track_info.
/datum/ai_controller/proc/on_evlog_event_added(datum/source, datum/event_logger_track/track, list/event_data)
	SIGNAL_HANDLER
	var/list/track_info = list()

	// Build full tree state view showing all nodes with status markers
	var/list/tree_lines = list()
	for(var/datum/bt_node/root_node as anything in behavior_nodes)
		root_node.append_full_tree_state(tree_lines, "")
	EVLOG_TRACK_INFO_ENTRY(track_info, "Behaviors", "Full Tree State", length(tree_lines) ? jointext(tree_lines, "\n") : "(none)")

	// Add execution context section
	var/active_node_label = "(none)"
	if(active_execution_index)
		for(var/datum/bt_node/root_node as anything in behavior_nodes)
			var/datum/bt_node/found = root_node.find_by_index(active_execution_index)
			if(found)
				active_node_label = found.get_label()
				break
	EVLOG_TRACK_INFO_ENTRY(track_info, "Execution Context", "Active Execution Index", "[active_execution_index] ([active_node_label])")
	EVLOG_TRACK_INFO_ENTRY(track_info, "Execution Context", "AI Status", ai_status == AI_STATUS_ON ? "ON" : (ai_status == AI_STATUS_IDLE ? "IDLE" : "OFF"))
	EVLOG_TRACK_INFO_ENTRY(track_info, "Execution Context", "Able to Run", able_to_run ? "TRUE" : "FALSE")

	// Blackboard snapshot
	for(var/blackboard_key_name, blackboard_value in blackboard)
		var/value_string
		if(isatom(blackboard_value))
			value_string = "[blackboard_value]"
		else if(islist(blackboard_value))
			var/list/blackboard_list = blackboard_value
			value_string = length(blackboard_list) ? jointext(blackboard_list, "\n") : "Empty List"
		else if(isnull(blackboard_value))
			value_string = "null"
		else // I think I covered all cases?
			value_string = "[blackboard_value]"
		EVLOG_TRACK_INFO_ENTRY(track_info, "Blackboard", blackboard_key_name, value_string)

	event_data["track_info"] = track_info


#undef TRACK_AI_DATUM_TARGET
#undef CLEAR_AI_DATUM_TARGET
#undef TRAIT_AI_TRACKING
