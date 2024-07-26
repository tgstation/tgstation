/datum/computer_file/program/crew_manifest
	download_access = list()

/obj/item/modular_computer/pda/install_default_programs()
	starting_programs |= /datum/computer_file/program/crew_manifest
	. = ..()
