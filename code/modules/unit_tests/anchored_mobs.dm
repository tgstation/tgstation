/datum/unit_test/anchored_mobs/Run()
	var/list/L = list()
	for(var/i in typesof(/mob))
		var/path = i
		var/mob/M = path
		if(initial(M.anchored))
			L += path
	if(!L.len)
		return			//passed!
	var/list/R = list()
	for(var/i in L)
		R += "[i]"
	Fail("The following mobs are defined as anchored. This is incompatible with the new move force/resist system and needs to be revised.: [R.Join(" ")]")
