/datum/lua_editor
	var/datum/lua_state/current_state

	/// Code imported from the user's system
	var/imported_code

	/// Arguments for a function call or coroutine resume
	var/list/arguments = list()

/datum/lua_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LuaEditor", "Lua")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/lua_editor/Destroy(force, ...)
	. = ..()
	if(current_state)
		LAZYREMOVEASSOC(SSlua.editors, "\ref[current_state]", src)

/datum/lua_editor/ui_state(mob/user)
	return GLOB.debug_state

/datum/lua_editor/proc/refify_list(list/L)
	. = list()
	for(var/i in 1 to L.len)
		var/key = L[i]
		var/new_key = key
		if(isdatum(key) || isworld(key))
			new_key = "[key] [REF(key)]"
		else if(islist(key))
			new_key = refify_list(key)
		var/value
		if(istext(key) || islist(key) || isdatum(key) || isworld(key))
			value = L[key]
		if(isdatum(value) || isworld(key))
			value = "[value] [REF(value)]"
		else if(islist(value))
			value = refify_list(value)
		var/list/to_add = list(new_key)
		if(value)
			to_add[new_key] = value
		. += to_add

/**
 * Converts a list into a list of assoc lists of the form ("key" = key, "value" = value)
 * so that list keys that are themselves lists can be fully json-encoded
 */
/datum/lua_editor/proc/kvpify_list(list/L, depth = INFINITY)
	. = list()
	for(var/i in 1 to L.len)
		var/key = L[i]
		var/new_key = key
		if(islist(key) && depth)
			new_key = kvpify_list(key, depth-1)
		var/value
		if(istext(key) || islist(key) || isdatum(key) || isworld(key))
			value = L[key]
		if(islist(value) && depth)
			value = kvpify_list(value, depth-1)
		if(value)
			. += list(list("key" = new_key, "value" = value))
		else
			. += list(list("key" = i, "value" = key))

/datum/lua_editor/proc/dekvpify_list(list/L)
	. = list()
	for(var/i in 1 to L.len)
		var/pair = L[i]
		var/key = pair["key"]
		var/value = pair["value"]
		var/list/to_add = list(key)
		to_add[key] = value
		. += to_add

/datum/lua_editor/proc/add_argument(list/target_list)
	usr.client.mod_list_add(target_list, null, "a lua editor", "arguments")
	SStgui.update_uis(src)

/datum/lua_editor/ui_static_data(mob/user)
	var/list/data = list()
	data["documentation"] = parsemarkdown_basic(file2text("code/modules/admin/verbs/lua/README.md"))
	return data

/datum/lua_editor/ui_data(mob/user)
	var/list/data = list()
	data["noStateYet"] = !current_state
	if(current_state)
		current_state.get_globals()
		if(current_state.log)
			data["stateLog"] = kvpify_list(refify_list(current_state.log))
		data["tasks"] = current_state.get_tasks()
		if(current_state.globals)
			data["globals"] = kvpify_list(refify_list(current_state.globals))
	if(imported_code)
		data["importedCode"] = imported_code
		imported_code = null
	data["states"] = SSlua.states
	data["callArguments"] = kvpify_list(refify_list(arguments))
	return data

