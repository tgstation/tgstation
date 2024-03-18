#define MAX_LOG_REPEAT_LOOKBACK 5

GLOBAL_VAR_INIT(IsLuaCall, FALSE)
GLOBAL_PROTECT(IsLuaCall)

GLOBAL_DATUM(lua_usr, /mob)
GLOBAL_PROTECT(lua_usr)

/datum/lua_state
	var/name

	/// The internal ID of the lua state stored in auxlua's global map
	var/internal_id

	/// A log of every return, yield, and error for each chunk execution and function call
	var/list/log = list()

	/// A list of all the variables in the state's environment
	var/list/globals = list()

	/// Ckey of the last user who ran a script on this lua state.
	var/ckey_last_runner = ""

/datum/lua_state/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, internal_id))
		return FALSE

/datum/lua_state/New(_name)
	if(SSlua.initialized != TRUE)
		qdel(src)
		return
	name = _name
	internal_id = DREAMLUAU_NEW_STATE()
	if(!isnum(internal_id))
		stack_trace(internal_id)
		qdel(src)

/datum/lua_state/proc/check_if_slept(result)
	if(result["status"] == "sleep")
		SSlua.sleeps += src

/datum/lua_state/proc/log_result(result, verbose = TRUE)
	if(!islist(result))
		return
	var/status = result["status"]
	if(!verbose && status != "error" && status != "panic" && !(result["name"] == "input" && (status == "finished" || length(result["return_values"]))))
		return
	var/append_to_log = TRUE
	var/index_of_log
	if(log.len)
		for(var/index in log.len to max(log.len - MAX_LOG_REPEAT_LOOKBACK, 1) step -1)
			var/list/entry = log[index]
			if(entry["status"] != status)
				continue
			if(entry["chunk"] != result["chunk"])
				continue
			if(entry["name"] != result["name"])
				continue
			if((status == "error" || status == "panic" || status == "print") && (entry["message"] != result["message"]))
				continue
			if(!(deep_compare_list(result["return_values"], entry["return_values"]) && deep_compare_list(result["variants"], result["variants"])))
				continue
			if(!entry["repeats"])
				entry["repeats"] = 0
			index_of_log = index
			entry["repeats"]++
			append_to_log = FALSE
			break
	if(append_to_log)
		if(islist(result["return_values"]))
			add_lua_return_value_variants(result["return_values"], result["variants"])
			result["return_values"] = weakrefify_list(result["return_values"])
		log += list(result)
		index_of_log = log.len
	INVOKE_ASYNC(src, TYPE_PROC_REF(/datum/lua_state, update_editors))
	return index_of_log

/datum/lua_state/proc/parse_error(message, name)
	if(copytext(message, 1, 7) == "PANIC:")
		return list("status" = "panic", "message" = copytext(message, 7), "name" = name)
	else
		return list("status" = "error", "message" = message, "name" = name)

/datum/lua_state/proc/load_script(script)
	GLOB.IsLuaCall = TRUE
	var/tmp_usr = GLOB.lua_usr
	GLOB.lua_usr = usr
	DREAMLUAU_SET_USR
	var/result = DREAMLUAU_LOAD(internal_id, script, "input")
	GLOB.IsLuaCall = FALSE
	GLOB.lua_usr = tmp_usr

	// Internal errors unrelated to the code being executed are returned as text rather than lists
	if(isnull(result))
		result = list("status" = "error", "message" = "load returned null (it may have runtimed - check the runtime logs)", "name" = "input")
	if(istext(result))
		result = parse_error(result, "input")
	result["chunk"] = script
	check_if_slept(result)

	log_lua("[key_name(usr)] executed the following lua code:\n<code>[script]</code>")

	return result

