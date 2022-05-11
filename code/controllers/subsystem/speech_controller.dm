/// verb_manager subsystem just for handling say's
VERB_MANAGER_SUBSYSTEM_DEF(speech_controller)
	name = "Speech Controller"
	wait = 1
	priority = FIRE_PRIORITY_SPEECH_CONTROLLER//has to be high priority, second in priority ONLY to SSinput

/*
///queues mob_to_queue into our process list so they say(message) near the start of the next tick
/datum/controller/subsystem/verb_manager/speech_controller/proc/queue_say_for_mob(mob/mob_to_queue, message, message_type)

	if(!TICK_CHECK || FOR_ADMINS_IF_BROKE_immediately_execute_all_speech)
		process_single_say(mob_to_queue, message, message_type)
		return TRUE

	queued_says_to_execute += list(list(mob_to_queue, message, message_type))

	return TRUE

/datum/controller/subsystem/verb_manager/speech_controller/fire(resumed)

	///	cache for sanic speed (lists are references anyways)
	var/list/says_to_process = queued_says_to_execute.Copy()
	queued_says_to_execute.Cut()//we should be going through the entire list every single iteration

	for(var/list/say_to_process as anything in says_to_process)

		var/mob/mob_to_speak = say_to_process[MOB_INDEX]//index 1 is the mob, 2 is the message, 3 is the message category
		var/message = say_to_process[MESSAGE_INDEX]
		var/message_category = say_to_process[CATEGORY_INDEX]

		process_single_say(mob_to_speak, message, message_category)

///used in fire() to process a single mobs message through the relevant proc.
///only exists so that sleeps in the message pipeline dont cause the whole queue to wait
/datum/controller/subsystem/verb_manager/speech_controller/proc/process_single_say(mob/mob_to_speak, message, message_category)
	set waitfor = FALSE

	switch(message_category)
		if(SPEECH_CONTROLLER_QUEUE_SAY_VERB)
			mob_to_speak.say(message)

		if(SPEECH_CONTROLLER_QUEUE_WHISPER_VERB)
			mob_to_speak.whisper(message)

		if(SPEECH_CONTROLLER_QUEUE_EMOTE_VERB)
			mob_to_speak.emote("me",1,message,TRUE)
*/
