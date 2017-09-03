SERVER_TOOLS_DEFINE_AND_SET_GLOBAL(reboot_mode, REBOOT_MODE_NORMAL)

/proc/GetTestMerges()
	if(world.RunningService())
		var/file_name
		if(ServiceVersion())	//will return null for versions < 3.0.91.0
			file_name = SERVICE_PR_TEST_JSON
		else
			file_name = SERVICE_PR_TEST_JSON_OLD
		if(fexists(file_name))
			. = json_decode(file2text(file_name))
			if(.)
				return
	return list()

/world/proc/RunningService()
	return params[SERVICE_WORLD_PARAM]

/proc/ServiceVersion()
	if(world.RunningService())
		return world.params[SERVICE_VERSION_PARAM]

/world/proc/ExportService(command)
	return RunningService() && shell("python [SERVER_TOOLS_INSTALLATION_PATH]/nudge.py \"[command]\"") == 0

/world/proc/ChatBroadcast(message)
	ExportService("[SERVICE_REQUEST_IRC_BROADCAST] [message]")

/world/proc/AdminBroadcast(message)
	ExportService("[SERVICE_REQUEST_IRC_ADMIN_CHANNEL_MESSAGE] [message]")

/world/proc/ServiceEndProcess()
	SERVER_TOOLS_LOG("Sending shutdown request!");
	sleep(world.tick_lag)	//flush the buffers
	ExportService(SERVICE_REQUEST_KILL_PROCESS)

//called at the exact moment the world is supposed to reboot
/world/proc/ServiceReboot()
	switch(SERVER_TOOLS_READ_GLOBAL(reboot_mode))
		if(REBOOT_MODE_HARD)
			SERVER_TOOLS_WORLD_ANNOUNCE("Hard reboot triggered, you will automatically reconnect...")
			ServiceEndProcess()
		if(REBOOT_MODE_SHUTDOWN)
			SERVER_TOOLS_WORLD_ANNOUNCE("The server is shutting down...")
			ServiceEndProcess()
		else
			ExportService(SERVICE_REQUEST_WORLD_REBOOT)	//just let em know

/world/proc/ServiceCommand(list/params)
	var/sCK = RunningService()
	var/their_sCK = params[SERVICE_CMD_PARAM_KEY]

	if(!their_sCK)
		return FALSE	//continue world/Topic

	if(their_sCK != sCK)
		return "Invalid comms key!";

	var/command = params[SERVICE_CMD_PARAM_COMMAND]
	if(!command)
		return "No command!"

	switch(command)
		if(SERVICE_CMD_HARD_REBOOT)
			if(SERVER_TOOLS_READ_GLOBAL(reboot_mode) != REBOOT_MODE_HARD)
				SERVER_TOOLS_WRITE_GLOBAL(reboot_mode, REBOOT_MODE_HARD)
				SERVER_TOOLS_LOG("Hard reboot requested by service")
				SERVER_TOOLS_NOTIFY_ADMINS("The world will hard reboot at the end of the game. Requested by service.")
		if(SERVICE_CMD_GRACEFUL_SHUTDOWN)
			if(SERVER_TOOLS_READ_GLOBAL(reboot_mode) != REBOOT_MODE_SHUTDOWN)
				GLOB.reboot_mode = REBOOT_MODE_SHUTDOWN
				SERVER_TOOLS_LOG("Shutdown requested by service")
				message_admins("The world will shutdown at the end of the game. Requested by service.")
		if(SERVICE_CMD_WORLD_ANNOUNCE)
			var/msg = params["message"]
			if(!istext(msg) || !msg)
				return "No message set!"
			SERVER_TOOLS_WORLD_ANNOUNCE(msg)
			return "SUCCESS"
		if(SERVICE_CMD_LIST_CUSTOM)
			return json_encode(ListServiceCustomCommands(FALSE))
		else
			var/custom_command_result = HandleServiceCustomCommand(lowertext(command), params[SERVICE_CMD_PARAM_SENDER], params[SERVICE_CMD_PARAM_CUSTOM])
			if(custom_command_result)
				return istext(custom_command_result) ? custom_command_result : "SUCCESS"
			return "Unknown command: [command]"
