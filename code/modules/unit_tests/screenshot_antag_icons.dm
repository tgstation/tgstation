/// A screenshot test to make sure every antag icon in the preferences menu is consistent
/datum/unit_test/screenshot_antag_icons

/datum/unit_test/screenshot_antag_icons/Run()
	var/datum/asset/spritesheet/antagonists/antagonists = get_asset_datum(/datum/asset/spritesheet/antagonists)

	for (var/antag_icon_key in antagonists.antag_icons)
		var/icon/reference_icon = antagonists.antag_icons[antag_icon_key]

		var/icon/icon = new()
		icon.Insert(reference_icon, null, SOUTH, 1)
		test_screenshot(antag_icon_key, icon)
