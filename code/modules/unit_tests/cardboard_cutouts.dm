/// Validates that cardboard cutouts have the proper icons
/datum/unit_test/cardboard_cutouts

/datum/unit_test/cardboard_cutouts/Run()
	var/obj/item/cardboard_cutout/normal_cutout = new
	test_screenshot("normal_cutout", getFlatIcon(normal_cutout))

	var/obj/item/cardboard_cutout/nuclear_operative/nukie_cutout = new
	test_screenshot("nukie_cutout", getFlatIcon(nukie_cutout))

/obj/item/cardboard_cutout/nuclear_operative
	starting_cutout = "Nuclear Operative"
