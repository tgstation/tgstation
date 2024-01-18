/// Logging for shuttle actions
/proc/log_shuttle(text, list/data)
	logger.Log(LOG_CATEGORY_SHUTTLE, text, data)
