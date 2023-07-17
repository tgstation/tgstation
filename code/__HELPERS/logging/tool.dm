/// Logging for tool usage
/proc/log_tool(text, mob/initiator)
	logger.Log(LOG_CATEGORY_TOOL, text, initiator ? list("initiator" = initiator) : null)
