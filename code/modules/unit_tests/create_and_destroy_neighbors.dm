/// Ensures correct usage of the CREATION_TEST_REQUIRED_NEIGHBOR() macro.
/datum/unit_test/create_and_destroy

/datum/unit_test/create_and_destroy/Run()
	var/list/type_paths_to_check = (valid_typesof(/atom/movable) + valid_typesof(/turf)) - uncreatables // No areas please
	for(var/atom/type_path as anything in type_paths_to_check)
		if(type_path::creation_test_master && type_path::creation_test_has_child)
			TEST_FAIL("[type_path] is both a master and child creation test type!")
