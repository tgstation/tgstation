/obj/machinery/modular_computer/initial_data()
	return cpu ? cpu.get_header_data() : ..()

/obj/item/modular_computer/initial_data()
	return get_header_data()

/obj/machinery/modular_computer/update_layout()
	return TRUE

/obj/item/modular_computer/update_layout()
	return TRUE

/datum/nano_module/program
	available_to_ai = FALSE
	var/datum/computer_file/program/program = null	// Program-Based computer program that runs this nano module. Defaults to null.

/datum/nano_module/program/New(var/host, var/topic_manager, var/program)
	..()
	src.program = program

/datum/topic_manager/program
	var/datum/program

/datum/topic_manager/program/New(var/datum/program)
	..()
	src.program = program

// Calls forwarded to PROGRAM itself should begin with "PRG_"
// Calls forwarded to COMPUTER running the program should begin with "PC_"
/datum/topic_manager/program/Topic(href, href_list)
	return program && program.Topic(href, href_list)
