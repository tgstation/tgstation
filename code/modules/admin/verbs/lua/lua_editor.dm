/datum/lua_editor
	var/datum/lua_state/current_state

	/// Arguments for a function call or coroutine resume
	var/list/arguments = list()

	/// If not set, the global table will not be shown in the lua editor
	var/show_global_table = FALSE

	/// The log page we are currently on
	var/page = 0

	/// If set, we will force the editor's modal to be this
	var/force_modal

	/// If set, we will force the editor to look at this chunk
	var/force_view_chunk

/datum/lua_editor/New(state, _quick_log_index)
	. = ..()
	if(state)
		current_state = state
		LAZYADDASSOCLIST(SSlua.editors, text_ref(current_state), src)

/datum/lua_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LuaEditor", "Lua")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/lua_editor/Destroy(force, ...)
	. = ..()
	if(current_state)
		LAZYREMOVEASSOC(SSlua.editors, text_ref(current_state), src)

/datum/lua_editor/ui_state(mob/user)
	return GLOB.debug_state

/datum/lua_editor/ui_static_data(mob/user)
	var/list/data = list()
	data["documentation"] = file2text('code/modules/admin/verbs/lua/README.md')
	return data

/datum/lua_editor/ui_data(mob/user)
	var/list/data = list()
	data["noStateYet"] = !current_state
	data["showGlobalTable"] = show_global_table
	if(current_state)
		if(current_state.log)
			data["stateLog"] = kvpify_list(refify_list(current_state.log.Copy((page*50)+1, min((page+1)*50+1, current_state.log.len+1))))
		data["page"] = page
		data["pageCount"] = CEILING(current_state.log.len/50, 1)
		data["tasks"] = current_state.get_tasks()
		if(show_global_table)
			current_state.get_globals()
			data["globals"] = kvpify_list(refify_list(current_state.globals))
	data["states"] = SSlua.states
	data["callArguments"] = kvpify_list(refify_list(arguments))
	if(force_modal)
		data["forceModal"] = force_modal
		force_modal = null
	if(force_view_chunk)
		data["forceViewChunk"] = force_view_chunk
		force_view_chunk = null
	return data

/datum/lua_editor/proc/traverse_list(list/path, list/root, traversal_depth_offset = 0)
	var/top_affected_list_depth = LAZYLEN(path)-traversal_depth_offset // The depth of the element to get
	if(top_affected_list_depth)
		var/list/current_list = root
		// We kvpify the list to the depth of the element to get - this allows us to reach list elements contained within a assoc list's key
		var/list/path_list = kvpify_list(current_list, top_affected_list_depth-1)
		while(LAZYLEN(path) > traversal_depth_offset)
			// Navigate to the index of the next path element within the current path element
			var/list/path_element = popleft(path)
			var/list/list_element = path_list[path_element["index"]]

			// Enter the next path element - be it the key or the value
			switch(path_element["type"])
				if("key")
					path_list = list_element["key"]
				if("value")
					path_list = list_element["value"]
				else
					to_chat(usr, span_warning("invalid path element type \[[path_element["type"]]] for list traversal (expected \"key\" or \"value\""))
					return
			// The element we are entering SHOULD be a list, unless we're at the end of the path
			if(!islist(path_list) && LAZYLEN(path))
				to_chat(usr, span_warning("invalid path element \[[path_list]] for list traversal (expected a list)"))
				return
			current_list = path_list
		return current_list
	else
		return root

