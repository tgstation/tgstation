// Server Tab - Server Verbs

ADMIN_VERB(toggle_random_events, "Toggle Random Events On/Off", "Toggles random events such as meteors, black holes, etc.", R_SERVER|R_ADMIN, VERB_CATEGORY_SERVER)
	var/new_are = !CONFIG_GET(flag/allow_random_events)
	CONFIG_SET(flag/allow_random_events, new_are)
	message_admins("[key_name_admin(user)] has [new_are ? "enabled" : "disabled"] random events.")

ADMIN_VERB(toggle_hub, "Toggle Hub", "Toggles public visibility for the server.", R_SERVER, VERB_CATEGORY_SERVER)
	world.update_hub_visibility(!GLOB.hub_visibility)
	log_admin("[key_name(user)] has toggled the server's hub status for the round, it is now [(GLOB.hub_visibility?"on":"off")] the hub.")
	message_admins("[key_name_admin(user)] has toggled the server's hub status for the round, it is now [(GLOB.hub_visibility?"on":"off")] the hub.")
	if (GLOB.hub_visibility && !world.reachable)
		message_admins("WARNING: The server will not show up on the hub because byond is detecting that a filewall is blocking incoming connections.")

#define RESTART_NORMAL "Regular Restart"
#define RESTART_DELAYED "Regular Restart (with delay)"
#define RESTART_HARD "Hard Restart (No delay/feedback)"
#define RESTART_NOW "Hardest Restart (Do nothing, reboot immediately)"
#define RESTART_TGS "Server Restart (Kill and Restart DD)"

ADMIN_VERB(restart, "Reboot World", "Restarts the world immediately.", R_SERVER, VERB_CATEGORY_SERVER)
	var/list/options = list(
		RESTART_NORMAL,
		RESTART_DELAYED,
		RESTART_HARD,
		RESTART_NOW,
		)
	if(world.TgsAvailable())
		options += RESTART_TGS

	if(SSticker.admin_delay_notice)
		var/bypass_delay = tgui_alert(
			user,
			"Are you sure? An admin has delayed the round end for the following reason: '[SSticker.admin_delay_notice]'",
			"Reboot World",
			list("Yes", "No"),
			) == "Yes"
		if(!bypass_delay)
			return FALSE

	var/restart_type = tgui_input_list(user, "Select Reboot Type", "Reboot World", options)
	if(isnull(restart_type))
		return FALSE

	var/action_message = "Initiated by [user.holder.fakekey ? "Admin" : user.key]."
	switch(restart_type)
		if(RESTART_NORMAL)
			SSticker.Reboot(action_message, "admin reboot - by [user.key] [user.holder.fakekey ? "(stealth)" : ""]", 1 SECONDS)
			return TRUE

		if(RESTART_DELAYED)
			var/delay = tgui_input_number(user, "How long should the delay be? (In seconds)", "Reboot World", default = 5, max_value = 60, min_value = 0)
			if(!delay)
				return FALSE
			SSticker.Reboot(action_message, "admin reboot - by [user.key] [user.holder.fakekey ? "(stealth)" : ""]", delay SECONDS)
			return TRUE

		if(RESTART_HARD)
			to_chat(world, "World Reboot - [action_message]")
			world.Reboot()
			return TRUE

		if(RESTART_NOW)
			to_chat(world, "World Reboot HARD - [action_message]")
			world.Reboot(fast_track = TRUE)
			return TRUE

		if(RESTART_TGS)
			to_chat(world, "Server Restart - [action_message]")
			world.TgsEndProcess()
			return TRUE

	message_admins("Restart Type not handled, tell coders.")

#undef RESTART_NORMAL
#undef RESTART_DELAYED
#undef RESTART_HARD
#undef RESTART_NOW
#undef RESTART_TGS

ADMIN_VERB(end_round, "End Round", "Attempts to end the round organically.", R_SERVER, VERB_CATEGORY_SERVER)
	var/do_it_now = tgui_alert(user, "End the round?", "End Round", list("Yes", "No")) == "Yes"
	if(!do_it_now)
		return

	SSticker.force_ending = TRUE
	log_admin("[key_name(user)] has forced the round to end.")
	message_admins("[key_name_admin(user)] has forced the round to end.")

