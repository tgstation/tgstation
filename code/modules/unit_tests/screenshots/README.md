This folder contains the results for screenshot tests. Screenshot tests make sure an icon looks the same as it did before a change to prevent regressions.

You can create one by simply using the `test_screenshot` proc.

This example test screenshots a red image and keeps it.

```dm
/// This is an example for screenshot tests, and a meta-test to make sure they work in the success case.
/// It creates a picture that is red on the left side, green on the other.
/datum/unit_test/screenshot_basic

/datum/unit_test/screenshot_basic/Run()
	var/icon/red = icon('icons/blanks/32x32.dmi', "nothing")
	red.Blend(COLOR_RED, ICON_OVERLAY)
	test_screenshot("red", red)
```

Unfortunately, screenshot tests are sanest to test through a pull request directly, due to limitations with both DM and GitHub.