/datum/lua_editor/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!check_rights_for(usr.client, R_DEBUG))
		return
	switch(action)
		if("newState")
			var/state_name = params["name"]
			if(!length(state_name))
				return TRUE
			var/datum/lua_state/new_state = new(state_name)
			SSlua.states += new_state
			LAZYREMOVEASSOC(SSlua.editors, text_ref(current_state), src)
			current_state = new_state
			LAZYADDASSOCLIST(SSlua.editors, text_ref(current_state), src)
			page = 0
			return TRUE
		if("switchState")
			var/state_index = params["index"]
			LAZYREMOVEASSOC(SSlua.editors, text_ref(current_state), src)
			current_state = SSlua.states[state_index]
			LAZYADDASSOCLIST(SSlua.editors, text_ref(current_state), src)
			page = 0
			return TRUE
		if("runCode")
			var/code = params["code"]
			var/result = current_state.load_script(code)
			var/index_with_result = current_state.log_result(result)
			message_admins("[key_name(usr)] executed [length(code)] bytes of lua code. [ADMIN_LUAVIEW_CHUNK(current_state, index_with_result)]")
			return TRUE
		if("moveArgUp")
			var/list/path = params["path"]
			var/list/target_list = traverse_list(path, arguments, traversal_depth_offset = 1)
			var/index = popleft(path)["index"]
			target_list.Swap(index-1, index)
			return TRUE
		if("moveArgDown")
			var/list/path = params["path"]
			var/list/target_list = traverse_list(path, arguments, traversal_depth_offset = 1)
			var/index = popleft(path)["index"]
			target_list.Swap(index, index+1)
			return TRUE
		if("removeArg")
			var/list/path = params["path"]
			var/list/target_list = traverse_list(path, arguments, traversal_depth_offset = 1)
			var/index = popleft(path)["index"]
			target_list.Cut(index, index+1)
			return TRUE
		if("addArg")
			var/list/path = params["path"]
			var/list/target_list = traverse_list(path, arguments)
			if(target_list != arguments)
				usr?.client?.mod_list_add(target_list, null, "a lua editor", "arguments")
			else
				var/list/vv_val = usr?.client?.vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
				var/class = vv_val["class"]
				if(!class)
					return
				LAZYADD(arguments, list(vv_val["value"]))
			return TRUE
		if("callFunction")
			var/list/recursive_indices = params["indices"]
			var/list/current_list = kvpify_list(current_state.globals)
			var/function = list()
			while(LAZYLEN(recursive_indices))
				var/index = popleft(recursive_indices)
				var/list/element = current_list[index]
				var/key = element["key"]
				var/value = element["value"]
				if(!(istext(key) || isnum(key)))
					to_chat(usr, span_warning("invalid key \[[key]] for function call (expected text or num)"))
					return
				function += key
				if(islist(value))
					current_list = value
				else
					var/regex/function_regex = regex("^function: 0x\[0-9a-fA-F]+$")
					if(function_regex.Find(value))
						break
					to_chat(usr, span_warning("invalid path element \[[value]] for function call (expected list or text matching [function_regex])"))
					return
			var/result = current_state.call_function(arglist(list(function) + arguments))
			current_state.log_result(result)
			arguments.Cut()
			return TRUE
		if("resumeTask")
			var/task_index = params["index"]
			SSlua.queue_resume(current_state, task_index, arguments)
			arguments.Cut()
			return TRUE
		if("killTask")
			var/task_info = params["info"]
			SSlua.kill_task(current_state, task_info)
			return TRUE
		if("vvReturnValue")
			var/log_entry_index = params["entryIndex"]
			var/list/log_entry = current_state.log[log_entry_index]
			var/thing_to_debug = traverse_list(params["tableIndices"], log_entry["param"])
			if(isweakref(thing_to_debug))
				var/datum/weakref/ref = thing_to_debug
				thing_to_debug = ref.resolve()
			INVOKE_ASYNC( \
				SSadmin_verbs, \
				TYPE_PROC_REF(/datum/controller/subsystem/admin_verbs, dynamic_invoke_admin_verb), \
				usr.client, \
				/mob/admin_module_holder/debug/view_variables, \
				list(thing_to_debug), \
				)
			return FALSE
		if("vvGlobal")
			var/thing_to_debug = traverse_list(params["indices"], current_state.globals)
			if(isweakref(thing_to_debug))
				var/datum/weakref/ref = thing_to_debug
				thing_to_debug = ref.resolve()
			INVOKE_ASYNC( \
				SSadmin_verbs, \
				TYPE_PROC_REF(/datum/controller/subsystem/admin_verbs, dynamic_invoke_admin_verb), \
				usr.client, \
				/mob/admin_module_holder/debug/view_variables, \
				list(thing_to_debug), \
				)
			return FALSE
		if("clearArgs")
			arguments.Cut()
			return TRUE
		if("toggleShowGlobalTable")
			show_global_table = !show_global_table
			return TRUE
		if("nextPage")
			page = min(page+1, CEILING(current_state.log.len/50, 1)-1)
			return TRUE
		if("previousPage")
			page = max(page-1, 0)
			return TRUE

/datum/lua_editor/ui_close(mob/user)
	. = ..()
	qdel(src)

ADMIN_VERB(debug, open_lua_editor, "", R_DEBUG)
	if(SSlua.initialized != TRUE)
		to_chat(usr, span_warning("SSlua is not initialized!"))
		return
	var/datum/lua_editor/editor = new()
	editor.ui_interact(usr)
