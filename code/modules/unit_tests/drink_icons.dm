/datum/unit_test/drink_icons

/datum/unit_test/drink_icons/Run()
	for(var/container_type in GLOB.glass_style_singletons)
		for(var/reagent_type in GLOB.glass_style_singletons[container_type])
			var/datum/glass_style/style = GLOB.glass_style_singletons[container_type][reagent_type]
			if(icon_exists(style.icon, style.icon_state))
				continue

			Fail("[style.type] glass style had an icon state ([style.icon_state]) not present in its icon ([style.icon]).")
