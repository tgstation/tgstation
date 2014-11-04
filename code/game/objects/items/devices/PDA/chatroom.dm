var/datum/chatroom/default_ntrc_chatroom = new("")
var/list/chatchannels = list(default_ntrc_chatroom.name = default_ntrc_chatroom)

//procs that can be used directly:
//channel.parse_msg

/datum/chatroom
	var/name = "#ss13"
	var/topic = "Welcome to the best NTRC channel in this sector of the galaxy!" // topic message for the chatroom
	var/list/operators = list() // chat operators
	var/list/logs = list() // chat logs
	var/list/muted = list() // muted users
	var/list/banned = list() // banned users
	var/list/auth = list() // authenticated clients
	var/list/users = list() // current users
	var/datum/events/events = new ()
	var/list/datum/event/evlist = list()

//parse_msg() is the exposed interface chat
//clients should interact with parse_msg() and parse_msg() only

/datum/chatroom/proc/parse_msg(client,nick,message)
	var/obj/machinery/message_server/MS = check_server(client)
	if(!MS)
		return "ERR_TCOM"

	if(!nick || length(nick) > 8)
		return "ERR_NICK"

	MS.send_chat_message(nick,name,message)

	if(findtext(message,"/",1,2))
		return handle_command(client,nick,copytext(message,2))

	else
		return send_message(client,nick,message)

//the following are for internal use only

/datum/chatroom/proc/check_server(client)
	var/atom/C = client
	var/turf/CT = get_turf(C)
	if(message_servers)
		for (var/obj/machinery/message_server/MS in message_servers)
			var/turf/T = get_turf(MS)
			if(MS.active && (T.z == CT.z))
				return MS
	return 0

/datum/chatroom/proc/handle_command(client,nick,command) //command parser
	var/list/cmd=text2list(command, " ")

	if(!get_auth(client,nick))
		return "ERR_AUTH"

	switch(cmd[1]) //argument-less commmands
		if("topic")
			if(cmd.len == 1)
				return get_topic(client)
			else
				return set_topic(client,nick,cmd[2])
		if("part")
			return channel_part(client,nick)
		if("delchannel")
			return delete_channel(client,nick)
		if("who")
			return get_who(client, nick)
		if("register")
			return register_auth(client,nick)

	if(cmd.len == 1)
		return "ERR_ARGS"

	switch(cmd[1]) //commands with 1 arg
		if("join")
			return channel_join(client,nick,cmd[2])
		if("log")
			return get_log(client,nick,cmd[2])
		if("op")
			return make_op(client,nick,cmd[2])
		if("deop")
			return deop(client,nick,cmd[2])
		if("ban")
			return ban(client,nick,cmd[2])
		if("unban")
			return unban(client,nick,cmd[2])
		if("kick")
			return kick(client,nick,cmd[2])
		if("mute")
			return mute_nick(client,nick,cmd[2])

	return "ERR_WCMD"

/datum/chatroom/proc/send_message(client,nick,message) //standard message
	if(nick in muted)
		return "ERR_MUTE"
	if(!message)
		return "ERR_BLNK"
	logs += "[strip_html_properly(nick)]> [strip_html_properly(message)]"
	log_chat("[usr]/([usr.ckey]) as [nick] sent to [name]: [message]")
	events.fireEvent("msg_chat",name,nick,message)
	return 1

/datum/chatroom/proc/get_auth(client,nick) //check auth
	if((!(nick in auth)) || (auth[nick] == client))
		return 1
	return 0

//chat commands go here
/datum/chatroom/proc/register_auth(client,nick) //register
	if(!get_auth(client,nick))
		return 0
	auth[nick] = client
	return 1

/datum/chatroom/proc/delete_channel(client,nick) //delchannel
	if(nick in operators)
		for(var/event in events.events)
			events.clearEvent("msg_chat",event)
		qdel(src)
		return 1
	return 0

/datum/chatroom/proc/channel_join(client,nick,channel) //join
	if(!findtext(channel,"#",1,2))
		channel = "#" + channel
	if(channel == name)
		if((nick in banned) || (nick in users))
			return 0
		users += nick
		get_topic(client,nick)
		evlist[nick] = events.addEvent("msg_chat",client,"msg_chat")
		return 1
	else
		if(!(channel in chatchannels))
			var/ret = new_channel(client,nick,channel)
			if(!ret)
				return 0
		channel_part(client,nick)
		var/datum/chatroom/C = chatchannels[channel]
		return C.parse_msg(client,nick,"/join [channel]")

/datum/chatroom/proc/channel_part(client,nick) //part
	users -= nick
	events.clearEvent("msg_chat",evlist[nick])
	return 1

/datum/chatroom/proc/make_op(client,nick,target) //op
	if(nick in operators)
		operators += target
		return 1
	return 0

/datum/chatroom/proc/deop(client,nick,target) //deop
	if(nick in operators)
		operators -= target
		return 1
	return 0

/datum/chatroom/proc/ban(client,nick,target) //ban
	if(nick in operators)
		banned += target
		return 1
	return 0

/datum/chatroom/proc/unban(client,nick,target) //unban
	if(nick in operators)
		banned -= target
		return 1
	return 0

/datum/chatroom/proc/kick(client,nick,target) //kick
	if(nick in operators)
		channel_part(null,nick)
		return 1
	return 0

/datum/chatroom/proc/set_topic(client,nick,newtopic) //topic
	if(nick in operators)
		topic = strip_html_properly(newtopic)
		return 1
	return 0

/datum/chatroom/proc/get_topic(client,nick) //topic
	call(client,"msg_chat")(name,"NTbot","TOPIC: [topic]")
	return 1

/datum/chatroom/proc/get_who(client,nick) //who
	for(var/user in users)
		call(client,"msg_chat")(name,"NTbot","WHO: [user]")
	return 1

/datum/chatroom/proc/get_log(client,nick,lines) //log
	for(var/i=0;i<lines;i++)
		var/mylog = logs[logs.len-i]
		call(client,"msg_chat")(name,"NTbot","LOG[i]: [mylog]")
	return 1

/datum/chatroom/proc/mute_nick(client,nick,target) //mute
	if(nick in operators)
		muted += target
		return 1
	return 0

/datum/chatroom/proc/new_channel(client,nick,target) //called by join
	if(target in chatchannels)
		return 0
	chatchannels[target] = new /datum/chatroom()
	var/datum/chatroom/C = chatchannels[target]
	C.name = target
	C.operators += nick
	return 1
