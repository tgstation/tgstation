/client/set_macros()
	set waitfor = FALSE

	erase_all_macros()

	var/list/macro_sets = SSinput.macro_sets
	for(var/i in 1 to macro_sets.len)
		var/setname = macro_sets[i]
		if(setname != "default")
			winclone(src, "default", setname)
		var/list/macro_set = macro_sets[setname]
		for(var/k in 1 to macro_set.len)
			var/key = macro_set[k]
			var/command = macro_set[key]
			winset(src, "[setname]-[REF(key)]", "parent=[setname];name=[key];command=[command]")

	winset(src, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED] mainwindow.macro=default")