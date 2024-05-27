/obj/item/modular_computer/laptop/preset/civilian
	desc = "A low-end laptop often used for personal recreation."
	starting_programs = list(
		/datum/computer_file/program/chatclient,
	)

//Used for Mafia testing purposes.
/obj/item/modular_computer/laptop/preset/mafia
	starting_programs = list(
		/datum/computer_file/program/mafia,
	)

/obj/item/modular_computer/laptop/preset/dispatcher
	internal_cell = /obj/item/stock_parts/cell/hyper //we expect it to be used A LOT
	desc = "An special laptop loaded with applications for keeping informed on station status."
	starting_programs = list(
		/datum/computer_file/program/alarm_monitor,
		/datum/computer_file/program/crew_manifest,
		/datum/computer_file/program/ntnetmonitor,
		/datum/computer_file/program/secureye,
		/datum/computer_file/program/radar/lifeline,
		/datum/computer_file/program/bounty_board,
	)
