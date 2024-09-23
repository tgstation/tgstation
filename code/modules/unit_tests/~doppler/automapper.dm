/// Checks that all automapper TOML entries actually link to a map and that the config exists.
/datum/unit_test/automapper
	var/config_path = "_maps/doppler/automapper/automapper_config.toml"

/datum/unit_test/automapper/Run()
	var/test_config = rustg_read_toml_file(config_path)

	if(!test_config)
		TEST_FAIL("Automapper could not read/find TOML config [config_path]!")
		return

	for(var/template in test_config["templates"])
		var/selected_template = test_config["templates"][template]

		for(var/map in selected_template["map_files"])
			var/map_file = selected_template["directory"] + selected_template["map_files"][map]
			TEST_ASSERT(fexists(map_file), "[template] could not find map file [map_file]!") // Testing for map existence

		for(var/template_two in test_config["templates"]) // Testing for duplicate entries
			if(template_two == template)
				continue
			var/selected_template_two = test_config["templates"][template_two]

			TEST_ASSERT_NOTEQUAL(selected_template["coordinates"], selected_template_two["coordinates"], "Automap template [template] had the same coords as [template_two]!")
			TEST_ASSERT_NOTEQUAL(selected_template["map_files"], selected_template_two["map_files"], "Automap template [template] had the same map files as [template_two]!")

/// This is like /datum/unit_test/log_mapping and tests if the integration with the current map failed.
/datum/unit_test/area_spawn

/datum/unit_test/area_spawn/Run()
	for(var/datum/area_spawn/area_spawn as anything in SSarea_spawn.failed_area_spawns)
		TEST_FAIL("[area_spawn] could not find any suitable turfs among [english_list(initial(area_spawn.target_areas))].")

