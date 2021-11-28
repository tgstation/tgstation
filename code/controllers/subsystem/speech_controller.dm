SUBSYSTEM_DEF(speech_controller)
	name = "Speech Controller"
	wait = 1
	flags = SS_TICKER
	priority = FIRE_PRIORITY_SPEECH_CONTROLLER//has to be high priority, second in priority ONLY to SSinput
	init_order = INIT_ORDER_SPEECH_CONTROLLER
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	///associative list of the form: list(client mob = message or messages that mob is queued to say).
	///this is our process queue, processed every tick.
	var/list/queued_says_to_execute = list()
	///how many says we've processed since the last stat_entry()
	var/say_tracker = 0

///queues mob_to_queue into our process list so they say(message) near the start of the next tick
/datum/controller/subsystem/speech_controller/proc/queue_say_for_mob(mob/mob_to_queue, message)
	if(QDELETED(mob_to_queue) || !message)
		return FALSE

	//if NO messages are queued for this mob, associate mob_to_queue and message in queued_says_to_execute
	//if ONE message is already queued for this mob, make the list association into its own list composed of the new and old message
	//if there are TWO OR MORE messages already queued for this mob add the new message to the list.
	//im 99% sure you shouldnt be able to send more than one message per tick anyways but in case you can we cannot drop them under any circumstances
	var/list/already_queued_message = queued_says_to_execute[mob_to_queue]//this should always be null, like always. but just in case
	if(already_queued_message)
		if(istext(already_queued_message))
			queued_says_to_execute[mob_to_queue] = list(already_queued_message, message)

		else if(islist(already_queued_message))
			already_queued_message += message //append the message to the end of the associated list so its said at the end

	else//there isnt already a queued message
		queued_says_to_execute[mob_to_queue] = message

	return TRUE

/datum/controller/subsystem/speech_controller/fire(resumed)
	if(!length(queued_says_to_execute))
		return

	for(var/mob/mob_to_say as anything in queued_says_to_execute)
		if(QDELETED(mob_to_say))
			queued_says_to_execute -= mob_to_say
			continue

		var/list/mob_message_or_messages = queued_says_to_execute[mob_to_say]

		if(islist(mob_message_or_messages))
			for(var/message in mob_message_or_messages)
				mob_to_say.say(message)
				say_tracker++

		else
			mob_to_say.say(mob_message_or_messages)
			say_tracker++

		queued_says_to_execute -= mob_to_say

/datum/controller/subsystem/speech_controller/stat_entry(msg)
	msg = "S:[say_tracker]"
	say_tracker = 0
	return ..()


