#define USERNAME_SIZE 32
#define CHANNELNAME_SIZE 18
#define MESSAGE_SIZE 2048

#define PING_COOLDOWN_TIME (3 SECONDS)

#define STATUS_ONLINE 3
#define STATUS_AWAY 2
#define STATUS_OFFLINE 1

/datum/computer_file/program/chatclient
	filename = "ntnrc_client"
	filedesc = "Chat Client"
	downloader_category = PROGRAM_CATEGORY_DEVICE
	program_open_overlay = "text"
	extended_desc = "This program allows communication over NTNRC network."
	size = 8
	ui_header = "ntnrc_idle.gif"
	program_flags = PROGRAM_ON_NTNET_STORE | PROGRAM_REQUIRES_NTNET
	tgui_id = "NtosNetChat"
	program_icon = FA_ICON_COMMENT_ALT
	alert_able = TRUE

	///The user's screen name.
	var/username
	///The id of the last message sent in a channel, used to tell if someone has sent a new message yet.
	var/last_message_id
	///The channel currently active in.
	var/active_channel
	///If the tablet is in Admin mode, you bypass Passwords and aren't announced when entering a channel.
	var/netadmin_mode = FALSE
	///All NTnet conversations the application is apart of.
	var/list/datum/ntnet_conversation/conversations = list()
	///Cooldown timer between pings.
	COOLDOWN_DECLARE(ping_cooldown)

/datum/computer_file/program/chatclient/on_install(datum/computer_file/source, obj/item/modular_computer/computer_installing)
	. = ..()
	if(!username)
		username = "DefaultUser[rand(100, 999)]"

/datum/computer_file/program/chatclient/Destroy()
	for(var/datum/ntnet_conversation/discussion as anything in conversations)
		discussion.purge_client(src)
	conversations.Cut()
	return ..()

/datum/computer_file/program/chatclient/proc/create_new_channel(channel_title, strong = FALSE)
	var/datum/ntnet_conversation/new_converstaion = new /datum/ntnet_conversation(channel_title, strong)
	new_converstaion.add_client(src)
	new_converstaion.title = channel_title
	active_channel = new_converstaion.id
	return new_converstaion

