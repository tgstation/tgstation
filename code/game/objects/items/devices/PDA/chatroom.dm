var/datum/chatroom/default_ntrc_chatroom = new()
var/list/chatchannels = list(default_ntrc_chatroom.name = default_ntrc_chatroom)

//procs that can be used directly:
//channel.parse_msg

/datum/chatroom
	var/name = "#ss13"
	var/list/logs = list() // chat logs
	var/list/auth = list() // authenticated clients
	var/list/authed = list() //authenticated users
	var/datum/events/events = new ()
	var/list/datum/event/evlist = list()

//parse_msg() is the exposed interface chat
//clients should interact with parse_msg() and parse_msg() only

/datum/chatroom/proc/parse_msg(client,nick,message)
	var/obj/machinery/message_server/MS = check_server(client)
	if(!MS)
		return "BAD_TCOM"

	if(!get_auth(client,nick) || !nick || length(nick) > 8)
		return "BAD_NICK"

	MS.send_chat_message(nick,name,message)

	if(findtext(message,"/",1,2))
		var/list/cmd=text2list(message, " ")
		switch(cmd[1])
			if("/register")
				if(cmd.len == 1)
					return register_auth(client,nick)
				else
					return "BAD_COMMAND_ARGUMENTS"
			if("/join")
				if(cmd.len == 2 && cmd[2])
					if((findtext(cmd[2],"#",1,2) && length(cmd[2]) > 1) || (!findtext(cmd[2],"#",1,2) && length(cmd[2]) > 0))
						return channel_join(client,nick,copytext(cmd[2], 1, 15))
					else // Happens only if "" or "#" is entered as a channel name.
						return "BAD_CHANNEL"
				else
					return "BAD_COMMAND_ARGUMENTS"
			if("/log")
				if(cmd.len == 2 && cmd[2])
					return get_log(client,nick,cmd[2])
				else
					return "BAD_COMMAND_ARGUMENTS"
			else
				return "BAD_COMMAND"

	return send_message(client,nick,message)

//the following are helper procs, FOR INTERNAL USE ONLY

/datum/chatroom/proc/check_server(client)
	var/atom/C = client
	var/turf/CT = get_turf(C)
	if(message_servers)
		for (var/obj/machinery/message_server/MS in message_servers)
			var/turf/T = get_turf(MS)
			if(MS.active && (T.z == CT.z))
				return MS
	return null

/datum/chatroom/proc/send_message(client,nick,message) //standard message
	if(!message)
		return 0
	logs.Insert(1,"[strip_html_properly(nick)]> [strip_html_properly(message)]")
	log_chat("[usr]/([usr.ckey]) as [nick] sent to [name]: [message]")
	events.fireEvent("msg_chat",name,nick,message)
	return 1

/datum/chatroom/proc/get_auth(client,nick) //check auth
	if((!(nick in authed)) || (auth[client] == nick))
		return 1
	return 0

//chat commands go here, FOR INTERNAL USE ONLY
/datum/chatroom/proc/register_auth(client,nick) //register
	if(!get_auth(client,nick))
		return "BAD_REGS"
	auth[client] = nick
	authed += nick
	return 1

/datum/chatroom/proc/channel_join(client,nick,channel) //join
	if(!findtext(channel,"#",1,2))
		channel = "#" + channel
	if(channel == name) //join this channel
		if(!(client in evlist))
			evlist[client] = events.addEvent("msg_chat",client,"msg_chat")
		return name

	else //leave this channel, join another one
		if(client in evlist)
			events.clearEvent("msg_chat",evlist[client])
			evlist -= client
		if(!(channel in chatchannels))
			var/datum/chatroom/NC = new /datum/chatroom()
			NC.name = channel
			chatchannels[channel] = NC
		var/datum/chatroom/C = chatchannels[channel]
		return C.parse_msg(client,nick,"/join [channel]")

/datum/chatroom/proc/get_log(client,nick,lines) //log
	lines = text2num(lines)
	lines = min(lines, logs.len)
	for(var/i=0;i<lines;i++)
		call(client,"msg_chat")(name,"NTbot","LOG[i]: [logs[(logs.len)-i]]")
	return 1
