GLOBAL_LIST_INIT(team_chat_admin_ckeys, list("waylandsmithy", "exavere", "sacko", "jaredfogle"))

/obj/machinery/modular_computer/console/preset/teamchat
	name = "internal team chat console"
	desc = "How are you examining this anyway?"
	///chat client installed on this computer, just helpful for linking all the computers
	var/datum/computer_file/program/chatclient/team/chatprogram

/obj/item/modular_computer/check_power_override()
	return TRUE

/obj/item/modular_computer
	var/mob/mob_user

/obj/machinery/modular_computer/console/preset/teamchat/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	chatprogram = new
	chatprogram.computer = cpu
	hard_drive.store_file(chatprogram)
	hard_drive.max_capacity = chatprogram.size

/mob
	var/obj/machinery/modular_computer/console/preset/teamchat/team_chat_console
	var/datum/action/team_chat/open_team_chat = new

/mob/living/Destroy()
	open_team_chat.Remove(src)
	QDEL_NULL(open_team_chat)
	QDEL_NULL(team_chat_console)
	return ..()

/mob/Login()
	. = ..()
	if(ckey in GLOB.team_chat_admin_ckeys)
		team_chat_console = new
		team_chat_console.chatprogram.username = key
		team_chat_console.chatprogram.netadmin_mode = TRUE
		team_chat_console.chatprogram.computer.mob_user = src
		for(var/team_name in GLOB.tournament_teams)
			var/datum/tournament_team/team = GLOB.tournament_teams[team_name]
			if(ckey == GLOB.team_chat_admin_ckeys[1])
				team.team_chat.changeop(team_chat_console.chatprogram)
			team.team_chat.add_client(team_chat_console.chatprogram, TRUE)
		open_team_chat.Grant(src)
		return

	for(var/team_name in GLOB.tournament_teams)
		var/datum/tournament_team/team = GLOB.tournament_teams[team_name]
		if(ckey in team.roster)
			team_chat_console = new
			team_chat_console.chatprogram.username = key
			team.team_chat.add_client(team_chat_console.chatprogram, TRUE)
			team_chat_console.chatprogram.active_channel = team.team_chat.id
			team_chat_console.chatprogram.computer.mob_user = src
			open_team_chat.Grant(src)
			return

/mob/Logout()
	. = ..()
	if(!open_team_chat)
		return
	open_team_chat.Remove(src)
	QDEL_NULL(team_chat_console)

/datum/action/team_chat
	name = "Open Team Chat"
	icon_icon = 'icons/obj/modular_tablet.dmi'
	button_icon_state = "command"

/datum/action/team_chat/Trigger()
	// make sure the program is active in case they closed or minimized it
	if(usr.team_chat_console.cpu.active_program != usr.team_chat_console.chatprogram)
		usr.team_chat_console.chatprogram.program_state = PROGRAM_STATE_ACTIVE
		usr.team_chat_console.cpu.active_program = usr.team_chat_console.chatprogram
	usr.team_chat_console.interact(usr)

/datum/ntnet_conversation/changeop(datum/computer_file/program/chatclient/newop)
	if(istype(newop))
		operator = newop

#define CHANNELNAME_SIZE 32
#define MESSAGE_SIZE 2048

/datum/computer_file/program/chatclient/team
	filename = "ntnrc_client"
	filedesc = "Team Chat Client"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "command"
	extended_desc = "This program allows communication over NTNRC network"
	size = 8
	requires_ntnet = FALSE
	requires_ntnet_feature = NTNET_COMMUNICATION
	ui_header = "ntnrc_idle.gif"
	available_on_ntnet = FALSE
	tgui_id = "NtosNetTeamChat"
	program_icon = "comment-alt"
	alert_able = TRUE

/datum/computer_file/program/chatclient/team/ui_status(mob/user)
	if(program_state != PROGRAM_STATE_ACTIVE) // Our program was closed. Close the ui if it exists.
		return UI_CLOSE
	return UI_INTERACTIVE

/datum/computer_file/program/chatclient/team/ui_act(action, params)
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
			var/message = reject_bad_chattext(params["message"], MESSAGE_SIZE)
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

			active_channel =  new_target
			channel = SSnetworks.station_network.get_chat_channel_by_id(new_target)
			if((!(src in channel.active_clients) && !(src in channel.offline_clients)) && !channel.password)
				channel.add_client(src)
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
		if("PRG_mute_user")
			if(!authed)
				return
			var/datum/computer_file/program/chatclient/team/muted = locate(params["ref"]) in channel.active_clients + channel.offline_clients
			channel.mute_user(src, muted)
			return TRUE
		if("PRG_ping_user")
			if(!authed)
				return
			var/datum/computer_file/program/chatclient/team/pinged = locate(params["ref"]) in channel.active_clients + channel.offline_clients
			channel.ping_user(src, pinged)
			return TRUE

/datum/computer_file/program/chatclient/team/ui_close(mob/user)
	if(program_state != PROGRAM_STATE_KILLED)
		kill_program(forced = TRUE)

/datum/computer_file/program/chatclient/team/kill_program(forced)
	var/last_active = active_channel
	. = ..()
	active_channel = last_active

/datum/computer_file/program/chatclient/team/ui_data(mob/user)
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
		for(var/datum/computer_file/program/chatclient/team/channel_client as anything in channel.active_clients + channel.offline_clients)
			if(channel_client == src)
				authed = TRUE
			clients.Add(list(list(
				"name" = channel_client.username,
				"status" = channel_client.program_state,
				"muted" = (channel_client in channel.muted_clients),
				"operator" = channel.operator == channel_client || channel_client.netadmin_mode,
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

#undef CHANNELNAME_SIZE
#undef MESSAGE_SIZE
