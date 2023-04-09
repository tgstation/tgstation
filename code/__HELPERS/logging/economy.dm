/proc/log_econ(text)
	if (CONFIG_GET(flag/log_econ))
		WRITE_LOG(GLOB.world_econ_log, "MONEY: [text]")
