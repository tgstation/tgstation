/proc/wrap_lua_get_var(datum/thing, var_name)
	SHOULD_NOT_SLEEP(TRUE)
	if(thing == world)
		return world.vars[var_name]
	if(ref(thing) == "\[0xe000001\]") //This weird fucking thing is like global.vars, but it's not a list and vars is not a valid index for it and I really don't fucking know.
		return global.vars[var_name]
	if(thing.can_vv_get(var_name))
		return thing.vars[var_name]

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
	var/result = list("status" = "print", "message" = print_message)
	INVOKE_ASYNC(target_state, TYPE_PROC_REF(/datum/lua_state, log_result), result, TRUE)
	log_lua("[target_state]: [print_message]")
