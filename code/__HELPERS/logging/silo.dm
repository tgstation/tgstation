/proc/log_silo(text)
	if (CONFIG_GET(flag/log_silo))
		WRITE_LOG(GLOB.world_silo_log, "MATS: [text]")
