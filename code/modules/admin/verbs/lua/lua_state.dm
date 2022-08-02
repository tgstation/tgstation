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

	/// A list in which to store datums and lists instantiated in lua, ensuring that they don't get garbage collected
	var/list/references = list()

/datum/lua_state/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, internal_id))
		return FALSE

/datum/lua_state/New(_name)
	if(SSlua.initialized != TRUE)
		qdel(src)
		return
	name = _name
	internal_id = __lua_new_state()

/datum/lua_state/proc/check_if_slept(result)
	if(result["status"] == "sleeping")
		SSlua.sleeps += src

/datum/lua_state/proc/log_result(result, verbose = TRUE)
	if(!islist(result))
		return
	if(!verbose && result["status"] != "errored" && result["status"] != "bad return" \
		&& !(result["name"] == "input" && (result["status"] == "finished" || length(result["param"]))))
		return
	var/append_to_log = TRUE
	if(log.len)
		for(var/index in log.len to max(log.len - MAX_LOG_REPEAT_LOOKBACK, 1) step -1)
			var/list/entry = log[index]
			if(entry["status"] == result["status"] \
				&& entry["chunk"] == result["chunk"] \
				&& entry["name"] == result["name"] \
				&& ((entry["param"] == result["param"]) || deep_compare_list(entry["param"], result["param"])))
				if(!entry["repeats"])
					entry["repeats"] = 0
				entry["repeats"]++
				append_to_log = FALSE
				break
	if(append_to_log)
		log += list(weakrefify_list(result))
	INVOKE_ASYNC(src, .proc/update_editors)

/datum/lua_state/proc/load_script(script)
	GLOB.IsLuaCall = TRUE
	var/tmp_usr = GLOB.lua_usr
	GLOB.lua_usr = usr
	var/result = __lua_load(internal_id, script)
	GLOB.IsLuaCall = FALSE
	GLOB.lua_usr = tmp_usr

	// Internal errors unrelated to the code being executed are returned as text rather than lists
	if(isnull(result))
		result = list("status" = "errored", "param" = "__lua_load returned null (it may have runtimed - check the runtime logs)", "name" = "input")
	if(istext(result))
		result = list("status" = "errored", "param" = result, "name" = "input")
	result["chunk"] = script
	check_if_slept(result)

	message_admins("[key_name(usr)] executed [length(script)] bytes of lua code. [ADMIN_LUAVIEW_CHUNK(src, log.len)]")
	log_lua("[key_name(usr)] executed the following lua code:\n<code>[script]</code>")

	return result

/datum/lua_state/proc/call_function(function, ...)
	var/call_args = length(args) > 1 ? args.Copy(2) : list()
	var/msg = "[key_name(usr)] called the lua function \"[function]\" with arguments: [english_list(call_args)]"
	log_lua(msg)

	var/tmp_usr = GLOB.lua_usr
	GLOB.lua_usr = usr
	GLOB.IsLuaCall = TRUE
	var/result = __lua_call(internal_id, function, call_args)
	GLOB.IsLuaCall = FALSE
	GLOB.lua_usr = tmp_usr

	if(isnull(result))
		result = list("status" = "errored", "param" = "__lua_call returned null (it may have runtimed - check the runtime logs)", "name" = "input")
	if(istext(result))
		result = list("status" = "errored", "param" = result, "name" = islist(function) ? jointext(function, ".") : function)
	check_if_slept(result)
	return result

/datum/lua_state/proc/call_function_return_first(function, ...)
	var/list/result = call_function(arglist(args))
	log_result(result, verbose = FALSE)
	if(length(result))
		if(islist(result["param"]) && length(result["param"]))
			return result["param"][1]

/datum/lua_state/proc/awaken()
	GLOB.IsLuaCall = TRUE
	var/result = __lua_awaken(internal_id)
	GLOB.IsLuaCall = FALSE

	if(isnull(result))
		result = list("status" = "errored", "param" = "__lua_awaken returned null (it may have runtimed - check the runtime logs)", "name" = "input")
	if(istext(result))
		result = list("status" = "errored", "param" = result, "name" = "An attempted awaken")
	check_if_slept(result)
	return result

/// Prefer calling SSlua.queue_resume over directly calling this
/datum/lua_state/proc/resume(index, ...)
	var/call_args = length(args) > 1 ? args.Copy(2) : list()
	var/msg = "[key_name(usr)] resumed a lua coroutine with arguments: [english_list(call_args)]"
	log_lua(msg)

	GLOB.IsLuaCall = TRUE
	var/result = __lua_resume(internal_id, index, call_args)
	GLOB.IsLuaCall = FALSE

	if(isnull(result))
		result = list("status" = "errored", "param" = "__lua_resume returned null (it may have runtimed - check the runtime logs)", "name" = "input")
	if(istext(result))
		result = list("status" = "errored", "param" = result, "name" = "An attempted resume")
	check_if_slept(result)
	return result

/datum/lua_state/proc/get_globals()
	globals = weakrefify_list(__lua_get_globals(internal_id))

/datum/lua_state/proc/get_tasks()
	return __lua_get_tasks(internal_id)

/datum/lua_state/proc/kill_task(task_info)
	__lua_kill_task(internal_id, task_info)

/datum/lua_state/proc/update_editors()
	var/list/editor_list = LAZYACCESS(SSlua.editors, "\ref[src]")
	if(editor_list)
		for(var/datum/lua_editor/editor as anything in editor_list)
			SStgui.update_uis(editor)

#undef MAX_LOG_REPEAT_LOOKBACK