/datum/lua_editor/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!check_rights_for(usr.client, R_DEBUG))
		return
	switch(action)
		if("newState")
			var/state_name = params["name"]
			var/datum/lua_state/new_state = new(state_name)
			SSlua.states += new_state
			LAZYREMOVEASSOC(SSlua.editors, "\ref[current_state]", src)
			current_state = new_state
			LAZYADDASSOCLIST(SSlua.editors, "\ref[current_state]", src)
			return TRUE
		if("switchState")
			var/state_index = params["index"]
			LAZYREMOVEASSOC(SSlua.editors, "\ref[current_state]", src)
			current_state = SSlua.states[state_index]
			LAZYADDASSOCLIST(SSlua.editors, "\ref[current_state]", src)
			return TRUE
		if("runCode")
			var/code = params["code"]
			current_state.load_script(code)
			return TRUE
		if("moveArgUp")
			var/list/recursive_indices = params["path"]
			var/top_affected_list_depth = LAZYLEN(recursive_indices)-1
			var/list/target_list
			if(top_affected_list_depth)
				var/list/path_list = kvpify_list(arguments, top_affected_list_depth)
				while(LAZYLEN(recursive_indices) > 1)
					var/list/path_element = popleft(recursive_indices)
					var/list/list_element = path_list[path_element["index"]]
					switch(path_element["type"])
						if("key")
							path_list = list_element["key"]
						if("value")
							path_list = list_element["value"]
						else
							to_chat(usr, span_warning("invalid path element type \[[path_element["type"]]] for argument move (expected \"key\" or \"value\""))
							return
					if(!islist(path_list))
						to_chat(usr, span_warning("invalid path element \[[path_list]] for argument move (expected a list)"))
						return
			else
				target_list = arguments
			var/index = popleft(recursive_indices)["index"]
			target_list.Swap(index-1, index)
			return TRUE
		if("moveArgDown")
			var/list/recursive_indices = params["path"]
			var/top_affected_list_depth = LAZYLEN(recursive_indices)-1
			var/list/target_list
			if(top_affected_list_depth)
				var/list/path_list = kvpify_list(arguments, top_affected_list_depth)
				while(LAZYLEN(recursive_indices) > 1)
					var/list/path_element = popleft(recursive_indices)
					var/list/list_element = path_list[path_element["index"]]
					switch(path_element["type"])
						if("key")
							path_list = list_element["key"]
						if("value")
							path_list = list_element["value"]
						else
							to_chat(usr, span_warning("invalid path element type \[[path_element["type"]]] for argument move (expected \"key\" or \"value\""))
							return
					if(!islist(path_list))
						to_chat(usr, span_warning("invalid path element \[[path_list]] for argument move (expected a list)"))
						return
			else
				target_list = arguments
			var/index = popleft(recursive_indices)["index"]
			target_list.Swap(index, index+1)
			return TRUE
		if("removeArg")
			var/list/recursive_indices = params["path"]
			var/top_affected_list_depth = LAZYLEN(recursive_indices)-1
			var/list/target_list
			if(top_affected_list_depth)
				var/list/path_list = kvpify_list(arguments, top_affected_list_depth)
				while(LAZYLEN(recursive_indices) > 1)
					var/list/path_element = popleft(recursive_indices)
					var/list/list_element = path_list[path_element["index"]]
					switch(path_element["type"])
						if("key")
							path_list = list_element["key"]
						if("value")
							path_list = list_element["value"]
						else
							to_chat(usr, span_warning("invalid path element type \[[path_element["type"]]] for argument removal (expected \"key\" or \"value\""))
							return
					if(!islist(path_list))
						to_chat(usr, span_warning("invalid path element \[[path_list]] for argument removal (expected a list)"))
						return
			else
				target_list = arguments
			var/index = popleft(recursive_indices)["index"]
			target_list.Cut(index, index+1)
			return TRUE
		if("addArg")
			var/list/recursive_indices = params["path"]
			var/top_affected_list_depth = LAZYLEN(recursive_indices)
			var/list/target_list
			if(top_affected_list_depth)
				var/list/path_list = kvpify_list(arguments, top_affected_list_depth)
				while(LAZYLEN(recursive_indices))
					var/list/path_element = popleft(recursive_indices)
					var/list/list_element = path_list[path_element["index"]]
					switch(path_element["type"])
						if("key")
							path_list = list_element["key"]
						if("value")
							path_list = list_element["value"]
						else
							to_chat(usr, span_warning("invalid path element type \[[path_element["type"]]] for argument addition (expected \"key\" or \"value\""))
							return
					if(!islist(path_list))
						to_chat(usr, span_warning("invalid path element \[[path_list]] for argument addition (expected a list)"))
						return
			else
				target_list = arguments
			add_argument(target_list)
			return
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
			current_state.call_function(arglist(list(function) + arguments))
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
			var/list/return_values = log_entry["param"]
			var/list/recursive_indices = params["tableIndices"]
			var/thing_to_debug = kvpify_list(return_values)
			while(LAZYLEN(recursive_indices))
				var/path_element = popleft(recursive_indices)
				var/index = path_element["index"]
				var/list_element = thing_to_debug[index]
				switch(path_element["type"])
					if("key")
						thing_to_debug = list_element["key"]
					if("value")
						thing_to_debug = list_element["value"]
					else
						to_chat(usr, span_warning("invalid path element \[[path_element["type"]]] for lua return VV (expected \"key\" or \"value\""))
						return
				if(!islist(thing_to_debug))
					break
			if(islist(thing_to_debug))
				thing_to_debug = dekvpify_list(thing_to_debug)
			INVOKE_ASYNC(usr.client, /client.proc/debug_variables, thing_to_debug)
			return
		if("vvGlobal")
			var/list/recursive_indices = params["indices"]
			var/thing_to_debug = kvpify_list(current_state.globals)
			while(LAZYLEN(recursive_indices))
				var/path_element = popleft(recursive_indices)
				var/index = path_element["index"]
				var/list_element = thing_to_debug[index]
				switch(path_element["type"])
					if("key")
						thing_to_debug = list_element["key"]
					if("value")
						thing_to_debug = list_element["value"]
					else
						to_chat(usr, span_warning("invalid path element \[[path_element["type"]]] for lua return VV (expected \"key\" or \"value\""))
						return
				if(!islist(thing_to_debug))
					break
			if(islist(thing_to_debug))
				thing_to_debug = dekvpify_list(thing_to_debug)
			INVOKE_ASYNC(usr.client, /client.proc/debug_variables, thing_to_debug)
			return
		if("loadCode")
			var/file_to_load = input(usr, "Select Script File", "Lua") as file|null
			if(!file_to_load)
				return
			imported_code = file2text(file_to_load)
			return TRUE
		if("clearArgs")
			arguments.Cut()
			return TRUE

/datum/lua_editor/ui_close(mob/user)
	. = ..()
	qdel(src)

/client/proc/open_lua_editor()
	set name = "Open Lua Editor"
	set category = "Debug"
	if(!check_rights_for(src, R_DEBUG))
		return
	if(SSlua.initialized != TRUE)
		to_chat(usr, span_warning("SSlua is not initialized!"))
		return
	var/datum/lua_editor/editor = new()
	editor.ui_interact(usr)
