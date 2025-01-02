
/datum/controller/subsystem/modular_computers
	/// Reference to the common chat used for all crew
	var/datum/ntnet_conversation/common/common_chat

/datum/controller/subsystem/modular_computers/Initialize()
	. = ..()
	common_chat = new(title = NTNRC_COMMON_CHAT, strong = TRUE)
