/datum/computer_file/program/maintenance/phys_scanner
	filename = "phys_scanner"
	filedesc = "Physical Scanner"
	category = PROGRAM_CATEGORY_MISC
	extended_desc = "This program allows the tablet to scan physical objects and display a data output."
	size = 2
	usage_flags = PROGRAM_TABLET
	tgui_id = "NtosPhysScanner"
	program_icon = "barcode"
	/// Information from the last scanned person, to display on the app.
	var/last_record = ""

/datum/computer_file/program/maintenance/phys_scanner/tap(atom/tapped_atom, mob/living/user, params)
	. = ..()

	if(!iscarbon(tapped_atom))
		return
	var/mob/living/carbon/carbon = tapped_atom
	carbon.visible_message(span_notice("[user] analyzes [tapped_atom]'s vitals."))
	last_record = healthscan(user, carbon, 1, tochat = FALSE)

/datum/computer_file/program/maintenance/phys_scanner/ui_data(mob/user)
	var/list/data = list()

	data["last_record"] = last_record
	return data
