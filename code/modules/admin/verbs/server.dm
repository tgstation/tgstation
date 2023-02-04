// Server Tab - Server Verbs


ADMIN_VERB(server, toggle_random_events, "Toggles random events such as meteors, black holes, blob (but not space dust) on/off", R_SERVER)
	var/new_are = !CONFIG_GET(flag/allow_random_events)
	CONFIG_SET(flag/allow_random_events, new_are)
	message_admins("[key_name_admin(usr)] has [new_are ? "enabled" : "disabled"] random events.")

ADMIN_VERB(server, toggle_hub, "", R_SERVER)
	world.update_hub_visibility(!GLOB.hub_visibility)

	log_admin("[key_name(usr)] has toggled the server's hub status for the round, it is now [(GLOB.hub_visibility?"on":"off")] the hub.")
	message_admins("[key_name_admin(usr)] has toggled the server's hub status for the round, it is now [(GLOB.hub_visibility?"on":"off")] the hub.")
	if (GLOB.hub_visibility && !world.reachable)
		message_admins("WARNING: The server will not show up on the hub because byond is detecting that a filewall is blocking incoming connections.")

ADMIN_VERB(server, reboot_world, "Restarts the world immediately", R_SERVER)
	var/localhost_addresses = list("127.0.0.1", "::1")
	var/list/options = list("Regular Restart", "Regular Restart (with delay)", "Hard Restart (No Delay/Feeback Reason)", "Hardest Restart (No actions, just reboot)")
	if(world.TgsAvailable())
		options += "Server Restart (Kill and restart DD)";

	if(SSticker.admin_delay_notice)
		if(alert(usr, "Are you sure? An admin has already delayed the round end for the following reason: [SSticker.admin_delay_notice]", "Confirmation", "Yes", "No") != "Yes")
			return FALSE

	var/result = input(usr, "Select reboot method", "World Reboot", options[1]) as null|anything in options
	if(result)
		var/init_by = "Initiated by [usr.client.holder.fakekey ? "Admin" : usr.key]."
		switch(result)
			if("Regular Restart")
				if(!(isnull(usr.client.address) || (usr.client.address in localhost_addresses)))
					if(alert(usr, "Are you sure you want to restart the server?","This server is live", "Restart", "Cancel") != "Restart")
						return FALSE
				SSticker.Reboot(init_by, "admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]", 10)
			if("Regular Restart (with delay)")
				var/delay = input("What delay should the restart have (in seconds)?", "Restart Delay", 5) as num|null
				if(!delay)
					return FALSE
				if(!(isnull(usr.client.address) || (usr.client.address in localhost_addresses)))
					if(alert(usr,"Are you sure you want to restart the server?","This server is live", "Restart", "Cancel") != "Restart")
						return FALSE
				SSticker.Reboot(init_by, "admin reboot - by [usr.key] [usr.client.holder.fakekey ? "(stealth)" : ""]", delay * 10)
			if("Hard Restart (No Delay, No Feeback Reason)")
				to_chat(world, "World reboot - [init_by]")
				world.Reboot()
			if("Hardest Restart (No actions, just reboot)")
				to_chat(world, "Hard world reboot - [init_by]")
				world.Reboot(fast_track = TRUE)
			if("Server Restart (Kill and restart DD)")
				to_chat(world, "Server restart - [init_by]")
				world.TgsEndProcess()

ADMIN_VERB(server, end_round, "Attempts to produce a round end report and then restart the server organically.", R_SERVER)
	var/confirm = tgui_alert(usr, "End the round and  restart the game world?", "End Round", list("Yes", "Cancel"))
	if(confirm == "Cancel")
		return
	if(confirm == "Yes")
		SSticker.force_ending = TRUE

ADMIN_VERB(server, toggle_ooc, "Toggle dis bitch", R_SERVER)
	toggle_ooc()
	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled OOC.")

ADMIN_VERB(server, toggle_dead_ooc, "Toggle dis bitch", R_SERVER)
	toggle_dooc()
	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead OOC.")

ADMIN_VERB(server, start_now, "Start the round RIGHT NOW", R_SERVER)
	if(SSticker.current_state == GAME_STATE_PREGAME || SSticker.current_state == GAME_STATE_STARTUP)
		if(!SSticker.start_immediately)
			var/localhost_addresses = list("127.0.0.1", "::1")
			if(!(isnull(usr.client.address) || (usr.client.address in localhost_addresses)))
				if(tgui_alert(usr, "Are you sure you want to start the round?","Start Now",list("Start Now","Cancel")) != "Start Now")
					return FALSE
			SSticker.start_immediately = TRUE
			log_admin("[usr.key] has started the game.")
			var/msg = ""
			if(SSticker.current_state == GAME_STATE_STARTUP)
				msg = " (The server is still setting up, but the round will be \
					started as soon as possible.)"
			message_admins("<font color='blue'>[usr.key] has started the game.[msg]</font>")
			SSblackbox.record_feedback("tally", "admin_verb", 1, "Start Now") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
			return TRUE
		SSticker.start_immediately = FALSE
		SSticker.SetTimeLeft(1800)
		to_chat(world, "<span class='infoplain'><b>The game will start in 180 seconds.</b></span>")
		SEND_SOUND(world, sound('sound/ai/default/attention.ogg'))
		message_admins("<font color='blue'>[usr.key] has cancelled immediate game start. Game will start in 180 seconds.</font>")
		log_admin("[usr.key] has cancelled immediate game start.")
	else
		to_chat(usr, "<span class='warningplain'><font color='red'>Error: Start Now: Game has already started.</font></span>")
	return FALSE

