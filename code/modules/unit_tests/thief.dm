/// Test thiefs for valid json
/datum/unit_test/thief/Run()
	load_strings_file(THIEF_FLAVOR_FILE)
	var/list/all_thief_flavors = GLOB.string_cache[THIEF_FLAVOR_FILE]
	for(var/list/thief_flavor as anything in all_thief_flavors)
		try
			var/objective_path = text2path(thief_flavor["objective_type"])
			var/datum/objective/exists allocate(objective_path)
			qdel(exists)
		catch(var/exception/exception)
			Fail("[reagent_type] has an INVALID \"objective_type\" value in thief_flavor.json!\n[exception]")
