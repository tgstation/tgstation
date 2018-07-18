SUBSYSTEM_DEF(chat)
	name = "Chat"
	wait = 5
	init_order = INIT_ORDER_CHAT
	priority = FIRE_PRIORITY_CHAT
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	var/list/browser_chat_queue
	var/list/old_chat_queue

/datum/controller/subsystem/chat/Initialize()
	browser_chat_queue = list()
	old_chat_queue = list()
	return ..()

/datum/controller/subsystem/chat/fire()
	var/list/queue = browser_chat_queue
	while(queue.len)
		var/client/user = queue[queue.len]
		var/message = queue[user]
		queue.len--
		if(istype(message, /list))
			user << output(list2params(message), "browseroutput:output_list")
		else
			user << output(message, "browseroutput:output")
	
	queue = old_chat_queue
	while(queue.len)
		var/client/user = queue[queue.len]
		var/message = queue[user]
		queue.len--
		if(istype(message, /list))
			message = jointext(message, "\n")
		SEND_TEXT(user, message)

/datum/controller/subsystem/chat/proc/queue_message(client/user, message, oldchat=FALSE)
	if(!oldchat)
		if(!user.chatOutput || user.chatOutput.broken) // A player who hasn't updated his skin file.
			return
		if(!user.chatOutput.loaded)
			//Client still loading, put their messages in a queue
			user.chatOutput.messageQueue += message
			return
		message = url_encode(message)
	var/list/queue = oldchat ? old_chat_queue : browser_chat_queue
	if(!queue[user])						// No entry yet; Directly set it
		queue[user] = message
	else if(!istype(queue[user], /list))	// Solo entry; Convert to list
		queue[user] = list(queue[user], message)
	else									// Multi entry in list; Append
		queue[user] += message
		