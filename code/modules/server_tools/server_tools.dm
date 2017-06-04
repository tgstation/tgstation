GLOBAL_VAR_INIT(reboot_mode, REBOOT_MODE_NORMAL)	//if the world should request the service to kill it at reboot
GLOBAL_PROTECT(reboot_mode)

/world/proc/RunningService()
	return params[SERVICE_WORLD_PARAM]

/world/proc/ExportService(command)
	return shell("python code/modules/server_tools/nudge.py \"[command]\"") == 0

/world/proc/IRCBroadcast(msg)
	ExportService("[SERVICE_REQUEST_IRC_BROADCAST] [msg]")

//called at the exact moment the world is supposed to reboot
/world/proc/ServiceReboot()
	switch(GLOB.reboot_mode)
		if(REBOOT_MODE_HARD)
			to_chat(src, "<span class='boldannounce'>Hard reboot triggered, you will automatically reconnect...</span>")
			log_world("Sending shutdown request!");
			sleep(1)	//flush the buffers
			ExportService(SERVICE_REQUEST_KILL_PROCESS)
		if(REBOOT_MODE_SHUTDOWN)
			to_chat(src, "<span class='boldannounce'>The server is shutting down...</span>")
			log_world("Deleting world")
			qdel(src)

/world/proc/ServiceCommand(list/params)
	var/sCK = RunningService()
	var/their_sCK = params[SERVICE_CMD_PARAM_KEY]

	if(!their_sCK || their_sCK != sCK)
		return "Invalid comms key!";

	var/command = params[SERVICE_CMD_PARAM_COMMAND]
	if(!command)
		return "No command!"
	
	var/static/last_irc_status = 0
	switch(command)
		if(SERVICE_CMD_HARD_REBOOT)
			if(GLOB.reboot_mode != REBOOT_MODE_HARD)
				GLOB.reboot_mode = REBOOT_MODE_HARD
				log_world("Hard reboot requested by service")
				message_admins("The world will hard reboot at the end of the game. Requested by service.")
				SSblackbox.set_val("service_hard_restart", TRUE)
		if(SERVICE_CMD_GRACEFUL_SHUTDOWN)
			if(GLOB.reboot_mode != REBOOT_MODE_SHUTDOWN)
				GLOB.reboot_mode = REBOOT_MODE_SHUTDOWN
				log_world("Shutdown requested by service")
				message_admins("The world will shutdown at the end of the game. Requested by service.")
				SSblackbox.set_val("service_shutdown", TRUE)
		if(SERVICE_CMD_WORLD_ANNOUNCE)
			var/msg = params["message"]
			if(!istext(msg) || !msg)
				return "No message set!"
			to_chat(src, "<span class='boldannounce'>[html_encode(msg)]</span>")
			return "SUCCESS"
		if(SERVICE_CMD_IRC_STATUS)
			var/rtod = REALTIMEOFDAY
			if(rtod - last_irc_status < IRC_STATUS_THROTTLE)
				return
			last_irc_status = rtod
			var/list/adm = get_admin_counts()
			var/list/allmins = adm["total"]
			var/status = "Admins: [allmins.len] (Active: [english_list(adm["present"])] AFK: [english_list(adm["afk"])] Stealth: [english_list(adm["stealth"])] Skipped: [english_list(adm["noflags"])]). "
			status += "Players: [GLOB.clients.len] (Active: [get_active_player_count(0,1,0)]). Mode: [SSticker.mode ? SSticker.mode.name : "Not started"]."
			return status

		if(SERVICE_CMD_ADMIN_MSG)
			return IrcPm(params[SERVICE_CMD_PARAM_TARGET], params[SERVICE_CMD_PARAM_MESSAGE], params[SERVICE_CMD_PARAM_SENDER])

		if(SERVICE_CMD_NAME_CHECK)
			log_admin("IRC Name Check: [params[SERVICE_CMD_PARAM_SENDER]] on [params[SERVICE_CMD_PARAM_TARGET]]")
			message_admins("IRC name checking on [params[SERVICE_CMD_PARAM_TARGET]] from [params[SERVICE_CMD_PARAM_SENDER]]")
			return keywords_lookup(params[SERVICE_CMD_PARAM_TARGET], 1)
		if(SERVICE_CMD_ADMIN_WHO)
			return ircadminwho()
		else
			return "Unknown command: [command]"

