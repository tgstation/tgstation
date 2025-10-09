/datum/unit_test/maptest_modular_map_loader

/datum/unit_test/maptest_modular_map_loader/Run()
	for (var/obj/modular_map_root/map_root_type as anything in subtypesof(/obj/modular_map_root))
		var/config_file = initial(map_root_type.config_file)
		if (!fexists(config_file))
			TEST_FAIL("[map_root_type] points to a config file which does not exist!")
			continue
		if (rustg_read_toml_file(config_file) == null)
			TEST_FAIL("[map_root_type] points to a config file which is invalid!")
