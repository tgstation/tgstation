/// Logging for PDA messages sent
/proc/log_pda(text)
	GLOB.logger.Log(LOG_CATEGORY_PDA, text)

/// Logging for newscaster comments
/proc/log_comment(text)
	GLOB.logger.Log(LOG_CATEGORY_PDA_COMMENT, text)

/// Logging for chatting on modular computer channels
/proc/log_chat(text)
	GLOB.logger.Log(LOG_CATEGORY_PDA_CHAT, text)
