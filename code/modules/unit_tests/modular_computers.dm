//File for containing unit tests related to modular computers


///Check that non-abstract maintenance themes have an id and a name
/datum/unit_test/maintenance_themes

/datum/unit_test/maintenance_themes/Run()
	var/list/collected_ids = list()
	for(var/datum/computer_file/program/maintenance/theme/proto_theme as anything in typesof(/datum/computer_file/program/maintenance/theme))
		if(proto_theme::abstract_type == proto_theme)
			continue
		if(!proto_theme::name)
			TEST_FAIL("[proto_theme] doesn't have a set name")
		if(!proto_theme::theme_id)
			TEST_FAIL("[proto_theme] doesn't have a set id")
			continue
		if(collected_ids[proto_theme::theme_id])
			TEST_FAIL("There's already a theme with same id as [proto_theme]")
		collected_ids[proto_theme::theme_id] = TRUE
