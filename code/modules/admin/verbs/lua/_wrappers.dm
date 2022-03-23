/proc/wrap_lua_set_var(datum/thing_to_set, var_name, value)
	thing_to_set.vv_edit_var(var_name, value)

/proc/wrap_lua_datum_proc_call(datum/thing_to_call, proc_name, list/arguments)
	SSlua.gc_guard = HandleUserlessProcCall("lua", thing_to_call, proc_name, arguments)
	return SSlua.gc_guard

/proc/wrap_lua_global_proc_call(proc_name, list/arguments)
	SSlua.gc_guard = HandleUserlessProcCall("lua", GLOBAL_PROC, proc_name, arguments)
	return SSlua.gc_guard

/proc/wrap_lua_require(modname)
	var/list/paths = CONFIG_GET(str_list/lua_path)
	for(var/path in paths)
		path = replacetext(path, "?", modname)
		if(fexists(path))
			return file2text(path)
