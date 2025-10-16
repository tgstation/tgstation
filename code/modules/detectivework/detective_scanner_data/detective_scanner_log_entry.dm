/datum/detective_scanner_log
	/// Name of the scanned atom
	var/scan_target
	/// Time the scan was performed at
	var/scan_time
	/// `data_entries` is an assoc list, which can't use `BINARY_INSERT`
	/// And to not perform sorting pipeline every time new data is added,
	/// this var will be utilized to only sort list when it's required
	var/sorted = TRUE
	/// Scan data for current log
	var/list/data_entries = list()

/datum/detective_scanner_log/ui_data(mob/user)
	var/list/ui_data = list()
	ui_data["scanTarget"] = scan_target
	ui_data["scanTime"] = scan_time

	sort_data_entries()
	var/list/data_entries_ui_data = list()
	for(var/key,value in data_entries)
		var/datum/detective_scanner_data_entry/entry = value
		UNTYPED_LIST_ADD(data_entries_ui_data, entry.ui_data(user))

	ui_data["dataEntries"] = data_entries_ui_data
	return ui_data

/// Adds new data entry to `data_entries` or updates existing one
/// Entries will be not sorted after using it
/// Returns TRUE if `data_entries` can be unsorted
/datum/detective_scanner_log/proc/add_data_entry(scan_category_id, data)
	var/datum/detective_scan_category/category = GLOB.detective_scan_categories[scan_category_id]
	if(isnull(category))
		stack_trace("scan_category_id - `[scan_category_id]` with no corresponding `/datum/detective_scan_category`")
		category = GLOB.detective_scan_categories[DETSCAN_CATEGORY_NOTES]

	var/datum/detective_scanner_data_entry/data_entry = data_entries[category.id]
	if(!isnull(data_entry))
		data_entry.add_data(data)
		return

	data_entries[scan_category_id] = new /datum/detective_scanner_data_entry(scan_category_id, category.display_order, data)
	sorted = (length(data_entries) <= 1)

/// Sorts the `data_entries` list if it's considered not sorted
/datum/detective_scanner_log/proc/sort_data_entries()
	if(!sorted)
		sortTim(data_entries, GLOBAL_PROC_REF(cmp_detective_scanner_data_entry), TRUE)
		sorted = TRUE

/// Return text that will be used in printed paper report
/// Called in `/obj/item/detective_scanner/proc/print_report()`
/datum/detective_scanner_log/proc/generate_report_text()
	var/list/report_text = list()
	report_text += "<h2>[capitalize(scan_target)] scan at [scan_time]</h2><dr>"
	if(!length(data_entries))
		report_text += "No forensic traces found."
	else
		sort_data_entries()
		for(var/log_category,data_entry in data_entries)
			var/datum/detective_scanner_data_entry/data_entry_datum = data_entry
			report_text += GLOB.detective_scan_categories[log_category].generate_report_data(data_entry_datum.data)

	report_text += "</dl><hr>"

	return report_text
