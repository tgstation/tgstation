#define TABLET_SCANNER_NONE "None"
#define TABLET_SCANNER_MEDICAL "Medical"
#define TABLET_SCANNER_REAGENT "Reagent"

/datum/computer_file/program/phys_scanner
	filename = "phys_scanner"
	filedesc = "Physical Scanner"
	category = PROGRAM_CATEGORY_MISC
	extended_desc = "This program allows the tablet to scan physical objects and display a data output."
	size = 8
	usage_flags = PROGRAM_TABLET
	available_on_ntnet = FALSE
	tgui_id = "NtosPhysScanner"
	program_icon = "barcode"

	var/set_mode = TABLET_SCANNER_NONE
	var/current_mode = TABLET_SCANNER_NONE

/datum/computer_file/program/phys_scanner/medical
	filedesc = "Medical Scanner"
	filename = "medscanner"
	set_mode = TABLET_SCANNER_MEDICAL

/datum/computer_file/program/phys_scanner/reagent
	filedesc = "Reagent Scanner"
	filename = "reagscanner"
	set_mode = TABLET_SCANNER_REAGENT

/datum/computer_file/program/phys_scanner/tap(atom/A, mob/living/user, params)
	. = ..()

	switch(current_mode)
		if(TABLET_SCANNER_REAGENT)
			if(!isnull(A.reagents))
				if(A.reagents.reagent_list.len > 0)
					var/reagents_length = A.reagents.reagent_list.len
					to_chat(user, span_notice("[reagents_length] chemical agent[reagents_length > 1 ? "s" : ""] found."))
					for (var/re in A.reagents.reagent_list)
						to_chat(user, span_notice("\t [re]"))
				else
					to_chat(user, span_notice("No active chemical agents found in [A]."))
			else
				to_chat(user, span_notice("No significant chemical agents found in [A]."))
		if(TABLET_SCANNER_MEDICAL)
			var/mob/living/carbon/carbon = A
			if(istype(carbon))
				carbon.visible_message(span_notice("[user] analyzes [A]'s vitals."))
				healthscan(user, carbon, 1)

/datum/computer_file/program/phys_scanner/ui_data(mob/user)
	var/list/data = get_header_data()

	data["set_mode"] = set_mode

	return data

/datum/computer_file/program/phys_scanner/run_program(mob/living/user)
	. = ..()

	current_mode = set_mode

/datum/computer_file/program/phys_scanner/kill_program(forced = FALSE)
	. = ..()

	current_mode = TABLET_SCANNER_NONE
