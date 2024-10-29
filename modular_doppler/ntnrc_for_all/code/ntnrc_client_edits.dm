
/// Enables the chat client to run without using up power.
/datum/computer_file/program/chatclient
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET | PROGRAM_RUNS_WITHOUT_POWER
	power_cell_use = 0
