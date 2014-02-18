/proc/copy_logs(var/where)
	if(config.copy_logs)
		ext_python("copy_logs.py", "data/logs \"[config.copy_logs]\"")