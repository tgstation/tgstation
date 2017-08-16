/datum/computer_file/program/chatclient
	filename = "ntnrc_client"
	filedesc = "Chat Client"
	program_icon_state = "command"
	extended_desc = "This program allows communication over NTNRC network"
	size = 8
	requires_ntnet = 1
	requires_ntnet_feature = NTNET_COMMUNICATION
	network_destination = "NTNRC server"
	ui_header = "ntnrc_idle.gif"
	available_on_ntnet = 1
	tgui_id = "ntos_net_chat"

	var/last_message = null				// Used to generate the toolbar icon
	var/username
	var/datum/ntnet_conversation/channel = null
	var/operator_mode = 0		// Channel operator mode
	var/netadmin_mode = 0		// Administrator mode (invisible to other users + bypasses passwords)

/datum/computer_file/program/chatclient/New()
	username = "DefaultUser[rand(100, 999)]"

/datum/computer_file/program/chatclient/ui_act(action, params)
	if(..())
		return 1

	switch(action)
		if("PRG_speak")
			. = 1
			if(!channel)
				return 1
			var/mob/living/user = usr
			var/message = reject_bad_text(input(user, "Enter message or leave blank to cancel: "))
			if(!message || !channel)
				return
			channel.add_message(message, username)
			log_talk(user,"[key_name(user)] as [username] sent to [channel.title]: [message]",LOGCHAT)

		if("PRG_joinchannel")
			. = 1
			var/datum/ntnet_conversation/C
			for(var/datum/ntnet_conversation/chan in GLOB.ntnet_global.chat_channels)
				if(chan.id == text2num(params["id"]))
					C = chan
					break

			if(!C)
				return 1

			if(netadmin_mode)
				channel = C		// Bypasses normal leave/join and passwords. Technically makes the user invisible to others.
				return 1

			if(C.password)
				var/mob/living/user = usr
				var/password = reject_bad_text(input(user,"Access Denied. Enter password:"))
				if(C && (password == C.password))
					C.add_client(src)
					channel = C
				return 1
			C.add_client(src)
			channel = C
		if("PRG_leavechannel")
			. = 1
			if(channel)
				channel.remove_client(src)
			channel = null
		if("PRG_newchannel")
			. = 1
			var/mob/living/user = usr
			var/channel_title = reject_bad_text(input(user,"Enter channel name or leave blank to cancel:"))
			if(!channel_title)
				return
			var/datum/ntnet_conversation/C = new/datum/ntnet_conversation()
			C.add_client(src)
			C.operator = src
			channel = C
			C.title = channel_title
		if("PRG_toggleadmin")
			. = 1
			if(netadmin_mode)
				netadmin_mode = 0
				if(channel)
					channel.remove_client(src) // We shouldn't be in channel's user list, but just in case...
					channel = null
				return 1
			var/mob/living/user = usr
			if(can_run(usr, 1, ACCESS_NETWORK))
				if(channel)
					var/response = alert(user, "Really engage admin-mode? You will be disconnected from your current channel!", "NTNRC Admin mode", "Yes", "No")
					if(response == "Yes")
						if(channel)
							channel.remove_client(src)
							channel = null
					else
						return
				netadmin_mode = 1
		if("PRG_changename")
			. = 1
			var/mob/living/user = usr
			var/newname = sanitize(input(user,"Enter new nickname or leave blank to cancel:"))
			if(!newname)
				return 1
			if(channel)
				channel.add_status_message("[username] is now known as [newname].")
			username = newname

		if("PRG_savelog")
			. = 1
			if(!channel)
				return
			var/mob/living/user = usr
			var/logname = stripped_input(user,"Enter desired logfile name (.log) or leave blank to cancel:")
			if(!logname || !channel)
				return 1
			var/datum/computer_file/data/logfile = new/datum/computer_file/data/logfile()
			// Now we will generate HTML-compliant file that can actually be viewed/printed.
			logfile.filename = logname
			logfile.stored_data = "\[b\]Logfile dump from NTNRC channel [channel.title]\[/b\]\[BR\]"
			for(var/logstring in channel.messages)
				logfile.stored_data += "[logstring]\[BR\]"
			logfile.stored_data += "\[b\]Logfile dump completed.\[/b\]"
			logfile.calculate_size()
			var/obj/item/weapon/computer_hardware/hard_drive/hard_drive = computer.all_components[MC_HDD]
			if(!computer || !hard_drive || !hard_drive.store_file(logfile))
				if(!computer)
					// This program shouldn't even be runnable without computer.
					CRASH("Var computer is null!")
					return 1
				if(!hard_drive)
					computer.visible_message("\The [computer] shows an \"I/O Error - Hard drive connection error\" warning.")
				else	// In 99.9% cases this will mean our HDD is full
					computer.visible_message("\The [computer] shows an \"I/O Error - Hard drive may be full. Please free some space and try again. Required space: [logfile.size]GQ\" warning.")
		if("PRG_renamechannel")
			. = 1
			if(!operator_mode || !channel)
				return 1
			var/mob/living/user = usr
			var/newname = reject_bad_text(input(user, "Enter new channel name or leave blank to cancel:"))
			if(!newname || !channel)
				return
			channel.add_status_message("Channel renamed from [channel.title] to [newname] by operator.")
			channel.title = newname
		if("PRG_deletechannel")
			. = 1
			if(channel && ((channel.operator == src) || netadmin_mode))
				qdel(channel)
				channel = null
		if("PRG_setpassword")
			. = 1
			if(!channel || ((channel.operator != src) && !netadmin_mode))
				return 1

			var/mob/living/user = usr
			var/newpassword = sanitize(input(user, "Enter new password for this channel. Leave blank to cancel, enter 'nopassword' to remove password completely:"))
			if(!channel || !newpassword || ((channel.operator != src) && !netadmin_mode))
				return 1

			if(newpassword == "nopassword")
				channel.password = ""
			else
				channel.password = newpassword

