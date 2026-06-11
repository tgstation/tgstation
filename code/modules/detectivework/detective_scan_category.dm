GLOBAL_LIST_INIT_TYPED(detective_scan_categories, /datum/detective_scan_category, initialize_detective_scan_categories())

/proc/initialize_detective_scan_categories()
	var/list/categories = list()
	for(var/datum/detective_scan_category/category_path as anything in subtypesof(/datum/detective_scan_category))
		var/datum/detective_scan_category/existing_category = categories[category_path::id]
		if(!isnull(existing_category))
			stack_trace("`[category_path]` has duplicate id - `[category_path::id]` of `[existing_category.type]`")
			continue

		categories[category_path::id] = new category_path

	return categories

/datum/detective_scan_category
	/// Category ID. Must be defined in `code/__DEFINES/security.dm`
	var/id = "no id"
	/// Name of scan category. Used in UIs and in paper
	var/name = "no name"
	/// Order the data with this category will be sorted by
	var/display_order = 0
	/// Fontawesome icon used in TGUI near this category data entry
	var/ui_icon = "question"
	/// Fontawesome icon color used in TGUI near this category data entry
	var/ui_icon_color = "white"

/// Generates report data used in `/datum/detective_scanner_log/proc/generate_report_text()`
/datum/detective_scan_category/proc/generate_report_data(list/data)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/list/report_text = list()
	report_text += "<dt><b>[name]</b></dt><dd>"

	for(var/entry in data)
		report_text += format_report_entry(entry, data[entry])

	report_text += "</dd>"
	return report_text

/// Formats entered log data. Can be used to have unique formating per each category
/datum/detective_scan_category/proc/format_report_entry(entry, entry_associated_value)
	return "[entry]<br>"

/datum/detective_scan_category/fingers
	id = DETSCAN_CATEGORY_FINGERS
	name = "Fingerprints"
	display_order = 1
	ui_icon = "fingerprint"
	ui_icon_color = "yellow"

/datum/detective_scan_category/blood
	id = DETSCAN_CATEGORY_BLOOD
	name = "Blood DNA, Type"
	display_order = 2
	ui_icon = "droplet"
	ui_icon_color = "red"

/datum/detective_scan_category/blood/format_report_entry(entry, entry_associated_value)
	return "[entry], [entry_associated_value]<br>"

/datum/detective_scan_category/fiber
	id = DETSCAN_CATEGORY_FIBER
	name = "Fibers"
	display_order = 3
	ui_icon = "shirt"
	ui_icon_color = "green"

/datum/detective_scan_category/drink
	id = DETSCAN_CATEGORY_REAGENTS
	name = "Reagents"
	display_order = 4
	ui_icon = "flask"
	ui_icon_color = "blue"

/datum/detective_scan_category/drink/format_report_entry(entry, entry_associated_value)
	return "<b>[entry]</b>: [entry_associated_value] u.<br>"

/datum/detective_scan_category/access
	id = DETSCAN_CATEGORY_ACCESS
	name = "ID Access"
	display_order = 5
	ui_icon = "id-card"
	ui_icon_color = "blue"

/datum/detective_scan_category/access/format_report_entry(entry, entry_associated_value)
	var/list/associated_value_list = entry_associated_value
	return "<b>[entry]</b>: [associated_value_list]<br>"

/datum/detective_scan_category/setting
	id = DETSCAN_CATEGORY_SETTINGS
	name = "Active settings"
	display_order = 6
	ui_icon = "wrench"
	ui_icon_color = "orange"

/datum/detective_scan_category/holy
	id = DETSCAN_CATEGORY_HOLY
	name = "Holy data"
	display_order = 7
	ui_icon = "book-bible"
	ui_icon_color = "brown"

/datum/detective_scan_category/illegal
	id = DETSCAN_CATEGORY_ILLEGAL
	name = "Illegal tech"
	display_order = 8
	ui_icon = "handcuffs"
	ui_icon_color = "red"

/datum/detective_scan_category/notes
	id = DETSCAN_CATEGORY_NOTES
	name = "Additional notes"
	ui_icon = "clipboard"
	ui_icon_color = "yellow"
	display_order = 9
