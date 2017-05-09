GLOBAL_VAR_INIT(reboot_mode, REBOOT_MODE_NORMAL)	//if the world should request the service to kill it at reboot
GLOBAL_PROTECT(reboot_mode)

/world/proc/RunningService()
	return params[SERVER_SERVICE_PARAM]

/world/proc/ExportService(command)
	shell("python tools/nudge.py \"[command]\"")

/world/proc/IRCBroadcast(msg)
	ExportService("irc [msg]")

/world/proc/ServiceReboot()
	switch(GLOB.reboot_mode)
		if(REBOOT_MODE_HARD)
			to_chat(src, "<span class='boldannounce'>Hard reboot triggered, you will automatically reconnect...</span>")
			log_world("Sending shutdown request!");
			sleep(1)	//flush the buffers
			ExportService("killme")
		if(REBOOT_MODE_SHUTDOWN)
			to_chat(src, "<span class='boldannounce'>The server is shutting down...</span>")
			log_world("Deleting world")
			qdel(src)

/world/proc/ServiceCommand(list/params)
	var/sCK = RunningService()
	var/their_sCK = params["serviceCommsKey"]

	if(!their_sCK || their_sCK != sCK)
		return "Invalid comms key!";

	var/command = params["command"]
	if(!command)
		return "No command!"
	
	var/static/last_irc_status = 0
	switch(command)
		if("hard_reboot")
			if(GLOB.reboot_mode != REBOOT_MODE_HARD)
				GLOB.reboot_mode = REBOOT_MODE_HARD
				log_world("Hard reboot requested by service")
				message_admins("The world will hard reboot at the end of the game. Requested by service.")
				SSblackbox.set_val("service_hard_restart", TRUE)
		if("graceful_shutdown")
			if(GLOB.reboot_mode != REBOOT_MODE_SHUTDOWN)
				GLOB.reboot_mode = REBOOT_MODE_SHUTDOWN
				log_world("Shutdown requested by service")
				message_admins("The world will shutdown at the end of the game. Requested by service.")
				SSblackbox.set_val("service_shutdown", TRUE)
		if("world_announce")
			var/msg = params["message"]
			if(!istext(msg) || !msg)
				return "No message set!"
			to_chat(src, "<span class='boldannounce'>[html_encode(msg)]</span>")
		if("irc_check")
			if(time - last_irc_status < IRC_STATUS_THROTTLE)
				return
			last_irc_status = time
			return "[GLOB.clients.len] players on [SSmapping.config.map_name], Mode: [GLOB.master_mode]; Round [SSticker.HasRoundStarted() ? (SSticker.IsRoundInProgress() ? "Active" : "Finishing") : "Starting"] -- [config.server ? config.server : "byond://[address]:[port]"]" 
		if("irc_status")
			if(time - last_irc_status < IRC_STATUS_THROTTLE)
				return
			last_irc_status = time
			var/list/adm = get_admin_counts()
			var/list/allmins = adm["total"]
			var/status = "Admins: [allmins.len] (Active: [english_list(adm["present"])] AFK: [english_list(adm["afk"])] Stealth: [english_list(adm["stealth"])] Skipped: [english_list(adm["noflags"])]). "
			status += "Players: [GLOB.clients.len] (Active: [get_active_player_count(0,1,0)]). Mode: [SSticker.mode ? SSticker.mode.name : "Not started"]."
			return status

		if("adminmsg")
			return IrcPm(params["target"], params["message"], params["sender"])

		if("namecheck")
			//TODO
			log_admin("IRC Name Check: [params["sender"]] on [params["target"]]")
			message_admins("IRC name checking on [params["target"]] from [params["sender"]]")
			return keywords_lookup(params["target"], 1)
		if("adminwho")
			return ircadminwho()
		else
			return "Unknown command: [command]"

