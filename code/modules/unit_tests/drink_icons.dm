/// Unit tests all glass style datums with icons / icon states that those are valid and not missing.
/datum/unit_test/glass_style_icons
	/// The generic commonplace DMI for all normal drink sprites
	var/generic_drink_loc = 'icons/obj/drinks/drinks.dmi'
	/// The generic commonplace DMI for all mixed drink sprites
	var/generic_mixed_drink_loc = 'icons/obj/drinks/mixed_drinks.dmi'

/datum/unit_test/glass_style_icons/Run()
	for(var/container_type in GLOB.glass_style_singletons)
		for(var/reagent_type in GLOB.glass_style_singletons[container_type])
			var/datum/glass_style/style = GLOB.glass_style_singletons[container_type][reagent_type]
			var/style_icon = style.icon
			var/style_icon_state = style.icon_state

			if(!style_icon_state)
				continue
			if(!style_icon)
				Fail("[style.type] glass style had an icon state ([style_icon_state]) but no icon file.")
				continue
			if(icon_exists(style_icon, style_icon_state))
				continue

			var/was_actually_in = ""
			// For ease of debugging errors, we will check a few generic locations
			// to see if it's just misplaced and the user needs to just correct it
			if(style_icon != generic_mixed_drink_loc && icon_exists(generic_mixed_drink_loc, style_icon_state))
				was_actually_in = "The icon was found in the mixed drinks dmi."
			else if(style_icon != generic_drink_loc && icon_exists(generic_drink_loc, style_icon_state))
				was_actually_in = "The icon was found in the standard drinks dmi."
			// If it wasn't found in either of the generic spots it could be absent or otherwise in another file
			else
				was_actually_in = "The icon may be located in another dmi or is missing."

			Fail("[style.type] glass style had an icon state ([style_icon_state]) not present in its icon ([style_icon]). [was_actually_in]")

/// Unit tests glass subtypes have a valid icon setup
/datum/unit_test/drink_icons

/datum/unit_test/drink_icons/Run()
	for(var/obj/item/reagent_containers/cup/glass/glass_subtypes as anything in subtypesof(/obj/item/reagent_containers/cup))
		var/glass_icon = initial(glass_subtypes.icon)
		var/glass_icon_state = initial(glass_subtypes.icon_state)
		if(icon_exists(glass_icon, glass_icon_state))
			continue
		Fail("[glass_subtypes] had an icon state ([glass_icon_state]) not present in its icon ([glass_icon]).")
