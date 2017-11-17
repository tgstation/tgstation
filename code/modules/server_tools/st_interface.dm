SERVER_TOOLS_DEFINE_AND_SET_GLOBAL(reboot_mode, REBOOT_MODE_NORMAL)
SERVER_TOOLS_DEFINE_AND_SET_GLOBAL(server_tools_api_compatible, FALSE)

/proc/GetTestMerges()
	if(RunningService(TRUE) && fexists(SERVICE_PR_TEST_JSON))
		. = json_decode(file2text(SERVICE_PR_TEST_JSON))
		if(.)
			return
	return list()

/world/proc/ServiceInit()
	if(!RunningService(TRUE))
		return
	ListServiceCustomCommands(TRUE)
	ExportService("[SERVICE_REQUEST_API_VERSION] [SERVER_TOOLS_API_VERSION]", TRUE)

/proc/RunningService(skip_compat_check = FALSE)
	return (skip_compat_check || SERVER_TOOLS_READ_GLOBAL(server_tools_api_compatible)) && world.params[SERVICE_WORLD_PARAM] != null

/proc/ServiceVersion()
	if(RunningService(TRUE))
		return world.params[SERVICE_VERSION_PARAM]

/proc/ServiceAPIVersion()
	return SERVICE_API_VERSION_STRING

/world/proc/ExportService(command, skip_compat_check = FALSE)
	. = FALSE
	if(!RunningService(skip_compat_check))
		return
	if(skip_compat_check && !fexists(SERVICE_INTERFACE_DLL))
		CRASH("Service parameter present but no interface DLL detected. This is symptomatic of running a service less than version 3.1! Please upgrade.")
	call(SERVICE_INTERFACE_DLL, SERVICE_INTERFACE_FUNCTION)(command)	//trust no retval
	return TRUE

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
	var/their_sCK = params[SERVICE_CMD_PARAM_KEY]
	if(!their_sCK || !RunningService(TRUE))
		return FALSE	//continue world/Topic

	var/sCK = world.params[SERVICE_WORLD_PARAM]
	if(their_sCK != sCK)
		return "Invalid comms key!";

	var/command = params[SERVICE_CMD_PARAM_COMMAND]
	if(!command)
		return "No command!"

	switch(command)
		if(SERVICE_CMD_API_COMPATIBLE)
			SERVER_TOOLS_WRITE_GLOBAL(server_tools_api_compatible, TRUE)
			return "SUCCESS"
		if(SERVICE_CMD_HARD_REBOOT)
			if(SERVER_TOOLS_READ_GLOBAL(reboot_mode) != REBOOT_MODE_HARD)
				SERVER_TOOLS_WRITE_GLOBAL(reboot_mode, REBOOT_MODE_HARD)
				SERVER_TOOLS_LOG("Hard reboot requested by service")
				SERVER_TOOLS_NOTIFY_ADMINS("The world will hard reboot at the end of the game. Requested by service.")
		if(SERVICE_CMD_GRACEFUL_SHUTDOWN)
			if(SERVER_TOOLS_READ_GLOBAL(reboot_mode) != REBOOT_MODE_SHUTDOWN)
				SERVER_TOOLS_WRITE_GLOBAL(reboot_mode, REBOOT_MODE_SHUTDOWN)
				SERVER_TOOLS_LOG("Shutdown requested by service")
				message_admins("The world will shutdown at the end of the game. Requested by service.")
		if(SERVICE_CMD_WORLD_ANNOUNCE)
			var/msg = params["message"]
			if(!istext(msg) || !msg)
				return "No message set!"
			SERVER_TOOLS_WORLD_ANNOUNCE(msg)
			return "SUCCESS"
		if(SERVICE_CMD_PLAYER_COUNT)
			return "[SERVER_TOOLS_CLIENT_COUNT]"
		if(SERVICE_CMD_LIST_CUSTOM)
			return json_encode(ListServiceCustomCommands(FALSE))
		else
			var/custom_command_result = HandleServiceCustomCommand(lowertext(command), params[SERVICE_CMD_PARAM_SENDER], params[SERVICE_CMD_PARAM_CUSTOM])
			if(custom_command_result)
				return istext(custom_command_result) ? custom_command_result : "SUCCESS"
			return "Unknown command: [command]"

/*
The MIT License

Copyright (c) 2011 Dominic Tarr

Permission is hereby granted, free of charge, 
to any person obtaining a copy of this software and 
associated documentation files (the "Software"), to 
deal in the Software without restriction, including 
without limitation the rights to use, copy, modify, 
merge, publish, distribute, sublicense, and/or sell 
copies of the Software, and to permit persons to whom 
the Software is furnished to do so, 
subject to the following conditions:

The above copyright notice and this permission notice 
shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR 
ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
