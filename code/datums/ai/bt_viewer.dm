GLOBAL_DATUM_INIT(bt_viewer, /datum/bt_viewer, new())

/datum/bt_viewer
	/// The controller currently being viewed.
	var/datum/ai_controller/viewing_controller = null
	/// The mob owning the controller.
	var/mob/viewing_mob = null
	/// TRUE while waiting for admin to click a mob.
	var/awaiting_pick = FALSE
	/// The admin waiting to pick, used to unregister the click signal.
	var/mob/awaiting_pick_user = null

/datum/bt_viewer/Destroy()
	_clear_target()
	_end_pick()
	return ..()

/datum/bt_viewer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BehaviorTreeViewer", "Behavior Tree Viewer")
		ui.open()

/datum/bt_viewer/ui_close(mob/user)
	. = ..()
	if(awaiting_pick_user == user)
		_end_pick()

/datum/bt_viewer/ui_state(mob/user)
	return ADMIN_STATE(R_DEBUG)

/datum/bt_viewer/ui_data(mob/user)
	var/list/data = list()
	data["mob_name"] = viewing_mob ? viewing_mob.name : null
	data["controller_type"] = viewing_controller ? "[viewing_controller.type]" : null
	data["active_execution_index"] = viewing_controller ? viewing_controller.active_execution_index : 0
	data["awaiting_pick"] = awaiting_pick
	data["roots"] = viewing_controller ? serialize_roots() : list()
	return data

/datum/bt_viewer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	switch(action)
		if("pick_mob")
			_end_pick()
			awaiting_pick = TRUE
			awaiting_pick_user = user
			RegisterSignal(user, COMSIG_MOB_CLICKON, PROC_REF(on_pick_click))
			return TRUE
		if("clear")
			_clear_target()
			return TRUE

/datum/bt_viewer/proc/on_pick_click(mob/source, atom/clicked, list/modifiers)
	SIGNAL_HANDLER
	_end_pick()
	if(!ismob(clicked))
		return NONE
	var/mob/target = clicked
	if(!target.ai_controller)
		return NONE
	set_target(target)
	return NONE

/datum/bt_viewer/proc/set_target(mob/target)
	_clear_target()
	viewing_mob = target
	viewing_controller = target.ai_controller
	RegisterSignal(viewing_mob, COMSIG_PREQDELETED, PROC_REF(on_mob_deleted))
	if(viewing_controller)
		viewing_controller.ensure_execution_index_cache()

/datum/bt_viewer/proc/on_mob_deleted(datum/source)
	SIGNAL_HANDLER
	_clear_target()

/datum/bt_viewer/proc/_clear_target()
	if(viewing_mob)
		UnregisterSignal(viewing_mob, COMSIG_PREQDELETED)
	viewing_mob = null
	viewing_controller = null

/datum/bt_viewer/proc/_end_pick()
	awaiting_pick = FALSE
	if(awaiting_pick_user)
		UnregisterSignal(awaiting_pick_user, COMSIG_MOB_CLICKON)
		awaiting_pick_user = null

/datum/bt_viewer/proc/serialize_roots()
	var/list/result = list()
	for(var/datum/bt_node/root in viewing_controller.behavior_nodes)
		result += list(serialize_node(root, 1))
	return result

/datum/bt_viewer/proc/serialize_node(datum/bt_node/node, priority_index)
	var/list/exec_cache = GLOB.bt_execution_indices[viewing_controller.type]
	var/list/last_cache = GLOB.bt_last_execution_indices[viewing_controller.type]

	// Node type as integer: 0=selector 1=sequence 2=parallel 3=decorator 4=leaf 5=subtree
	var/node_type
	if(istype(node, /datum/bt_node/composite/selector))
		node_type = 0
	else if(istype(node, /datum/bt_node/composite/sequence))
		node_type = 1
	else if(istype(node, /datum/bt_node/composite/parallel))
		node_type = 2
	else if(istype(node, /datum/bt_node/decorator))
		node_type = 3
	else if(istype(node, /datum/bt_node/subtree))
		node_type = 5
	else
		node_type = 4

	// Nodes inside subtrees may not be in the top-level cache — treat missing as 0.
	var/exec = exec_cache ? exec_cache[node] : 0
	var/last = last_cache ? last_cache[node] : 0
	if(!exec)
		exec = 0
	if(!last)
		last = 0

	var/list/node_data = list(
		"l" = viewing_controller.bt_node_label(node),
		"t" = node_type,
		"p" = priority_index,
		"e" = exec,
	)
	if(last != exec)
		node_data["z"] = last

	if(istype(node, /datum/bt_node/decorator))
		var/datum/bt_node/decorator/dec = node
		if(dec.observer_abort)
			node_data["a"] = dec.observer_abort
		if(length(dec.observed_keys))
			node_data["k"] = dec.observed_keys
		if(dec.invert)
			node_data["i"] = TRUE
		if(dec.child)
			var/list/child_data = serialize_node(dec.child, 1)
			if(child_data)
				node_data["c"] = list(child_data)

	else if(istype(node, /datum/bt_node/composite))
		var/datum/bt_node/composite/comp = node
		if(length(comp.children))
			var/list/children_data = list()
			for(var/i in 1 to length(comp.children))
				var/datum/bt_node/child = comp.children[i]
				if(!child)
					continue
				var/list/child_data = serialize_node(child, i)
				if(child_data)
					children_data += list(child_data)
			if(length(children_data))
				node_data["c"] = children_data

	else if(istype(node, /datum/bt_node/subtree))
		var/datum/bt_node/subtree/sub = node
		if(sub.root)
			var/list/child_data = serialize_node(sub.root, 1)
			if(child_data)
				node_data["c"] = list(child_data)

	return node_data
