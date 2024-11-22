TIMER_SUBSYSTEM_DEF(runechat)
	name = "Runechat"
	priority = FIRE_PRIORITY_RUNECHAT

	var/list/datum/callback/message_queue = list()

/datum/controller/subsystem/timer/runechat/fire(resumed)
	. = ..() //poggers
	while(message_queue.len)
		var/datum/chatmessage/queued_message = message_queue[message_queue.len]
		var/datum/callback/message_callback = message_queue[queued_message]
		message_callback.Invoke()
		message_queue -= queued_message
		if(MC_TICK_CHECK)
			return
