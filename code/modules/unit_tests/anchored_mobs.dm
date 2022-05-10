/datum/unit_test/anchored_mobs/Run()
	var/list/L = list()
	for(var/i in typesof(/mob))
		var/mob/M = i
		if(initial(M.anchored))
			L += "[i]"
	TEST_ASSERT(!L.len, "The following mobs are defined as anchored. This is incompatible with the new move force/resist system and needs to be revised.: [L.Join(" ")]")
