/// Logging for shuttle actions
/proc/log_shuttle(text)
	if (CONFIG_GET(flag/log_shuttle))
		WRITE_LOG(GLOB.world_shuttle_log, "SHUTTLE: [text]")