/datum/computer_file/program/chatclient/ui_act(action, params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	var/datum/ntnet_conversation/channel = SSmodular_computers.get_chat_channel_by_id(active_channel)
	var/authed = FALSE
	if(channel && ((channel.channel_operator == src) || netadmin_mode))
		authed = TRUE

	switch(action)
		if("PRG_speak")
			if(!channel || isnull(active_channel))
				return
			if(src in channel.muted_clients) // Make sure we aren't muted
				return
			var/message = reject_bad_chattext(params["message"], MESSAGE_SIZE)
			if(!message)
				return
			if(channel.password && (!(src in channel.active_clients) && !(src in channel.offline_clients)))
				if(channel.password == message)
					channel.add_client(src)
					return TRUE

			channel.add_message(message, username)
			var/mob/living/user = usr
			user.log_talk(message, LOG_CHAT, tag = "as [username] to channel [channel.title]")
			return TRUE
		if("PRG_joinchannel")
			var/new_target = text2num(params["id"])
			if(isnull(new_target) || new_target == active_channel)
				return

			if(netadmin_mode)
				active_channel = new_target // Bypasses normal leave/join and passwords. Technically makes the user invisible to others.
				return TRUE

			active_channel = new_target
			channel = SSmodular_computers.get_chat_channel_by_id(new_target)
			if((!(src in channel.active_clients) && !(src in channel.offline_clients)) && !channel.password)
				channel.add_client(src)
			return TRUE
		if("PRG_leavechannel")
			if(channel)
				channel.remove_client(src)
				active_channel = null
				return TRUE
		if("PRG_newchannel")
			var/channel_title = reject_bad_chattext(params["new_channel_name"], CHANNELNAME_SIZE)
			if(!channel_title)
				return
			create_new_channel(channel_title)
			return TRUE
		if("PRG_toggleadmin")
			if(netadmin_mode)
				netadmin_mode = FALSE
				channel?.add_client(src)
				return TRUE
			var/mob/living/user = usr
			if(can_run(user, TRUE, list(ACCESS_NETWORK)))
				for(var/datum/ntnet_conversation/channels as anything in SSmodular_computers.chat_channels)
					channels.remove_client(src)
				netadmin_mode = TRUE
				return TRUE
		if("PRG_changename")
			var/newname = reject_bad_chattext(params["new_name"], USERNAME_SIZE)
			newname = replacetext(newname, " ", "_")
			if(!newname || newname == username)
				return
			for(var/datum/ntnet_conversation/anychannel as anything in SSmodular_computers.chat_channels)
				if(src in anychannel.active_clients)
					anychannel.add_status_message("[username] is now known as [newname].")
			username = newname
			return TRUE
		if("PRG_savelog")
			if(!channel)
				return
			var/logname = stripped_input(params["log_name"])
			if(!logname)
				return
			var/datum/computer_file/data/text/logfile = new()
			// Now we will generate HTML-compliant file that can actually be viewed/printed.
			logfile.filename = logname
			logfile.stored_text = "\[b\]Logfile dump from NTNRC channel [channel.title]\[/b\]\[BR\]"
			for(var/message_id in channel.messages)
				logfile.stored_text = "[logfile.stored_text][channel.messages[message_id]]\[BR\]"
			logfile.stored_text = "[logfile.stored_text]\[b\]Logfile dump completed.\[/b\]"
			logfile.calculate_size()
			if(!computer || !computer.store_file(logfile))
				if(!computer)
					// This program shouldn't even be runnable without computer.
					CRASH("Var computer is null!")
				computer.visible_message(span_warning("\The [computer] shows an \"I/O Error - Hard drive may be full. Please free some space and try again. Required space: [logfile.size]GQ\" warning."))
			return TRUE
		if("PRG_renamechannel")
			if(!authed)
				return
			var/newname = reject_bad_chattext(params["new_name"], CHANNELNAME_SIZE)
			if(!newname || !channel)
				return
			channel.add_status_message("Channel renamed from [channel.title] to [newname] by operator.")
			channel.title = newname
			return TRUE
		if("PRG_deletechannel")
			if(authed)
				qdel(channel)
				active_channel = null
				return TRUE
		if("PRG_setpassword")
			if(!authed)
				return
			var/new_password = sanitize(params["new_password"])
			if(!authed)
				return
			channel.password = new_password
			return TRUE
		if("PRG_mute_user")
			if(!authed)
				return
			var/datum/computer_file/program/chatclient/muted = locate(params["ref"]) in channel.active_clients + channel.offline_clients
			channel.mute_user(src, muted)
			return TRUE
		if("PRG_ping_user")
			if(!COOLDOWN_FINISHED(src, ping_cooldown))
				return
			if(src in channel.muted_clients)
				return
			var/datum/computer_file/program/chatclient/pinged = locate(params["ref"]) in channel.active_clients + channel.offline_clients
			channel.ping_user(src, pinged)
			COOLDOWN_START(src, ping_cooldown, PING_COOLDOWN_TIME)
			return TRUE

/datum/computer_file/program/chatclient/process_tick(seconds_per_tick)
	. = ..()

	if(!(src in computer.idle_threads))
		return

	var/datum/ntnet_conversation/watched_channel = SSmodular_computers.get_chat_channel_by_id(active_channel)
	if(isnull(watched_channel)) // If we're not in a channel, no need for a message notification header.
		ui_header = null
		return
	if(!length(watched_channel.messages)) // But if there's no messages, we do still wait for a message.
		ui_header = "ntnrc_idle.gif"
		return

	var/last_message_id_found = watched_channel.messages[length(watched_channel.messages)]
	if(last_message_id_found == last_message_id)
		ui_header = "ntnrc_idle.gif"
		return
	ui_header = "ntnrc_new.gif"

/datum/computer_file/program/chatclient/on_start(mob/living/user)
	. = ..()
	if(!.)
		return
	for(var/datum/ntnet_conversation/channel as anything in SSmodular_computers.chat_channels)
		if(src in channel.offline_clients)
			channel.offline_clients.Remove(src)
			channel.active_clients.Add(src)

/datum/computer_file/program/chatclient/kill_program(mob/user)
	for(var/datum/ntnet_conversation/channel as anything in SSmodular_computers.chat_channels)
		channel.go_offline(src)
	active_channel = null
	return ..()

/datum/computer_file/program/chatclient/background_program(mob/user)
	. = ..()
	var/datum/ntnet_conversation/open_channel = SSmodular_computers.get_chat_channel_by_id(active_channel)
	if(isnull(open_channel) || !length(open_channel.messages))
		last_message_id = null
		ui_header = null
		return

	last_message_id = open_channel.messages[length(open_channel.messages)]
	ui_header = "ntnrc_idle.gif"

/// Converts active/idle/closed to a numerical status for sorting clients by.
/datum/computer_file/program/chatclient/proc/get_numerical_status()
	if(src == computer.active_program)
		return STATUS_ONLINE
	if(src in computer.idle_threads)
		return STATUS_AWAY
	return STATUS_OFFLINE

/datum/computer_file/program/chatclient/ui_static_data(mob/user)
	var/list/data = list()
	data["selfref"] = REF(src) //used to verify who is you, as usernames can be copied.
	return data

/datum/computer_file/program/chatclient/ui_data(mob/user)
	var/list/data = list()

	var/list/all_channels = list()
	for(var/datum/ntnet_conversation/conversations as anything in SSmodular_computers.chat_channels)
		if(conversations.title)
			all_channels.Add(list(list(
				"chan" = conversations.title,
				"id" = conversations.id,
			)))
	data["all_channels"] = all_channels
	data["active_channel"] = active_channel

	var/datum/ntnet_conversation/channel = SSmodular_computers.get_chat_channel_by_id(active_channel)
	var/authed = FALSE
	data["clients"] = list()
	data["messages"] = list()
	if(channel)
		data["title"] = channel.title
		if(!channel.password || netadmin_mode)
			authed = TRUE
		var/list/clients = list()
		for(var/datum/computer_file/program/chatclient/channel_client as anything in channel.active_clients + channel.offline_clients)
			if(channel_client == src)
				authed = TRUE
			clients.Add(list(list(
				"name" = channel_client.username,
				"online" = (channel_client == channel_client.computer.active_program),
				"away" = (channel_client in channel_client.computer.idle_threads),
				"muted" = (channel_client in channel.muted_clients),
				"operator" = (channel.channel_operator == channel_client),
				"status" = channel_client.get_numerical_status(),
				"ref" = REF(channel_client),
			)))
		//no fishing for ui data allowed
		if(authed)
			data["strong"] = channel.strong
			data["clients"] = clients
			var/list/messages = list()
			for(var/i=channel.messages.len to 1 step -1)
				var/message_id = channel.messages[i]
				messages.Add(list(list(
					"key" = message_id,
					"msg" = channel.messages[message_id],
				)))
			data["messages"] = messages
			data["is_operator"] = (channel.channel_operator == src) || netadmin_mode

	data["username"] = username
	data["adminmode"] = netadmin_mode
	data["can_admin"] = can_run(user, FALSE, list(ACCESS_NETWORK))
	data["authed"] = authed
	return data

#undef USERNAME_SIZE
#undef CHANNELNAME_SIZE
#undef MESSAGE_SIZE

#undef PING_COOLDOWN_TIME

#undef STATUS_ONLINE
#undef STATUS_AWAY
#undef STATUS_OFFLINE
