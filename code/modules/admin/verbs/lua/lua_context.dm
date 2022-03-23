/datum/lua_context
	var/name

	/// The internal ID of the lua state stored in auxlua's global map
	var/internal_id

	/// A log of every return, yield, and error for each chunk execution and function call
	var/list/log = list()

	/// A list of all the variables in the state's environment
	var/list/globals = list()

	/// A list in which to store datums and lists instantiated in lua, ensuring that they don't get garbage collected
	var/list/references = list()

/datum/lua_context/vv_edit_var(var_name, var_value)
	. = ..()
	if(var_name == NAMEOF(src, internal_id))
		return FALSE

/datum/lua_context/New(_name)
	if(SSlua.initialized != TRUE)
		qdel(src)
		return
	name = _name
	internal_id = __lua_new_context()

/datum/lua_context/proc/handle_result(result)
	if(result["status"] == "sleeping")
		SSlua.sleeps += src
		if(!result["chunk"])
			return
	log += list(result)
	if(result["status"] == "finished" || result["status"] == "yielded")
		if(!length(result["param"]))
			return
		else if(length(result["param"]) == 1)
			return result["param"][1]
		else
			return result["param"]

/datum/lua_context/proc/load_script(script)
	var/result = __lua_load(internal_id, script)
	if(istext(result))
		result = list("status" = "error", "param" = result, "name" = "input")
	result["chunk"] = script
	return handle_result(result)

/datum/lua_context/proc/call_function(function, ...)
	var/call_args = length(args) > 1 ? args.Copy(2) : list()
	var/result = __lua_call(internal_id, function, call_args)
	if(istext(result))
		result = list("status" = "error", "param" = result, "name" = islist(function) ? jointext(function, ".") : function)
	return handle_result(result)

/datum/lua_context/proc/awaken()
	var/result = __lua_awaken(internal_id)
	if(istext(result))
		result = list("status" = "error", "param" = result, "name" = "An attempted awaken")
	return handle_result(result)

/// Prefer calling SSlua.queue_resume over directly calling this
/datum/lua_context/proc/resume(index, ...)
	var/call_args = length(args) > 1 ? args.Copy(2) : list()
	var/result = __lua_resume(internal_id, index, call_args)
	if(istext(result))
		result = list("status" = "error", "param" = result, "name" = "An attempted resume")
	return handle_result(result)

/datum/lua_context/proc/get_globals()
	globals = __lua_get_globals(internal_id)

/datum/lua_context/proc/get_tasks()
	return __lua_get_tasks(internal_id)

/datum/lua_context/proc/kill_task(task_info)
	__lua_kill_task(internal_id, task_info)
