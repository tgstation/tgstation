/// This is an example for screenshot tests, and a meta-test to make sure they work in the success case.
/// It creates a picture that is red on the left side, green on the other.
/datum/unit_test/screenshot_basic

/datum/unit_test/screenshot_basic/Run()
	var/icon/red = icon('icons/blanks/32x32.dmi', "nothing")
	red.Blend(COLOR_RED, ICON_OVERLAY)
	test_screenshot("red", red)
