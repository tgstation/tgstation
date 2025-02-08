
/datum/controller/subsystem/modular_computers
	/// Reference to the common chat used for all crew
	var/datum/ntnet_conversation/ai/ai_chat
	var/datum/ntnet_conversation/common/common_chat

/datum/controller/subsystem/modular_computers/Initialize()
	. = ..()
	ai_chat = new(title = NTNRC_AI_CHAT, strong = TRUE)
	common_chat = new(title = NTNRC_COMMON_CHAT, strong = TRUE)
