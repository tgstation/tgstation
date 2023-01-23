/// A screenshot test for specific dynamic human icons
/datum/unit_test/screenshot_dynamic_human_icons

/datum/unit_test/screenshot_dynamic_human_icons/Run()
	// Complicated MODsuit setup
	var/icon/icon = get_dynamic_human_icon(/datum/outfit/syndicatecommandocorpse)
	test_screenshot("syndicate_commando", icon)
