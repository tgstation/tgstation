/datum/unit_test/aas_configs

/datum/unit_test/aas_configs/Run()
	var/expected_max_length = MAX_AAS_LENGTH

	for(var/config_type in valid_subtypesof(/datum/aas_config_entry))
		var/datum/aas_config_entry/entry = allocate(config_type)
		for(var/key, line in entry.announcement_lines_map)
			if(length_char(line) > expected_max_length)
				TEST_FAIL("Announcement line '[key]' in config '[config_type]' exceeds max length of [expected_max_length] characters (actual length: [length(line)])")
