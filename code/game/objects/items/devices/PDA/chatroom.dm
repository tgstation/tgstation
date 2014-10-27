var/datum/chatroom/default_ntrc_chatroom = new("")
var/list/chatchannels = list(default_ntrc_chatroom.name = default_ntrc_chatroom)

//procs that can be used directly:
//channel.parse_msg

/datum/chatroom
	var/name = "ss13"
	var/channelpassword = ""
	var/operator = ""
	var/topic = "Welcome to #ss13! The best NTRC channel in this sector of the galaxy!" // topic message for the chatroom
	var/list/logs = list() // chat logs
	var/list/muted = list() // muted users
	var/list/auth = list()
	var/list/pass = list()
	var/datum/events/events = new ()

/datum/chatroom/New()
	channelpassword = rand()

//parse_msg() is the exposed interface
//clients should interact with parse_msg() and parse_msg() only

/datum/chatroom/proc/parse_msg(client,nick,message)
	if(!check_server(client))
		return "ERR_TCOM"

	if(!nick || length(nick) > 8)
		return "ERR_NICK"

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
				return 1
	return 0

/datum/chatroom/proc/handle_command(client,nick,command) //command parser
	var/list/cmd=text2list(command, " ")

	if(cmd[1] == "auth" && cmd.len > 1) //parsed here to avoid triggering ERR_AUTH
		return attempt_auth(client,nick,cmd[2])

	if(!get_auth(client,nick))
		return "ERR_AUTH"

	switch(cmd[1]) //argument-less commmands
		if("join")
			return channel_join(client,nick)
		if("topic")
			if(cmd.len == 1)
				return get_topic(client)
			else
				return set_topic(client,nick,cmd[2])
		if("del")
			return delete_channel(client,nick)

	if(cmd.len == 1)
		return "ERR_ARGS"

	switch(cmd[1]) //commands with 1 arg
		if("op")
			return operator_auth(client,nick,cmd[2])
		if("register")
			return register_auth(client,nick,cmd[2])
		if("mute")
			return mute_nick(client,nick,cmd[2])
		if("new")
			return new_channel(client,nick,cmd[2])
		if("pass")
			return new_pass(client,nick,cmd[2])

	return "ERR_WCMD"

/datum/chatroom/proc/send_message(client,nick,message) //standard message
	if(nick in muted)
		return "ERR_MUTE"
	if(!message)
		return "ERR_BLNK"
	logs += "[strip_html_properly(nick)]> [strip_html_properly(message)]<"
	events.fireEvent("msg_chat",name,nick,message)
	return 1

/datum/chatroom/proc/get_auth(client,nick) //check auth
	if(!pass[nick] || (auth[nick] == client))
		return 1
	return 0

//chat commands go here
/datum/chatroom/proc/attempt_auth(client,nick,password) //auth
	if(pass[nick] == password)
		auth[nick] = client
		return 1
	return 0

/datum/chatroom/proc/register_auth(client,nick,password) //register
	if(pass[nick] && (get_auth(client,nick) != client))
		return 0
	pass[nick] = password
	return 1

/datum/chatroom/proc/delete_channel(client,nick) //delete
	if(nick == operator)
		for(var/event in events.events)
			events.clearEvent("msg_chat",event)
		qdel(src)
		return 1
	return 0

/datum/chatroom/proc/channel_join(client,nick) //join
	get_topic(client,nick)
	return events.addEvent("msg_chat",client,"msg_chat")

/datum/chatroom/proc/operator_auth(client,nick,pass) //op
	if(pass == channelpassword)
		operator += nick
		return 1
	return 0

/datum/chatroom/proc/set_topic(client,nick,newtopic) //topic
	if(operator == nick)
		topic = strip_html_properly(newtopic)
		return 1
	return 0

/datum/chatroom/proc/get_topic(client,nick) //topic
	call(client,"msg_chat")(name,"NTbot",topic)
	return 1

/datum/chatroom/proc/get_log(client,nick,lines) //log
	for(var/i=0;i<lines;i++)
		call(client,"msg_chat")(name,"NTbot",logs[logs.len-i])
	return 1

/datum/chatroom/proc/mute_nick(client,nick,target) //mute
	if(operator == nick)
		muted += target
		return 1
	return 0

/datum/chatroom/proc/new_channel(client,nick,target) //new
	if(!(target in chatchannels))
		chatchannels[target] = new /datum/chatroom()
	var/datum/chatroom/C = chatchannels[target]
	C.name = target
	C.operator = nick
	return 1

/datum/chatroom/proc/new_pass(client,nick,target) //pass
	if(operator == nick)
		channelpassword = target
		return 1
	return 0
