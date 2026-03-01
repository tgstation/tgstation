/datum/unit_test/component_duping/Run()
	var/list/bad_dms = list()
	for(var/t in typesof(/datum/component))
		var/datum/component/comp = t
		if(!isnum(initial(comp.dupe_mode)))
			bad_dms += t
	TEST_ASSERT(!length(bad_dms), "Components with invalid dupe modes: ([bad_dms.Join(",")])")
