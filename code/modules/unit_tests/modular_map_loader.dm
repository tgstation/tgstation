/datum/unit_test/modular_map_loader

/datum/unit_test/modular_map_loader/Run()
	for (var/obj/modular_map_root/map_root_type as anything in subtypesof(/obj/modular_map_root))
		var/config_file = initial(map_root_type.config_file)
		if (rustg_read_toml_file(config_file) == null)
			Fail("[map_root_type] points to a config file which is missing or invalid!")
