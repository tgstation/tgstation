TIMER_SUBSYSTEM_DEF(runechat)
	name = "Runechat"
	priority = FIRE_PRIORITY_RUNECHAT

	///list that keeps track of all runechat message datums by their creation_string. used to keep track of runechat messages.
	///associative list of the form: list(creation string = the chatmessage datum assigned to that string)
	var/list/messages_by_creation_string = list()
	///queue for runechat messages receiving client MeasureText() calls and ready to create the runechat images
	var/list/datum/callback/message_queue = list()

/datum/controller/subsystem/timer/runechat/fire(resumed)
	. = ..() //poggers
	while(message_queue.len)
		var/datum/callback/queued_message = message_queue[message_queue.len]
		queued_message.Invoke()
		message_queue.len--
		if(MC_TICK_CHECK)
			return
