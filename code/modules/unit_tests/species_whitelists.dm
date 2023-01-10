/datum/unit_test/species_whitelist_check/Run()
	for(var/typepath in subtypesof(/datum/species))
		var/datum/species/S = typepath
		if(initial(S.changesource_flags) == NONE)
			TEST_FAIL("A species type was detected with no changesource flags: [S]")
