/datum/unit_test/achievements

/datum/unit_test/achievements/Run()
	for(var/datum/award/award as anything in subtypesof(/datum/award))
		if(!initial(award.name)) //Skip abstract achievements types
			continue
		var/init_icon_path = initial(award.icon_path)
		if(!init_icon_path || !fexists(file("icons/ui_icons/achievements/[init_icon_path]")))
			Fail("Award [initial(award.name)] has an unexistent icon_path: [init_icon_path || "NONE!"]")