/datum/computer_file/program/chatclient/process_tick()
	..()
	if(program_state != PROGRAM_STATE_KILLED)
		ui_header = "ntnrc_idle.gif"
		if(channel)
			// Remember the last message. If there is no message in the channel remember null.
			last_message = channel.messages.len ? channel.messages[channel.messages.len - 1] : null
		else
			last_message = null
		return 1
	if(channel && channel.messages && channel.messages.len)
		ui_header = last_message == channel.messages[channel.messages.len - 1] ? "ntnrc_idle.gif" : "ntnrc_new.gif"
	else
		ui_header = "ntnrc_idle.gif"

/datum/computer_file/program/chatclient/kill_program(forced = FALSE)
	if(channel)
		channel.remove_client(src)
		channel = null
	..()

/datum/computer_file/program/chatclient/ui_data(mob/user)
	if(!GLOB.ntnet_global || !GLOB.ntnet_global.chat_channels)
		return

	var/list/data = list()

	data = get_header_data()


	data["adminmode"] = netadmin_mode
	if(channel)
		data["title"] = channel.title
		var/list/messages[0]
		for(var/M in channel.messages)
			messages.Add(list(list(
				"msg" = M
			)))
		data["messages"] = messages
		var/list/clients[0]
		for(var/C in channel.clients)
			var/datum/computer_file/program/chatclient/cl = C
			clients.Add(list(list(
				"name" = cl.username
			)))
		data["clients"] = clients
		operator_mode = (channel.operator == src) ? 1 : 0
		data["is_operator"] = operator_mode || netadmin_mode

	else // Channel selection screen
		var/list/all_channels[0]
		for(var/C in GLOB.ntnet_global.chat_channels)
			var/datum/ntnet_conversation/conv = C
			if(conv && conv.title)
				all_channels.Add(list(list(
					"chan" = conv.title,
					"id" = conv.id
				)))
		data["all_channels"] = all_channels

	return data