/proc/wrap_lua_set_var(datum/thing_to_set, var_name, value)
	thing_to_set.vv_edit_var(var_name, value)

/proc/wrap_lua_datum_proc_call(datum/thing_to_call, proc_name, list/arguments)
	if(!usr)
		usr = GLOB.lua_usr
	if(usr)
		SSlua.gc_guard = WrapAdminProcCall(thing_to_call, proc_name, arguments)
	else
		SSlua.gc_guard = HandleUserlessProcCall("lua", thing_to_call, proc_name, arguments)
	return SSlua.gc_guard

/proc/wrap_lua_global_proc_call(proc_name, list/arguments)
	if(!usr)
		usr = GLOB.lua_usr
	if(usr)
		SSlua.gc_guard = WrapAdminProcCall(GLOBAL_PROC, proc_name, arguments)
	else
		SSlua.gc_guard = HandleUserlessProcCall("lua", GLOBAL_PROC, proc_name, arguments)
	return SSlua.gc_guard

/proc/wrap_lua_print(state_id, list/arguments)
	var/datum/lua_state/target_state
	for(var/datum/lua_state/state as anything in SSlua.states)
		if(state.internal_id == state_id)
			target_state = state
			break
	if(!target_state)
		return
	var/print_message = jointext(arguments, "\t")
	var/result = list("status" = "print", "param" = print_message)
	target_state.log_result(result, verbose = TRUE)
	log_lua("[target_state]: [print_message]")
