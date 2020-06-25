/datum/unit_test/configuration_documentation
	/// List of undocumented config entries
	var/list/undocumented_entries
	/// List of set config entries with no code equivalent
	var/list/extraneous_entries

/datum/unit_test/configuration_documentation/Run()
	undocumented_entries = global.config.entries.Copy()
	extraneous_entries = list()
	var/test_config_file = world.params["original_config"] ? world.params["original_config"] : DEFAULT_CONFIGURATION_FILE
	TestGraph(test_config_file)
	if(undocumented_entries.len)
		Fail("The following configuration entries are missing default values in the .txt (commented out or otherwise): [english_list(undocumented_entries)]")
	if(extraneous_entries.len)
		Fail("The following configuration entries do not have a match in code: [english_list(extraneous_entries, assoc = TRUE)]")

/**
  * Test a graph of config files inclusions
  * filename - The file to test
  * stack - Used for recursive calls to prevent repeat parsing
  */
/datum/unit_test/configuration_documentation/proc/TestGraph(filename, list/stack = list())
	var/filename_to_test = world.system_type == MS_WINDOWS ? lowertext(filename) : filename
	if(filename_to_test in stack)
		Fail("Config recursion detected ([english_list(stack)])!")
		return

	stack = stack + filename_to_test

	var/list/parsed_entries = global.config.ParseConfigFile(filename_to_test)
	for(var/entry in parsed_entries)
		if(!entry)
			// Commented out entries
			for(var/disabled_entry in parsed_entries[entry])
				TryRemoveEntry(entry, filename_to_test)
		else if(entry == CONFIGURATION_INCLUDE_TOKEN)
			TestGraph(parsed_entries[entry], stack)
		else
			TryRemoveEntry(entry, filename_to_test)

/**
  * Attempt to update undocumented_entries and extraneous_entries
  * entry - The detected entry
  * filename - The containing filename
  */
/datum/unit_test/configuration_documentation/proc/TryRemoveEntry(entry, filename)
	var/start_len = undocumented_entries.len
	undocumented_entries -= entry
	if(undocumented_entries.len == start_len)
		extraneous_entries[entry] = filename