ADMIN_VERB(server, delay_round_end, "Prevent the server from restarting", R_SERVER)
	if(SSticker.delay_end)
		tgui_alert(usr, "The round end is already delayed. The reason for the current delay is: \"[SSticker.admin_delay_notice]\"", "Alert", list("Ok"))
		return

	var/delay_reason = input(usr, "Enter a reason for delaying the round end", "Round Delay Reason") as null|text

	if(isnull(delay_reason))
		return

	if(SSticker.delay_end)
		tgui_alert(usr, "The round end is already delayed. The reason for the current delay is: \"[SSticker.admin_delay_notice]\"", "Alert", list("Ok"))
		return

	SSticker.delay_end = TRUE
	SSticker.admin_delay_notice = delay_reason

	log_admin("[key_name(usr)] delayed the round end for reason: [SSticker.admin_delay_notice]")
	message_admins("[key_name_admin(usr)] delayed the round end for reason: [SSticker.admin_delay_notice]")

ADMIN_VERB(server, toggle_entering, "People can't enter", R_SERVER)
	if(!SSlag_switch.initialized)
		return
	SSlag_switch.set_measure(DISABLE_NON_OBSJOBS, !SSlag_switch.measures[DISABLE_NON_OBSJOBS])
	log_admin("[key_name(usr)] toggled new player game entering. Lag Switch at index ([DISABLE_NON_OBSJOBS])")
	message_admins("[key_name_admin(usr)] toggled new player game entering [SSlag_switch.measures[DISABLE_NON_OBSJOBS] ? "OFF" : "ON"].")

ADMIN_VERB(server, toggle_ai, "People can't be AI", R_SERVER)
	var/alai = CONFIG_GET(flag/allow_ai)
	CONFIG_SET(flag/allow_ai, !alai)
	if (alai)
		to_chat(world, "<B>The AI job is no longer chooseable.</B>", confidential = TRUE)
	else
		to_chat(world, "<B>The AI job is chooseable now.</B>", confidential = TRUE)
	log_admin("[key_name(usr)] toggled AI allowed.")
	world.update_status()

ADMIN_VERB(server, toggle_respawn, "Respawn basically", R_SERVER)
	var/new_nores = !CONFIG_GET(flag/norespawn)
	CONFIG_SET(flag/norespawn, new_nores)
	if (!new_nores)
		to_chat(world, "<B>You may now respawn.</B>", confidential = TRUE)
	else
		to_chat(world, "<B>You may no longer respawn :(</B>", confidential = TRUE)
	message_admins(span_adminnotice("[key_name_admin(usr)] toggled respawn to [!new_nores ? "On" : "Off"]."))
	log_admin("[key_name(usr)] toggled respawn to [!new_nores ? "On" : "Off"].")
	world.update_status()

ADMIN_VERB(server, delay_pre_game, "Delay the game start", R_SERVER)
	var/newtime = input(usr, "Set a new time in seconds. Set -1 for indefinite delay.","Set Delay",round(SSticker.GetTimeLeft()/10)) as num|null
	if(SSticker.current_state > GAME_STATE_PREGAME)
		return tgui_alert(usr, "Too late... The game has already started!")
	if(newtime)
		newtime = newtime*10
		SSticker.SetTimeLeft(newtime)
		SSticker.start_immediately = FALSE
		if(newtime < 0)
			to_chat(world, "<span class='infoplain'><b>The game start has been delayed.</b></span>", confidential = TRUE)
			log_admin("[key_name(usr)] delayed the round start.")
		else
			to_chat(world, "<span class='infoplain'><b>The game will start in [DisplayTimeText(newtime)].</b></span>", confidential = TRUE)
			SEND_SOUND(world, sound('sound/ai/default/attention.ogg'))
			log_admin("[key_name(usr)] set the pre-game delay to [DisplayTimeText(newtime)].")

ADMIN_VERB(server, set_admin_notice, "Set an announcement that appears to everone who joins the server; only lasts this round", R_SERVER)
	var/new_admin_notice = input(src,"Set a public notice for this round. Everyone who joins the server will see it.\n(Leaving it blank will delete the current notice):","Set Notice",GLOB.admin_notice) as message|null
	if(new_admin_notice == null)
		return
	if(new_admin_notice == GLOB.admin_notice)
		return
	if(new_admin_notice == "")
		message_admins("[key_name(usr)] removed the admin notice.")
		log_admin("[key_name(usr)] removed the admin notice:\n[GLOB.admin_notice]")
	else
		message_admins("[key_name(usr)] set the admin notice.")
		log_admin("[key_name(usr)] set the admin notice:\n[new_admin_notice]")
		to_chat(world, span_adminnotice("<b>Admin Notice:</b>\n \t [new_admin_notice]"), confidential = TRUE)
	GLOB.admin_notice = new_admin_notice

ADMIN_VERB(server, toggle_guests, "Guests can't enter", R_SERVER)
	var/new_guest_ban = !CONFIG_GET(flag/guest_ban)
	CONFIG_SET(flag/guest_ban, new_guest_ban)
	if (new_guest_ban)
		to_chat(world, "<B>Guests may no longer enter the game.</B>", confidential = TRUE)
	else
		to_chat(world, "<B>Guests may now enter the game.</B>", confidential = TRUE)
	log_admin("[key_name(usr)] toggled guests game entering [!new_guest_ban ? "" : "dis"]allowed.")
	message_admins(span_adminnotice("[key_name_admin(usr)] toggled guests game entering [!new_guest_ban ? "" : "dis"]allowed."))
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Guests", "[!new_guest_ban ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