ADMIN_VERB(toggle_ooc, "Toggle OOC", "Toggle OOC.", R_SERVER|R_ADMIN, VERB_CATEGORY_SERVER)
	toggle_ooc()
	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled OOC.")

ADMIN_VERB(toggle_dead_ooc, "Toggle Dead OOC", "Toggles the ability for observers to use OOC.", R_SERVER|R_ADMIN, VERB_CATEGORY_SERVER)
	toggle_dooc()
	log_admin("[key_name(usr)] toggled Dead OOC.")
	message_admins("[key_name_admin(usr)] toggled Dead OOC.")

ADMIN_VERB(start_now, "Start Now", "Forces the round to start immediately, skipping the delay.", R_SERVER, VERB_CATEGORY_SERVER)
	switch(SSticker.current_state)
		if(GAME_STATE_PREGAME, GAME_STATE_STARTUP)
			var/get_confirmation = !SSticker.start_immediately && !user.is_localhost()
			if(get_confirmation && tgui_alert(user, "Are you certain you want to start the round?", "Start Now", list("Yes", "No")) != "Yes")
				return FALSE

			SSticker.start_immediately = !SSticker.start_immediately
			if(!SSticker.start_immediately)
				log_admin("[key_name(user)] canceled early start.")
				message_admins("[key_name_admin(user)] cancled early start.")
				SSticker.SetTimeLeft(3 MINUTES)
				SEND_SOUND(world, sound('sound/ai/default/attention.ogg'))
				to_chat(world, "<span class='infoplain'><b>The game will start in 180 seconds.</b></span>")
				return TRUE

			log_admin("[key_name(user)] enabled instant start.")
			var/static/delay_message = " (The server is still setting up, but the round will be started as soon as possible.)"
			message_admins(span_blue("[key_name_admin(user)] started the game.[(SSticker.current_state == GAME_STATE_STARTUP) ? delay_message : ""]"))
			return TRUE

		else
			to_chat(user, span_warning("The game has already started."))
			return FALSE

ADMIN_VERB(delay_round_end, "Delay Round End", "Prevent the server from restarting.", R_SERVER, VERB_CATEGORY_SERVER)
	if(SSticker.delay_end)
		tgui_alert(user, "The round end is already delayed. The reason for the current delay is: \"[SSticker.admin_delay_notice]\"", "Alert", list("Ok"))
		return

	var/delay_reason = input(user, "Enter a reason for delaying the round end", "Round Delay Reason") as null|text

	if(isnull(delay_reason))
		return

	if(SSticker.delay_end)
		tgui_alert(user, "The round end is already delayed. The reason for the current delay is: \"[SSticker.admin_delay_notice]\"", "Alert", list("Ok"))
		return

	SSticker.delay_end = TRUE
	SSticker.admin_delay_notice = delay_reason

	log_admin("[key_name(user)] delayed the round end for reason: [SSticker.admin_delay_notice]")
	message_admins("[key_name_admin(user)] delayed the round end for reason: [SSticker.admin_delay_notice]")

ADMIN_VERB(toggle_enter, "Toggle Entering", "Prevent new players from joining the game.", R_SERVER|R_ADMIN, VERB_CATEGORY_SERVER)
	if(!SSlag_switch.initialized)
		to_chat(user, span_warning("The server is not initialized, please wait."))
		return

	SSlag_switch.set_measure(DISABLE_NON_OBSJOBS, !SSlag_switch.measures[DISABLE_NON_OBSJOBS])
	log_admin("[key_name(user)] toggled new player game entering. Lag Switch at index ([DISABLE_NON_OBSJOBS])")
	message_admins("[key_name_admin(user)] toggled new player game entering [SSlag_switch.measures[DISABLE_NON_OBSJOBS] ? "OFF" : "ON"].")

ADMIN_VERB(toggle_ai, "Toggle AI", "Toggle whether people can play as an AI.", R_SERVER, VERB_CATEGORY_SERVER)
	var/allow_ai = !CONFIG_GET(flag/allow_ai)
	CONFIG_SET(flag/allow_ai, !allow_ai)

	log_admin("[key_name(user)] [allow_ai ? "enabled" : "disabled"] joining as an AI.")
	message_admins("[key_name_admin(user)] [allow_ai ? "enabled" : "disabled"] joining as an AI.")

	to_chat(world, span_boldbig("The AI job is [allow_ai ? "now" : "no longer"] chooseable."))
	world.update_status()

