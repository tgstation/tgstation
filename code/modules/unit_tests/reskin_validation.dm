/datum/unit_test/reskin_validation

/datum/unit_test/reskin_validation/Run()
	var/list/known_names = list()
	for(var/datum/atom_skin/skin as anything in valid_subtypesof(/datum/atom_skin))
		if(isnull(skin::preview_name))
			TEST_FAIL("Reskin [skin] is missing a preview_name.")
		// preview names are bundled by abstract types
		else if(known_names["[skin::preview_name]-[skin::abstract_type]"])
			TEST_FAIL("Reskin [skin] has a duplicate preview_name [skin::preview_name].")
		else
			known_names["[skin::preview_name]-[skin::abstract_type]"] = TRUE

		if(skin::new_icon && skin::new_icon_state && !icon_exists(skin::new_icon, skin::new_icon_state))
			TEST_FAIL("Reskin [skin] has a new_icon_state [skin::new_icon_state] that does not exist in file [skin::new_icon].")
