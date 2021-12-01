SUBSYSTEM_DEF(speech_controller)
	name = "Speech Controller"
	wait = 1
	flags = SS_TICKER
	priority = FIRE_PRIORITY_SPEECH_CONTROLLER//has to be high priority, second in priority ONLY to SSinput
	init_order = INIT_ORDER_SPEECH_CONTROLLER
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

	///list of the form: list(client mob, message that mob is queued to say, other say arguments (if any)).
	///this is our process queue, processed every tick.
	var/list/queued_says_to_execute = list()

///queues mob_to_queue into our process list so they say(message) near the start of the next tick
/datum/controller/subsystem/speech_controller/proc/queue_say_for_mob(mob/mob_to_queue, message, ...)
	if(!ismob(mob_to_queue) || mob_to_queue.gc_destroyed || !message)
		return FALSE

	if(!TICK_CHECK)
		mob_to_queue.say(arglist(args.Copy(2)))//master isnt that overloaded, dont delay the message
		return TRUE

	queued_says_to_execute += list(args.Copy())

	return TRUE

/datum/controller/subsystem/speech_controller/fire(resumed)

	///	cache for sanic speed (lists are references anyways)
	var/list/says_to_process = queued_says_to_execute.Copy()
	says_to_process.Cut()//we should be going through the entire list every single iteration
	for(var/list/say_args as anything in says_to_process)
		var/mob/mob_to_speak = say_args[1]
		if(!ismob(mob_to_speak) || mob_to_speak.gc_destroyed || !say_args[2])//index 1 is the mob, 2 is the message, 3+ are optional
			continue

		say_args -= mob_to_speak

		mob_to_speak.say(arglist(say_args))





