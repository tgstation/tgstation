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

/datum/lua_state/CanProcCall(procname)
	if(SSlua.in_lua_stack) //No calling auxlua hooks from lua code
		return FALSE
	. = ..()

/datum/lua_state/New(_name)
	if(SSlua.initialized != TRUE)
		qdel(src)
		return
	name = _name
	internal_id = __lua_new_state()

/datum/lua_state/proc/handle_result(result)
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

/datum/lua_state/proc/load_script(script)
	var/tmp_usr = SSlua.lua_usr
	SSlua.lua_usr = usr
	SSlua.in_lua_stack = TRUE
	var/result = __lua_load(internal_id, script)
	SSlua.in_lua_stack = FALSE
	SSlua.lua_usr = tmp_usr
	if(istext(result))
		result = list("status" = "error", "param" = result, "name" = "input")
	result["chunk"] = script
	return handle_result(result)

/datum/lua_state/proc/call_function(function, ...)
	var/call_args = length(args) > 1 ? args.Copy(2) : list()
	var/tmp_usr = SSlua.lua_usr
	SSlua.lua_usr = usr
	SSlua.in_lua_stack = TRUE
	var/result = __lua_call(internal_id, function, call_args)
	SSlua.in_lua_stack = FALSE
	SSlua.lua_usr = tmp_usr
	if(istext(result))
		result = list("status" = "error", "param" = result, "name" = islist(function) ? jointext(function, ".") : function)
	return handle_result(result)

/datum/lua_state/proc/awaken()
	SSlua.in_lua_stack = TRUE
	var/result = __lua_awaken(internal_id)
	SSlua.in_lua_stack = FALSE
	if(istext(result))
		result = list("status" = "error", "param" = result, "name" = "An attempted awaken")
	return handle_result(result)

/// Prefer calling SSlua.queue_resume over directly calling this
/datum/lua_state/proc/resume(index, ...)
	var/call_args = length(args) > 1 ? args.Copy(2) : list()
	SSlua.in_lua_stack = TRUE
	var/result = __lua_resume(internal_id, index, call_args)
	SSlua.in_lua_stack = FALSE
	if(istext(result))
		result = list("status" = "error", "param" = result, "name" = "An attempted resume")
	return handle_result(result)

/datum/lua_state/proc/get_globals()
	globals = __lua_get_globals(internal_id)

/datum/lua_state/proc/get_tasks()
	return __lua_get_tasks(internal_id)

/datum/lua_state/proc/kill_task(task_info)
	__lua_kill_task(internal_id, task_info)
