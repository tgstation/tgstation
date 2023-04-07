/**
 * This unit test verifies that all Font Awesome icons are present in code, and that all quirk icons are valid.
 */
/datum/unit_test/font_awesome_icons
	var/list/allowed_icons

/datum/unit_test/font_awesome_icons/Run()
	load_parse_verify()
	verify_quirk_icons()

/**
 * Loads the Font Awesome CSS file, parses it into a list of icon names, and compares it to the list of icons in code.
 * If there are any differences, note them.
 */
/datum/unit_test/font_awesome_icons/proc/load_parse_verify()
	var/css = file2text("html/font-awesome/css/all.min.css")
	var/list/icons = parse_fa_css_into_icon_list(css)

	var/list/actual = list()
	for(var/datum/font_awesome_icon/icon as anything in subtypesof(/datum/font_awesome_icon))
		var/icon_class = initial(icon.name)
		if(icon_class in actual)
			TEST_FAIL("Font Awesome helper datum for icon 'fa-[icon_class]' is defined multiple times. ([icon])")
			continue
		actual += icon_class

	var/list/diff = icons - actual
	if(length(diff))
		TEST_FAIL("Icons in Font Awesome are missing in code: [english_list(diff)]")

	diff = actual - icons
	if(length(diff))
		TEST_FAIL("Icons in code are not present in Font Awesome: [english_list(diff)]")

	allowed_icons = icons

/**
 * Verifies that all quirk icons are valid.
 */
/datum/unit_test/font_awesome_icons/proc/verify_quirk_icons()
	for(var/datum/quirk/quirk as anything in subtypesof(/datum/quirk))
		if(quirk == initial(quirk.abstract_parent_type))
			continue

		var/quirk_icon = initial(quirk.icon)
		if(findtext(quirk_icon, " "))
			var/list/split = splittext(quirk_icon, " ")
			quirk_icon = split[length(split)] // respect modifier classes

		if(findtext(quirk_icon, "tg-") == 1)
			continue

		if(!(quirk_icon in allowed_icons))
			TEST_FAIL("Quirk [initial(quirk.name)]([quirk]) has invalid icon: [quirk_icon]")

/// Parses the given Font Awesome CSS file into a list of icon names.
/datum/unit_test/font_awesome_icons/proc/parse_fa_css_into_icon_list(css)
	css = replacetext(css, "\n", "")
	var/list/css_entries = splittext(css, "}")
	var/list/icons = list()
	for(var/entry in css_entries)
		entry = replacetext(entry, "\t", "")
		if(!length(entry))
			continue

		var/entry_contents = splittext(entry, "{")
		var/list/entry_names = splittext(entry_contents[1], ",")
		for(var/entry_name in entry_names)
			entry_names -= entry_name

			if(!findtext(entry_name, ":"))
				continue

			entry_name = splittext(entry_name, ":")[1]
			if(!findtext(entry_name, ".fa-"))
				continue

			entry_name = replacetext(entry_name, ".fa-", "")
			entry_names |= entry_name
		icons |= entry_names

	return sort_list(icons)
