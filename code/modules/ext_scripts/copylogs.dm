/proc/copy_logs(var/where)
	ext_python("copy_logs.py", "data/logs \"[where]\"")