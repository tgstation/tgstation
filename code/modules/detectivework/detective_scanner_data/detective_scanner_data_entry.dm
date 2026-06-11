/proc/cmp_detective_scanner_data_entry(datum/detective_scanner_data_entry/a, datum/detective_scanner_data_entry/b)
	return cmp_numeric_asc(a.display_order, b.display_order)

/datum/detective_scanner_data_entry
	/// Category this data entry is related to
	var/category
	/// Order this entry will be displayed in TGUI and paper report
	var/display_order = 0
	/// List of data for this entry. Displayed in UIs and paper report
	var/list/data = list()

/datum/detective_scanner_data_entry/New(category, display_order, data)
	src.category = category
	src.display_order = display_order
	if(!isnull(data))
		src.data += data

/datum/detective_scanner_data_entry/ui_data(mob/user)
	var/list/ui_data = list()
	ui_data["category"] = category
	ui_data["data"] = data
	return ui_data

/datum/detective_scanner_data_entry/proc/add_data(data)
	src.data += data
