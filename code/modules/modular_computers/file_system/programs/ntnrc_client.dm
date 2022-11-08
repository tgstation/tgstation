#define USERNAME_SIZE 32
#define CHANNELNAME_SIZE 12
#define MESSAGE_SIZE 2048

/datum/computer_file/program/chatclient
	filename = "ntnrc_client"
	filedesc = "Chat Client"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "command"
	extended_desc = "This program allows communication over NTNRC network"
	size = 8
	requires_ntnet = TRUE
	requires_ntnet_feature = NTNET_COMMUNICATION
	ui_header = "ntnrc_idle.gif"
	available_on_ntnet = TRUE
	tgui_id = "NtosNetChat"
	program_icon = "comment-alt"
	alert_able = TRUE

	///The user's screen name.
	var/username
	///The last message you sent in a channel, used to tell if someone has sent a new message yet.
	var/last_message
	///The channel currently active in.
	var/active_channel
	///If the tablet is in Admin mode, you bypass Passwords and aren't announced when entering a channel.
	var/netadmin_mode = FALSE
	///All NTnet conversations the application is apart of.
	var/list/datum/ntnet_conversation/conversations = list()

/datum/computer_file/program/chatclient/New()
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

/datum/computer_file/program/chatclient/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/datum/ntnet_conversation/channel = SSnetworks.station_network.get_chat_channel_by_id(active_channel)
	var/authed = FALSE
	if(channel && ((channel.channel_operator == src) || netadmin_mode))
		authed = TRUE

	switch(action)
		if("PRG_speak")
			if(!channel || isnull(active_channel))
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
			channel = SSnetworks.station_network.get_chat_channel_by_id(new_target)
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
				return UI_UPDATE
			var/mob/living/user = usr
			if(can_run(user, TRUE, ACCESS_NETWORK))
				for(var/datum/ntnet_conversation/channels as anything in SSnetworks.station_network.chat_channels)
					channels.remove_client(src)
				netadmin_mode = TRUE
				return UI_UPDATE
		if("PRG_changename")
			var/newname = reject_bad_chattext(params["new_name"], USERNAME_SIZE)
			newname = replacetext(newname, " ", "_")
			if(!newname || newname == username)
				return
			for(var/datum/ntnet_conversation/anychannel as anything in SSnetworks.station_network.chat_channels)
				if(src in anychannel.active_clients)
					anychannel.add_status_message("[username] is now known as [newname].")
			username = newname
			return UI_UPDATE
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
			for(var/logstring in channel.messages)
				logfile.stored_text = "[logfile.stored_text][logstring]\[BR\]"
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
			if(!authed)
				return
			var/datum/computer_file/program/chatclient/pinged = locate(params["ref"]) in channel.active_clients + channel.offline_clients
			channel.ping_user(src, pinged)
			return TRUE

/datum/computer_file/program/chatclient/process_tick(delta_time)
	. = ..()
	var/datum/ntnet_conversation/channel = SSnetworks.station_network.get_chat_channel_by_id(active_channel)
	if(program_state != PROGRAM_STATE_KILLED)
		ui_header = "ntnrc_idle.gif"
		if(channel)
			// Remember the last message. If there is no message in the channel remember null.
			last_message = length(channel.messages) ? channel.messages[length(channel.messages)] : null
		else
			last_message = null
		return TRUE
	if(channel?.messages?.len)
		ui_header = (last_message == channel.messages[length(channel.messages)] ? "ntnrc_idle.gif" : "ntnrc_new.gif")
	else
		ui_header = "ntnrc_idle.gif"

/datum/computer_file/program/chatclient/on_start(mob/living/user)
	. = ..()
	if(!.)
		return
	for(var/datum/ntnet_conversation/channel as anything in SSnetworks.station_network.chat_channels)
		if(src in channel.offline_clients)
			channel.offline_clients.Remove(src)
			channel.active_clients.Add(src)

/datum/computer_file/program/chatclient/kill_program(forced = FALSE)
	for(var/datum/ntnet_conversation/channel as anything in SSnetworks.station_network.chat_channels)
		channel.go_offline(src)
	active_channel = null
	return ..()

/datum/computer_file/program/chatclient/ui_static_data(mob/user)
	var/list/data = list()
	data["can_admin"] = can_run(user, FALSE, ACCESS_NETWORK)
	data["selfref"] = REF(src) //used to verify who is you, as usernames can be copied.
	data["username"] = username
	data["adminmode"] = netadmin_mode
	return data

/datum/computer_file/program/chatclient/ui_data(mob/user)
	var/list/data = get_header_data()
	if(!SSnetworks.station_network || !SSnetworks.station_network.chat_channels)
		return data

	var/list/all_channels = list()
	for(var/datum/ntnet_conversation/conversations as anything in SSnetworks.station_network.chat_channels)
		if(conversations.title)
			all_channels.Add(list(list(
				"chan" = conversations.title,
				"id" = conversations.id,
			)))
	data["all_channels"] = all_channels
	data["active_channel"] = active_channel

	var/datum/ntnet_conversation/channel = SSnetworks.station_network.get_chat_channel_by_id(active_channel)
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
				"status" = channel_client.program_state,
				"muted" = (channel_client in channel.muted_clients),
				"operator" = (channel.channel_operator == channel_client),
				"ref" = REF(channel_client),
			)))
		//no fishing for ui data allowed
		if(authed)
			data["strong"] = channel.strong
			data["clients"] = clients
			var/list/messages = list()
			for(var/message in channel.messages)
				messages.Add(list(list(
					"msg" = message,
				)))
			data["messages"] = messages
			data["is_operator"] = (channel.channel_operator == src) || netadmin_mode

	data["authed"] = authed
	return data

#undef USERNAME_SIZE
#undef CHANNELNAME_SIZE
#undef MESSAGE_SIZE
