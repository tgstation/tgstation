/proc/copy_logs()
	if(config.copy_logs)
		ext_python("copy_logs.py", "data/logs \"[config.copy_logs]\"")