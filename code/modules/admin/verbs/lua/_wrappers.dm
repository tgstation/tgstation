/proc/wrap_lua_set_var(datum/thing_to_set, var_name, value)
	SHOULD_NOT_SLEEP(TRUE)
	thing_to_set.vv_edit_var(var_name, value)

/proc/wrap_lua_datum_proc_call(datum/thing_to_call, proc_name, list/arguments)
	SHOULD_NOT_SLEEP(TRUE)
	if(!usr)
		usr = GLOB.lua_usr
	var/ret
	if(usr)
		ret = WrapAdminProcCall(thing_to_call, proc_name, arguments)
	else
		ret = HandleUserlessProcCall("lua", thing_to_call, proc_name, arguments)
	if(isdatum(ret))
		SSlua.gc_guard = ret
		var/datum/ret_datum = ret
		ret_datum.RegisterSignal(ret_datum, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/datum, lua_reference_cleanup), override = TRUE)
	return ret

/proc/wrap_lua_global_proc_call(proc_name, list/arguments)
	SHOULD_NOT_SLEEP(TRUE)
	if(!usr)
		usr = GLOB.lua_usr
	var/ret
	if(usr)
		ret = WrapAdminProcCall(GLOBAL_PROC, proc_name, arguments)
	else
		ret = HandleUserlessProcCall("lua", GLOBAL_PROC, proc_name, arguments)
	if(isdatum(ret))
		SSlua.gc_guard = ret
		var/datum/ret_datum = ret
		ret_datum.RegisterSignal(ret_datum, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/datum, lua_reference_cleanup), override = TRUE)
	return ret

/proc/wrap_lua_print(state_id, list/arguments)
	SHOULD_NOT_SLEEP(TRUE)
	var/datum/lua_state/target_state
	for(var/datum/lua_state/state as anything in SSlua.states)
		if(state.internal_id == state_id)
			target_state = state
			break
	if(!target_state)
		return
	var/print_message = jointext(arguments, "\t")
	var/result = list("status" = "print", "param" = print_message)
	INVOKE_ASYNC(target_state, TYPE_PROC_REF(/datum/lua_state, log_result), result, TRUE)
	log_lua("[target_state]: [print_message]")
