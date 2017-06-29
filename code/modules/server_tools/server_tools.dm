GLOBAL_VAR_INIT(reboot_mode, REBOOT_MODE_NORMAL)	//if the world should request the service to kill it at reboot
GLOBAL_PROTECT(reboot_mode)
GLOBAL_VAR_INIT(service_port, world.params[SERVICE_CMD_PARAM_PORT])

/world/proc/RunningService()
	return params[SERVICE_WORLD_PARAM]

/world/proc/ExportService(command)
	return RunningService() && shell("python code/modules/server_tools/nudge.py [GLOB.service_port] \"[command]\"") == 0

/world/proc/IRCBroadcast(msg)
	ExportService("[SERVICE_REQUEST_IRC_BROADCAST] [msg]")

/world/proc/ServiceEndProcess()
	log_world("Sending shutdown request!");
	sleep(1)	//flush the buffers
	ExportService(SERVICE_REQUEST_KILL_PROCESS)

//called at the exact moment the world is supposed to reboot
/world/proc/ServiceReboot()
	switch(GLOB.reboot_mode)
		if(REBOOT_MODE_HARD)
			to_chat(src, "<span class='boldannounce'>Hard reboot triggered, you will automatically reconnect...</span>")
			ServiceEndProcess()
		if(REBOOT_MODE_SHUTDOWN)
			to_chat(src, "<span class='boldannounce'>The server is shutting down...</span>")
			ServiceEndProcess()
		else
			ExportService(SERVICE_REQUEST_WORLD_REBOOT)	//just let em know
