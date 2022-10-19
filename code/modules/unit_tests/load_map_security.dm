// replace runtimestation with another valid _maps .json if not present
#define VALID_TEST_MAP "runtimestation"

/// Tests to ensure we can load a map from a whitelisted directory (_maps), but not a non-whitelisted directory (i.e "fartyShitPants")
/datum/unit_test/load_map_security

/datum/unit_test/load_map_security/Run()

	// Copy our valid map into a bad directory
	// We can technically load from /unitTestTempDir by passing it in our map name
	// But it should fail when passed as a directory
	fcopy("_maps/[VALID_TEST_MAP].json", "data/load_map_security_temp/[VALID_TEST_MAP].json")

	//Attempt to load our configs

	// test load from _maps - this should pass
	var/datum/map_config/maps_config = load_map_config(VALID_TEST_MAP, MAP_DIRECTORY_MAPS)

	// test load from data - this should pass
	// this also confirms that our fcopy worked for our bad_config test
	var/datum/map_config/data_config = load_map_config("load_map_security_temp/[VALID_TEST_MAP]", MAP_DIRECTORY_DATA)

	// data/load_map_security_temp/ is not in our whitelist, this should fail
	var/datum/map_config/bad_config = load_map_config(VALID_TEST_MAP,"data/load_map_security_temp")


	// Check we can load from _maps
	TEST_ASSERT(!maps_config.defaulted, "Failed to load: _maps/[VALID_TEST_MAP]")

	// Check we can load from data and ensure that our fcopy setup worked
	TEST_ASSERT(!data_config.defaulted, "Failed to load: data/load_map_security_temp/[VALID_TEST_MAP]")

	// Check we can't load from "bad directory"
	TEST_ASSERT(bad_config.defaulted, "Loaded from non-whitelisted directory: data/load_map_security_temp/[VALID_TEST_MAP]")


/datum/unit_test/load_map_security/Destroy()
	// Clean up our temp directory
	fdel("data/load_map_security_temp/")
	return ..()

#undef VALID_TEST_MAP
