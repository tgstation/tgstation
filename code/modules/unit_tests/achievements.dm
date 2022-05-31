///Checks that all achievements have an existing icon state in the achievements icon file.
/datum/unit_test/achievements

/datum/unit_test/achievements/Run()
	var/award_icons = icon_states(ACHIEVEMENTS_SET)
	for(var/datum/award/award as anything in subtypesof(/datum/award))
		if(!initial(award.name)) //Skip abstract achievements types
			continue
		var/init_icon = initial(award.icon)
		if(!init_icon || !(init_icon in award_icons))
			Fail("Award [initial(award.name)] has an unexistent icon: \"[init_icon || "null"]\"")
