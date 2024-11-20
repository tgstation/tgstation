
/// Conversation subtype that doesn't allow for the addition of any single operator. Netadmin mode can still override.
/datum/ntnet_conversation/common

/// Override to block adding an operator.
/datum/ntnet_conversation/common/changeop(datum/computer_file/program/chatclient/newop, silent = FALSE)
	return
