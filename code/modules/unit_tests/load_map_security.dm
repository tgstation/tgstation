//Tests to ensure we can load a map from a whitelisted directory (_maps), but not a non-whitelisted directory (i.e "fartyShitPants")
/datum/unit_test/load_map_security/Run()

	//Replace runtimestation with another valid map .json if not present
	var/goodMap = "runtimestation"

	// Copy our good map into a bad directory
	// We can technically load from /unitTestTempDir by passing it in our map name
	// But it should fail when passed as a directory
	fcopy("_maps/[goodMap].json", "data/load_map_security_temp/[goodMap].json")

	//Attempt to load our configs
	var/datum/map_config/good_config = load_map_config("_maps",goodMap)
	var/datum/map_config/bad_config = load_map_config("data/load_map_security_temp",goodMap)
	var/datum/map_config/proove_fcopy_config = load_map_config("data","load_map_security_temp/[goodMap]")

	//Check we can still load from _maps
	TEST_ASSERT(!good_config.defaulted, "Failed to load: _maps/[goodMap]")

	//Check we can't load from "bad directory"
	TEST_ASSERT(bad_config.defaulted, "Loaded from non-whitelisted directory: data/load_map_security_temp/[goodMap]")

	//Proove that fcopy worked for bad_config, and the .json is in the "bad directory"
	TEST_ASSERT(!proove_fcopy_config.defaulted, "Failed to load: data/load_map_security_temp/[goodMap]")

	fdel("data/load_map_security_temp/")