ADMIN_VERB(toggle_respawning, "Toggle Respawn", "Toggle the ability for dead players to return to lobby.", R_SERVER, VERB_CATEGORY_SERVER)
	var/prevent_respawn = !CONFIG_GET(flag/norespawn)
	CONFIG_SET(flag/norespawn, prevent_respawn)
	to_chat(world, span_boldbig("You can [prevent_respawn ? "no longer" : "now"] respawn."))
	log_admin("[key_name(user)] toggled respawning [prevent_respawn ? "off" : "on"].")
	message_admins("[key_name_admin(user)] toggled respawning [prevent_respawn ? "off" : "on"].")

ADMIN_VERB(delay_start, "Delay Pre-Game", "Delay the game start.", R_SERVER, VERB_CATEGORY_SERVER)
	if(SSticker.current_state > GAME_STATE_PREGAME)
		tgui_alert(user, "Game already started.")
		return

	var/current_time_left = SSticker.GetTimeLeft()
	var/new_time = tgui_input_number(
		user,
		"Set a new time in seconds. Use '-1' for indefinite delay.",
		"Delay Pre-Game",
		round(current_time_left / 10),
		min_value = -1,
		)

	if(!new_time)
		return // -1 is truthy. I hate it too.

	if(SSticker.current_state > GAME_STATE_PREGAME)
		tgui_alert(user, "Too slow! The game started.")
		return

	SSticker.start_immediately = FALSE
	if(new_time < 0)
		SSticker.SetTimeLeft(-1)
		to_chat(world, span_infoplain(span_bold("The game start has been delayed.")))
	else
		SSticker.SetTimeLeft(new_time SECONDS)
		SEND_SOUND(world, sound('sound/ai/default/attention.ogg'))
		to_chat(world, span_infoplain(span_bold("The game will start in [DisplayTimeText(new_time)].")))

	log_admin("[key_name(user)] delayed the round start.")
	message_admins("[key_name_admin(user)] delayed the round start.")

ADMIN_VERB(set_admin_notice, "Set Admin Notice", "Set an announcement that appears to everyone who joins the server. Only lasts this round.", R_SERVER|R_ADMIN, VERB_CATEGORY_SERVER)
	var/old_notice = GLOB.admin_notice
	var/admin_notice = tgui_input_text(
		user,
		"Set the public notice for this round. Leave blank to remove.",
		"Admin Notice",
		old_notice,
		multiline = TRUE,
		encode = FALSE, // you have R_SERVER, I'm sure we can trust you.
		)

	if(isnull(admin_notice))
		return

	if(!length(admin_notice))
		GLOB.admin_notice = ""
		message_admins("[key_name_admin(user)] removed the admin notice.")
		log_admin("[key_name(user)] removed the admin notice:\n[old_notice]")
		return

	GLOB.admin_notice = admin_notice
	message_admins("[key_name_admin(user)] set the admin notice.")
	log_admin("[key_name(user)] set the admin notice:\n[admin_notice]")
	to_chat(world, span_adminnotice("<b>Admin Notice:</b>\n \t [admin_notice]"))

ADMIN_VERB(toggle_guests, "Toggle Guests", "Toggle the ability for guests to connect to the server.", R_SERVER|R_ADMIN, VERB_CATEGORY_SERVER)
	var/new_guest_ban = !CONFIG_GET(flag/guest_ban)
	CONFIG_SET(flag/guest_ban, new_guest_ban)
	to_chat(world, span_bold("Guests are [new_guest_ban ? "no longer" : "now"] allowed to join the server."))

	var/ejections = 0
	if(new_guest_ban)
		for(var/client/connected as anything in GLOB.clients)
			if(is_guest_key(connected.key))
				ejections++
				qdel(connected)
		if(ejections)
			log_admin("[key_name(user)] kicked [ejections] guests by disabling their ability to join.")
			message_admins("[key_name_admin(user)] kicked [ejections] guests by disabling their ability to join.")

	log_admin("[key_name(user)] toggled guests game entering [!new_guest_ban ? "" : "dis"]allowed.")
	message_admins(span_adminnotice("[key_name_admin(user)] toggled guests game entering [!new_guest_ban ? "" : "dis"]allowed."))
