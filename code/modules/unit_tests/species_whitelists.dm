/datum/unit_test/species_whitelist_check/Run()
	for(var/typepath in subtypesof(/datum/species))
		var/datum/species/S = typepath
		if(initial(S.changesource_flags) == NONE && !S.check_roundstart_eligible()) //cannot be made in any way + cannot be roundstart = completely unavailable
			Fail("A species type was detected with no changesource flags, and is not roundstart eligible: [S]")
