/proc/copy_logs()
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/copy_logs() called tick#: [world.time]")
	if(config.copy_logs)
		ext_python("copy_logs.py", "data/logs \"[config.copy_logs]\"")