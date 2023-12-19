/proc/log_econ(text)
	add_event_to_buffer(data = text, log_key = "ECONOMY")
	if (CONFIG_GET(flag/log_econ))
		WRITE_LOG(GLOB.world_econ_log, "MONEY: [text]")
