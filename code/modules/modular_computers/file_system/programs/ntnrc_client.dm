
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
	var/last_message // Used to generate the toolbar icon
	var/username
	var/active_channel
	var/list/channel_history = list()
	var/operator_mode = FALSE // Channel operator mode
	var/netadmin_mode = FALSE // Administrator mode (invisible to other users + bypasses passwords)
	//A list of all the converstations we're a part of
	var/list/datum/ntnet_conversation/conversations = list()

/datum/computer_file/program/chatclient/New()
	username = "DefaultUser[rand(100, 999)]"

/datum/computer_file/program/chatclient/Destroy()
	for(var/datum/ntnet_conversation/discussion as anything in conversations)
		discussion.purge_client(src)
	conversations.Cut()
	return ..()

/datum/computer_file/program/chatclient/ui_act(action, params)
	. = ..()
	if(.)
		return

	var/datum/ntnet_conversation/channel = SSnetworks.station_network.get_chat_channel_by_id(active_channel)
	var/authed = FALSE
	if(channel && ((channel.operator == src) || netadmin_mode))
		authed = TRUE
	switch(action)
		if("PRG_speak")
			if(!channel || isnull(active_channel))
				return
			var/message = reject_bad_text(params["message"])
			if(!message)
				return
			if(channel.password && (!(src in channel.active_clients) && !(src in channel.offline_clients)))
				if(channel.password == message)
					channel.add_client(src)
					return TRUE

			channel.add_message(message, username)
			var/mob/living/user = usr
			user.log_talk(message, LOG_CHAT, tag="as [username] to channel [channel.title]")
			return TRUE
		if("PRG_joinchannel")
			var/new_target = text2num(params["id"])
			if(isnull(new_target) || new_target == active_channel)
				return

			if(netadmin_mode)
				active_channel = new_target // Bypasses normal leave/join and passwords. Technically makes the user invisible to others.
				return TRUE

			active_channel =  new_target
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
			var/channel_title = reject_bad_text(params["new_channel_name"])
			if(!channel_title)
				return
			var/datum/ntnet_conversation/C = new /datum/ntnet_conversation()
			C.add_client(src)
			C.operator = src
			C.title = channel_title
			active_channel = C.id
			return TRUE
		if("PRG_toggleadmin")
			if(netadmin_mode)
				netadmin_mode = FALSE
				if(channel)
					channel.remove_client(src) // We shouldn't be in channel's user list, but just in case...
				return TRUE
			var/mob/living/user = usr
			if(can_run(user, TRUE, ACCESS_NETWORK))
				for(var/C in SSnetworks.station_network.chat_channels)
					var/datum/ntnet_conversation/chan = C
					chan.remove_client(src)
				netadmin_mode = TRUE
				return TRUE
		if("PRG_changename")
			var/newname = sanitize(params["new_name"])
			newname = replacetext(newname, " ", "_")
			if(!newname || newname == username)
				return
			for(var/datum/ntnet_conversation/anychannel as anything in SSnetworks.station_network.chat_channels)
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
			var/datum/computer_file/data/logfile = new /datum/computer_file/data/logfile()
			// Now we will generate HTML-compliant file that can actually be viewed/printed.
			logfile.filename = logname
			logfile.stored_data = "\[b\]Logfile dump from NTNRC channel [channel.title]\[/b\]\[BR\]"
			for(var/logstring in channel.messages)
				logfile.stored_data = "[logfile.stored_data][logstring]\[BR\]"
			logfile.stored_data = "[logfile.stored_data]\[b\]Logfile dump completed.\[/b\]"
			logfile.calculate_size()
			var/obj/item/computer_hardware/hard_drive/hard_drive = computer.all_components[MC_HDD]
			if(!computer || !hard_drive || !hard_drive.store_file(logfile))
				if(!computer)
					// This program shouldn't even be runnable without computer.
					CRASH("Var computer is null!")
				if(!hard_drive)
					computer.visible_message(span_warning("\The [computer] shows an \"I/O Error - Hard drive connection error\" warning."))
				else // In 99.9% cases this will mean our HDD is full
					computer.visible_message(span_warning("\The [computer] shows an \"I/O Error - Hard drive may be full. Please free some space and try again. Required space: [logfile.size]GQ\" warning."))
			return TRUE
		if("PRG_renamechannel")
			if(!authed)
				return
			var/newname = reject_bad_text(params["new_name"])
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

/datum/computer_file/program/chatclient/process_tick()
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
		ui_header = last_message == channel.messages[length(channel.messages)] ? "ntnrc_idle.gif" : "ntnrc_new.gif"
	else
		ui_header = "ntnrc_idle.gif"

/datum/computer_file/program/chatclient/run_program(mob/living/user)
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
	..()

/datum/computer_file/program/chatclient/ui_static_data(mob/user)
	var/list/data = list()
	data["can_admin"] = can_run(user, FALSE, ACCESS_NETWORK)
	return data

/datum/computer_file/program/chatclient/ui_data(mob/user)
	if(!SSnetworks.station_network || !SSnetworks.station_network.chat_channels)
		return list()

	var/list/data = list()

	data = get_header_data()

	var/list/all_channels = list()
	for(var/C in SSnetworks.station_network.chat_channels)
		var/datum/ntnet_conversation/conv = C
		if(conv?.title)
			all_channels.Add(list(list(
				"chan" = conv.title,
				"id" = conv.id
			)))
	data["all_channels"] = all_channels

	data["active_channel"] = active_channel
	data["selfref"] = REF(src) //used to verify who is you, as usernames can be copied.
	data["username"] = username
	data["adminmode"] = netadmin_mode
	var/datum/ntnet_conversation/channel = SSnetworks.station_network.get_chat_channel_by_id(active_channel)
	if(channel)
		data["title"] = channel.title
		var/authed = FALSE
		if(!channel.password)
			authed = TRUE
		if(netadmin_mode)
			authed = TRUE
		var/list/clients = list()
		for(var/datum/computer_file/program/chatclient/channel_client as anything in channel.active_clients + channel.offline_clients)
			if(channel_client == src)
				authed = TRUE
			clients.Add(list(list(
				"name" = channel_client.username,
				"status" = channel_client.program_state,
				"muted" = (channel_client in channel.muted_clients),
				"operator" = channel.operator == channel_client,
				"ref" = REF(channel_client)
			)))
		data["authed"] = authed
		//no fishing for ui data allowed
		if(authed)
			data["strong"] = channel.strong
			data["clients"] = clients
			var/list/messages = list()
			for(var/message in channel.messages)
				messages.Add(list(list(
					"msg" = message
				)))
			data["messages"] = messages
			data["is_operator"] = (channel.operator == src) || netadmin_mode
		else
			data["clients"] = list()
			data["messages"] = list()
	else
		data["clients"] = list()
		data["authed"] = FALSE
		data["messages"] = list()

	return data
