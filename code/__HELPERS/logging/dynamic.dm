/// Logging for dynamic procs
/proc/log_dynamic(text)
	WRITE_LOG(GLOB.dynamic_log, "DYNAMIC: [text]")
