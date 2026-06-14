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

/datum/bt_viewer/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/simple/plane_background))

/datum/bt_viewer/ui_data(mob/user)
	var/list/data = list()
	data["mob_name"] = viewing_mob ? viewing_mob.name : null
	data["controller_type"] = viewing_controller ? "[viewing_controller.type]" : null
	data["active_execution_index"] = viewing_controller ? viewing_controller.active_execution_index : 0
	if(viewing_controller?.bt_execution_log != null)
		data["fired_indices"] = viewing_controller.bt_execution_log.Copy()
		viewing_controller.bt_execution_log.Cut() //Clear the list every time we update
	else
		data["fired_indices"] = list()
	data["awaiting_pick"] = awaiting_pick
	if(viewing_controller)
		var/list/root_indices = list()
		var/list/node_list = list()
		collect_nodes(root_indices, node_list)
		data["roots"] = root_indices
		data["nodes"] = node_list
		var/list/bb_entries = list()
		var/list/bb = viewing_controller.blackboard
		for(var/key in bb)
			var/value = bb[key]
			var/str_val
			if(isnull(value))
				str_val = "null"
			else if(islist(value))
				str_val = "list([length(value)])"
			else
				str_val = "[value]"
			bb_entries += list(list("key" = key, "value" = str_val))
		data["blackboard"] = bb_entries
	else
		data["roots"] = list()
		data["nodes"] = list()
		data["blackboard"] = list()
	return data

/datum/bt_viewer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	var/mob/user = ui.user
	switch(action)
		if("pick_target")
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

	var/atom/target = clicked
	if(!target.ai_controller)
		return NONE
	set_target(target)
	return NONE

/datum/bt_viewer/proc/set_target(mob/target)
	_clear_target()
	viewing_mob = target
	viewing_controller = target.ai_controller
	viewing_controller.bt_execution_log = list()
	RegisterSignal(viewing_mob, COMSIG_PREQDELETED, PROC_REF(on_mob_deleted))

/datum/bt_viewer/proc/on_mob_deleted(datum/source)
	SIGNAL_HANDLER
	_clear_target()

/datum/bt_viewer/proc/_clear_target()
	if(viewing_mob)
		UnregisterSignal(viewing_mob, COMSIG_PREQDELETED)
	if(viewing_controller)
		viewing_controller.bt_execution_log = null
	viewing_mob = null
	viewing_controller = null

/datum/bt_viewer/proc/_end_pick()
	awaiting_pick = FALSE
	if(awaiting_pick_user)
		UnregisterSignal(awaiting_pick_user, COMSIG_MOB_CLICKON)
		awaiting_pick_user = null

/datum/bt_viewer/proc/collect_nodes(list/root_indices, list/node_list)
	var/priority = 1
	for(var/datum/bt_node/root as anything in viewing_controller.behavior_nodes)
		root_indices += root.execution_index
		_collect_node(root, node_list, priority++)

// Recursively adds node and all descendants to node_list as flat entries.
// Each entry has exec_index as its unique key, with children as a flat list of child exec_indices.
/datum/bt_viewer/proc/_collect_node(datum/bt_node/node, list/node_list, priority_index)
	var/exec = node.execution_index || 0
	var/last = node.last_execution_index || 0

	var/list/node_data = list(
		"exec_index" = exec,
		"label" = node.get_label(),
		"node_type" = node.node_type,
		"priority" = priority_index,
	)
	if(last != exec)
		node_data["last_exec_index"] = last

	if(node.node_type == BT_NODE_DECORATOR)
		var/datum/bt_node/decorator/dec = node
		if(dec.observer_abort)
			node_data["observer_abort"] = dec.observer_abort
		if(dec.invert)
			node_data["invert"] = TRUE

	var/list/children = node.get_children()
	if(length(children))
		var/list/child_indices = list()
		for(var/i in 1 to length(children))
			var/datum/bt_node/child = children[i]
			if(!child)
				continue
			child_indices += child.execution_index
			_collect_node(child, node_list, i)
		node_data["children"] = child_indices

	node_list += list(node_data)
