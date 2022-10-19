/// Logging for PDA messages sent
/proc/log_pda(text)
	if (CONFIG_GET(flag/log_pda))
		WRITE_LOG(GLOB.world_pda_log, "PDA: [text]")

/// Logging for newscaster comments
/proc/log_comment(text)
	//reusing the PDA option because I really don't think news comments are worth a config option
	if (CONFIG_GET(flag/log_pda))
		WRITE_LOG(GLOB.world_pda_log, "COMMENT: [text]")

/// Logging for chatting on modular computer channels
/proc/log_chat(text)
	//same thing here
	if (CONFIG_GET(flag/log_pda))
		WRITE_LOG(GLOB.world_pda_log, "CHAT: [text]")
