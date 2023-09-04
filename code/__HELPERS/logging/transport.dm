/// Logging for transport (tram/elevator) actions
/proc/log_transport(text, list/data)
	logger.Log(LOG_CATEGORY_TRANSPORT, text, data)
