
/// Enables the chat client to run without using up power.
/datum/computer_file/program/chatclient
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET | PROGRAM_RUNS_WITHOUT_POWER
	power_cell_use = 0

/datum/computer_file/program/chatclient/on_start(mob/living/user)
	. = ..()
	if(!.)
		return

	// If we're already in the common chat, start with it open.
	if((src in SSmodular_computers.common_chat.active_clients) || (src in SSmodular_computers.common_chat.offline_clients))
		active_channel = SSmodular_computers.common_chat.id
