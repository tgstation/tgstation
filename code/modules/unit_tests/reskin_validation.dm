/datum/unit_test/reskin_validation

/datum/unit_test/reskin_validation/Run()
	for(var/datum/atom_skin/skin as anything in valid_subtypesof(/datum/atom_skin))
		if(isnull(skin::preview_name))
			TEST_FAIL("Reskin [skin] is missing a preview_name.")

		if(skin::new_icon && skin::new_icon_state && !icon_exists(skin::new_icon, skin::new_icon_state))
			TEST_FAIL("Reskin [skin] has a new_icon_state [skin::new_icon_state] that does not exist in file [skin::new_icon].")
