/datum/unit_test/keybinding_init/Run()
	for(var/i in subtypesof(/datum/keybinding))
		var/datum/keybinding/KB = i
		if(initial(KB.keybind_signal) || !initial(KB.name))
			continue
		Fail("[KB.name] does not have a keybind signal defined.")
