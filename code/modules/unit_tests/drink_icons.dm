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
				TEST_FAIL("[style.type] glass style had an icon state ([style_icon_state]) but no icon file.")
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

			TEST_FAIL("[style.type] glass style had an icon state ([style_icon_state]) not present in its icon ([style_icon]). [was_actually_in]")

/// Unit tests glass style datums are applied to drinking glasses
/datum/unit_test/glass_style_functionality

/datum/unit_test/glass_style_functionality/Run()
	// The tested drink
	// Should ideally have multiple drinking glass datums associated (to check the correct one is seletced)
	// As well as a value set from every var (name, description, icon, and icon state)
	var/tested_reagent_type = /datum/reagent/consumable/ethanol/jack_rose
	var/obj/item/reagent_containers/cup/glass/drinkingglass/glass = allocate(/obj/item/reagent_containers/cup/glass/drinkingglass)
	var/datum/glass_style/expected_glass_type = GLOB.glass_style_singletons[glass.type][tested_reagent_type]
	TEST_ASSERT_NOTNULL(expected_glass_type, "Glass style datum for the tested reagent ([tested_reagent_type]) and container ([glass.type]) was not found.")

	// Add 5 units of the reagent to the glass. This will change the name, desc, icon, and icon state
	glass.reagents.add_reagent(tested_reagent_type, 5)
	TEST_ASSERT_EQUAL(glass.icon, expected_glass_type.icon, "Glass icon file did not change after gaining a reagent that would change it.")
	TEST_ASSERT_EQUAL(glass.icon_state, expected_glass_type.icon_state, "Glass icon state did not change after gaining a reagent that would change it")
	TEST_ASSERT_EQUAL(glass.name, expected_glass_type.name, "Glass name did not change after gaining a reagent that would change it")
	TEST_ASSERT_EQUAL(glass.desc, expected_glass_type.desc, "Glass desc did not change after gaining a reagent that would change it")
	// Clear all units from the glass, This will reset all the previously changed values
	glass.reagents.clear_reagents()
	TEST_ASSERT_EQUAL(glass.icon, initial(glass.icon), "Glass icon file did not reset after clearing reagents")
	TEST_ASSERT_EQUAL(glass.icon_state, initial(glass.icon_state), "Glass icon state did not reset after clearing reagents")
	TEST_ASSERT_EQUAL(glass.name, initial(glass.name), "Glass name did not reset after clearing reagents")
	TEST_ASSERT_EQUAL(glass.desc, initial(glass.desc), "Glass desc did not reset after clearing reagents")

/// Unit tests glass subtypes have a valid icon setup
/datum/unit_test/drink_icons

/datum/unit_test/drink_icons/Run()
	for(var/obj/item/reagent_containers/cup/glass/glass_subtypes as anything in subtypesof(/obj/item/reagent_containers/cup))
		var/glass_icon
		var/glass_icon_state
		if(glass_subtypes::greyscale_config)
			var/datum/greyscale_config/greyscale_config = glass_subtypes::greyscale_config
			glass_icon = greyscale_config::icon_file
			glass_icon_state = glass_subtypes::post_init_icon_state
		else
			glass_icon = glass_subtypes::icon
			glass_icon_state = glass_subtypes::icon_state
		if(!glass_icon_state)
			continue
		if(!glass_icon)
			TEST_FAIL("[glass_subtypes] had an icon state ([glass_icon_state]) but no icon file.")
			continue
		if(icon_exists(glass_icon, glass_icon_state))
			continue
		TEST_FAIL("[glass_subtypes] had an icon state ([glass_icon_state]) not present in its icon ([glass_icon]).")
