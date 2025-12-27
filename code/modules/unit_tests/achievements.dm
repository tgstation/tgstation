///Checks that all achievements have an existing icon state in the achievements icon file.
/datum/unit_test/achievements

/datum/unit_test/achievements/Run()
	var/list/collected_ids = list()
	for(var/datum/award/award as anything in subtypesof(/datum/award))
		if(!initial(award.name)) //Skip abstract achievements types
			continue
		if(!award::icon_state || !icon_exists(award::icon, award::icon_state))
			TEST_FAIL("[award] has a non-existent icon in [award::icon]: \"[award::icon_state || "null"]\"")
		if(!(award::category in GLOB.achievement_categories))
			TEST_FAIL("[award] has unsupported category: \"[award::category || "null"]\". Update GLOB.achievement_categories")
		if(length(award::database_id) > 32) //sql schema limit
			TEST_FAIL("[award] database id is too long")
		else if(!award::database_id)
			TEST_FAIL("[award] doesn't have a database id")
			continue
		if(collected_ids[award::database_id])
			TEST_FAIL("There's already an award with same database id as [award]")
		collected_ids[award::database_id] = TRUE


///Check that non-abstract maintenance themes have an id, name and icon
/datum/unit_test/unlockable_themes

/datum/unit_test/unlockable_themes/Run()
	var/list/collected_ids = list()
	for(var/datum/computer_file/program/maintenance/theme/theme as anything in typesof(/datum/computer_file/program/maintenance/theme))
		if(theme::abstract_type == theme)
			continue
		if(!theme::theme_name)
			TEST_FAIL("[theme] doesn't have a set name")
		if(!theme::theme_id)
			TEST_FAIL("[theme] doesn't have a set id")
		if(length(theme::theme_id) > 32) //sql schema limit
			TEST_FAIL("[theme] theme id is too long")
		if(!theme::icon || !icon_exists(theme::icon_file, theme::icon))
			TEST_FAIL("[theme] has a non-existent icon in [theme::icon_file]: \"[theme::icon || "null"]\"")
			continue
		if(collected_ids[theme::theme_id])
			TEST_FAIL("There's already a theme with same id as [theme]")
		collected_ids[theme::theme_id] = TRUE
