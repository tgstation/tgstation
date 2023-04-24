TIMER_SUBSYSTEM_DEF(runechat)
	name = "Runechat"
	priority = FIRE_PRIORITY_RUNECHAT

	var/list/datum/callback/message_queue = list()

/datum/controller/subsystem/timer/runechat/fire(resumed)
	. = ..() //poggers
	while(message_queue.len)
		var/datum/callback/queued_message = message_queue[message_queue.len]
		queued_message.Invoke()
		message_queue.len--
		if(MC_TICK_CHECK)
			return
