/// Validates that cardboard cutouts have the proper icons
/datum/unit_test/cardboard_cutouts

/datum/unit_test/cardboard_cutouts/Run()
	var/obj/item/cardboard_cutout/normal_cutout = new
	test_screenshot("normal_cutout", getFlatIcon(normal_cutout))

	var/obj/item/cardboard_cutout/nuclear_operative/nukie_cutout = new
	test_screenshot("nukie_cutout", getFlatIcon(nukie_cutout))

	nukie_cutout.push_over()
	test_screenshot("nukie_cutout_pushed", getFlatIcon(nukie_cutout))

#if DM_VERSION >= 515
	// This is the only reason we're testing xenomorphs.
	// Making a custom subtype with direct_icon is hacky.
	ASSERT(!isnull(/datum/cardboard_cutout/xenomorph_maid::direct_icon))
#endif

	var/obj/item/cardboard_cutout/xenomorph/xenomorph_cutout = new
	test_screenshot("xenomorph_cutout", getFlatIcon(xenomorph_cutout))

/obj/item/cardboard_cutout/nuclear_operative
	starting_cutout = "Nuclear Operative"

/obj/item/cardboard_cutout/xenomorph
	starting_cutout = "Xenomorph"
