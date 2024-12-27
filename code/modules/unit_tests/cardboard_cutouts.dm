/// Validates that cardboard cutouts have the proper icons
/datum/unit_test/cardboard_cutouts

/datum/unit_test/cardboard_cutouts/Run()
	for(var/datum/cardboard_cutout/cutout as anything in subtypesof(/datum/cardboard_cutout))
		var/direct_icon = initial(cutout.direct_icon)
		if(isnull(direct_icon)) //these are dynamically generated.
			continue
		var/direct_state = initial(cutout.direct_icon_state)
		if(!icon_exists(direct_icon, direct_state))
			TEST_FAIL("[cutout] has a non-existant icon state at: [direct_icon] - [direct_state]")

	var/obj/item/cardboard_cutout/normal_cutout = new
	test_screenshot("normal_cutout", getFlatIcon(normal_cutout))

	var/obj/item/cardboard_cutout/nuclear_operative/nukie_cutout = new
	test_screenshot("nukie_cutout", getFlatIcon(nukie_cutout))

	nukie_cutout.push_over()
	test_screenshot("nukie_cutout_pushed", getFlatIcon(nukie_cutout))

	// This is the only reason we're testing xenomorphs.
	// Making a custom subtype with direct_icon is hacky.
	ASSERT(!isnull(/datum/cardboard_cutout/xenomorph_maid::direct_icon))

	var/obj/item/cardboard_cutout/xenomorph/xenomorph_cutout = new
	test_screenshot("xenomorph_cutout", getFlatIcon(xenomorph_cutout))