/datum/lua_state/proc/call_function(function, ...)
	var/call_args = length(args) > 1 ? args.Copy(2) : list()
	if(islist(function))
		var/list/new_function_path = list()
		for(var/path_element in function)
			if(isweakref(path_element))
				var/datum/weakref/weak_ref = path_element
				var/resolved = weak_ref.hard_resolve()
				if(!resolved)
					return list("status" = "error", "message" = "Weakref in function path ([weak_ref] [text_ref(weak_ref)]) resolved to null.", "name" = jointext(function, "."))
				new_function_path += resolved
			else
				new_function_path += path_element
		function = new_function_path
	log_lua("[key_name(usr)] called the lua function \"[jointext(function, ".")]\" with arguments: [english_list(call_args)]")

	var/tmp_usr = GLOB.lua_usr
	GLOB.lua_usr = usr
	GLOB.IsLuaCall = TRUE
	DREAMLUAU_SET_USR
	var/result = DREAMLUAU_CALL_FUNCTION(internal_id, function, call_args)
	GLOB.IsLuaCall = FALSE
	GLOB.lua_usr = tmp_usr

	if(isnull(result))
		result = list("status" = "error", "message" = "call_function returned null (it may have runtimed - check the runtime logs)", "name" = jointext(function, "."))
	if(istext(result))
		result = parse_error(result, jointext(function, "."))
	check_if_slept(result)
	return result

/datum/lua_state/proc/call_function_return_first(function, ...)
	var/list/result = call_function(arglist(args))
	log_result(deep_copy_list(result), verbose = FALSE)
	if(length(result))
		if(islist(result["return_values"]) && length(result["return_values"]))
			var/return_value = result["return_values"][1]
			var/variant = (islist(result["variants"]) && length(result["variants"])) && result["variants"][1]
			if(islist(return_value) && islist(variant))
				remove_non_dm_variants(return_value, variant)
			return return_value

/datum/lua_state/proc/awaken()
	GLOB.IsLuaCall = TRUE
	DREAMLUAU_SET_USR
	var/result = DREAMLUAU_AWAKEN(internal_id)
	GLOB.IsLuaCall = FALSE

	if(isnull(result))
		result = list("status" = "error", "message" = "awaken returned null (it may have runtimed - check the runtime logs)", "name" = "An attempted awaken")
	if(istext(result))
		result = parse_error(result, "An attempted awaken")
	check_if_slept(result)
	return result

/// Prefer calling SSlua.queue_resume over directly calling this
/datum/lua_state/proc/resume(index, ...)
	var/call_args = length(args) > 1 ? args.Copy(2) : list()
	var/msg = "[key_name(usr)] resumed a lua coroutine with arguments: [english_list(call_args)]"
	log_lua(msg)

	GLOB.IsLuaCall = TRUE
	DREAMLUAU_SET_USR
	var/result = DREAMLUAU_RESUME(internal_id, index, call_args)
	GLOB.IsLuaCall = FALSE

	if(isnull(result))
		result = list("status" = "error", "param" = "resume returned null (it may have runtimed - check the runtime logs)", "name" = "An attempted resume")
	if(istext(result))
		result = parse_error(result, "An attempted resumt")
	check_if_slept(result)
	return result

/datum/lua_state/proc/get_globals()
	var/result = DREAMLUAU_GET_GLOBALS(internal_id)
	if(isnull(result))
		CRASH("get_globals returned null")
	if(istext(result))
		CRASH(result)
	var/list/new_globals = result
	var/list/values = new_globals["values"]
	var/list/variants = new_globals["variants"]
	add_lua_editor_variants(values, variants)
	globals = list("values" = weakrefify_list(values), "variants" = variants)

/datum/lua_state/proc/get_tasks()
	var/result = DREAMLUAU_LIST_THREADS(internal_id)
	if(isnull(result))
		CRASH("list_threads returned null")
	if(istext(result))
		CRASH(result)
	return result

/datum/lua_state/proc/kill_task(is_sleep, index)
	return is_sleep ? DREAMLUAU_KILL_SLEEPING_THREAD(internal_id, index) : DREAMLUAU_KILL_YIELDED_THREAD(internal_id, index)

/datum/lua_state/proc/update_editors()
	var/list/editor_list = LAZYACCESS(SSlua.editors, text_ref(src))
	if(editor_list)
		for(var/datum/lua_editor/editor as anything in editor_list)
			SStgui.update_uis(editor)

#undef MAX_LOG_REPEAT_LOOKBACK
