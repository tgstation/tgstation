/// A screenshot test to make sure every antag icon in the preferences menu is consistent
/datum/unit_test/screenshot_antag_icons

/datum/unit_test/screenshot_antag_icons/Run()
	var/datum/asset/spritesheet_batched/antagonists/antagonists = get_asset_datum(/datum/asset/spritesheet_batched/antagonists)

	// Generates the spritesheet in /tmp, while also ensuring that ALL icons output to the same size (will error otherwise)
	// Left here in case caching changes somehow and we want a fresh generator
	var/test_icon_filepath = "tmp/antag_icon_screenshot_test.dmi"
	var/list/headless_result = rustg_iconforge_generate_headless(test_icon_filepath, json_encode(antagonists.entries_json), TRUE)
	if(!istype(headless_result))
		TEST_FAIL("Could not generate antagonist icons using rustg_iconforge_generate_headless! The output format was invalid (JSON did not decode to a list). Got: [headless_result]")
	if(!length(headless_result))
		TEST_FAIL("Could not generate antagonist icons using rustg_iconforge_generate_headless! The output list was empty. Got: [json_encode(headless_result)]")
	if(headless_result["file_path"] != test_icon_filepath)
		TEST_FAIL("Could not generate antagonist icons using rustg_iconforge_generate_headless! The output file_path differed from the input. Got: [json_encode(headless_result)]")
	if(headless_result["width"] != ANTAGONIST_PREVIEW_ICON_SIZE || headless_result["height"] != ANTAGONIST_PREVIEW_ICON_SIZE)
		TEST_FAIL("Could not generate antagonist icons using rustg_iconforge_generate_headless! The output size was not ANTAGONIST_PREVIEW_ICON_SIZE. Got: [json_encode(headless_result)]")
	if(!fexists(test_icon_filepath))
		TEST_FAIL("Could not generate antagonist icons using rustg_iconforge_generate_headless! The output file does not exist on the filesystem! Got: [json_encode(headless_result)]")
	var/icon/test_icon = icon(file(test_icon_filepath))

	for (var/antag_icon_key in antagonists.entries)
		var/icon/icon = icon(test_icon, antag_icon_key, SOUTH, 1)
		test_screenshot(antag_icon_key, icon)
