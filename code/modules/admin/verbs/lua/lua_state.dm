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

/datum/lua_state/CanProcCall(procname)
	if(GLOB.IsLuaCall) //No calling auxlua hooks from lua code
		return FALSE
	return ..()

/datum/lua_state/New(_name)
	if(SSlua.initialized != TRUE)
		qdel(src)
		return
	name = _name
	internal_id = __lua_new_state()

/datum/lua_state/proc/handle_result(result)
	// If this is a sleep, we need to add it to the subsystem's list of sleeps to run in the next fire
	if(result["status"] == "sleeping")
		SSlua.sleeps += src
	var/append_to_log = TRUE
	if(log.len)
		var/list/last_entry = peek(log)
		if(last_entry["status"] == result["status"] \
			&& last_entry["chunk"] == result["chunk"] \
			&& last_entry["name"] == result["name"] \
			&& ((last_entry["param"] == result["param"]) || deep_compare_list(last_entry["param"], result["param"])))
			if(!last_entry["repeats"])
				last_entry["repeats"] = 0
			last_entry["repeats"]++
			append_to_log = FALSE
	if(append_to_log)
		log += list(result)
	// We want to return the return value(s) of executed code
	if(result["status"] == "finished" || result["status"] == "yielded")
		return result["param"]

/datum/lua_state/proc/load_script(script)
	GLOB.IsLuaCall = TRUE
	var/tmp_usr = GLOB.lua_usr
	GLOB.lua_usr = usr
	var/result = __lua_load(internal_id, script)
	GLOB.IsLuaCall = FALSE
	GLOB.lua_usr = tmp_usr

	// Internal errors unrelated to the code being executed are returned as text rather than lists
	if(istext(result))
		result = list("status" = "error", "param" = result, "name" = "input")
	result["chunk"] = script
	. = handle_result(result)

	message_admins("[key_name(usr)] executed [length(script)] bytes of lua code. [ADMIN_LUAVIEW_CHUNK(src, log.len)]")
	log_lua("[key_name(usr)] executed the following lua code:\n[script]")

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

	if(istext(result))
		result = list("status" = "error", "param" = result, "name" = islist(function) ? jointext(function, ".") : function)
	return handle_result(result)

/datum/lua_state/proc/call_function_return_first(function, ...)
	var/list/return_values = call_function(arglist(args))
	if(length(return_values))
		return return_values[1]

/datum/lua_state/proc/awaken()
	GLOB.IsLuaCall = TRUE
	var/result = __lua_awaken(internal_id)
	GLOB.IsLuaCall = FALSE

	if(istext(result))
		result = list("status" = "error", "param" = result, "name" = "An attempted awaken")
	return handle_result(result)

/// Prefer calling SSlua.queue_resume over directly calling this
/datum/lua_state/proc/resume(index, ...)
	var/call_args = length(args) > 1 ? args.Copy(2) : list()
	var/msg = "[key_name(usr)] resumed a lua coroutine with arguments: [english_list(call_args)]"
	log_lua(msg)

	GLOB.IsLuaCall = TRUE
	var/result = __lua_resume(internal_id, index, call_args)
	GLOB.IsLuaCall = FALSE

	if(istext(result))
		result = list("status" = "error", "param" = result, "name" = "An attempted resume")
	return handle_result(result)

/datum/lua_state/proc/get_globals()
	globals = __lua_get_globals(internal_id)

/datum/lua_state/proc/get_tasks()
	return __lua_get_tasks(internal_id)

/datum/lua_state/proc/kill_task(task_info)
	__lua_kill_task(internal_id, task_info)
