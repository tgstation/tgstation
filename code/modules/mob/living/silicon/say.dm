/mob/living/silicon/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, \"[text]\"";
	else if (ending == "!")
		return "declares, \"[text]\"";

	return "states, \"[text]\"";

/mob/living/silicon/say(var/message)
	return ..(message, "R")

/mob/living/silicon/robot/IsVocal()
		return !config.silent_borg

/mob/living/proc/robot_talk(var/message)

	log_say("[key_name(src)] (@[src.x],[src.y],[src.z])(binary): [message]")


	var/message_a = say_quote(message)
	var/rendered = "<i><span class='game say'>Robotic Talk, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i>"

	for (var/mob/living/S in living_mob_list)
		if(S.binarycheck() || S.stat == DEAD) // This SHOULD catch everything caught by the one below, but I'm not going to change it.
			if(istype(S , /mob/living/silicon/ai) && !isMoMMI(src))
				var/renderedAI = "<i><span class='game say'>Robotic Talk, <a href='byond://?src=\ref[S];track2=\ref[S];track=\ref[src]'><span class='name'>[name]</span></a> <span class='message'>[message_a]</span></span></i>"
				S << renderedAI
			else
				S << rendered
	for(var/mob/dead/observer/O in dead_mob_list)
		if(istype(O , /mob/dead/observer) && O.stat == DEAD)
			var/rendered_Obs = "<i><span class='game say'>Robotic Talk, <span class='name'>[name]</span> <a href='byond://?src=\ref[O];follow2=\ref[O];follow=\ref[src]'>(Follow)</a> <span class='message'>[message_a]</span></span></i>"
			O << rendered_Obs

/mob/living/silicon/binarycheck()
	return 1

/mob/living/silicon/lingcheck()
	return 0 //Borged or AI'd lings can't speak on the ling channel.

/mob/living/silicon/radio(message, message_mode)
	. = ..()
	if(. != 0)
		return .
	if(message_mode == "robot")
		if(radio)
			radio.talk_into(src, message)
		return REDUCE_RANGE

	else if(message_mode in radiochannels)
		if(radio)
			radio.talk_into(src, message, message_mode)
			return ITALICS | REDUCE_RANGE
	return 0

/mob/living/silicon/get_message_mode(message)
	. = ..()
	if(..() == MODE_HEADSET)
		return MODE_ROBOT
	else
		return .

/mob/living/silicon/handle_inherent_channels(message, message_mode)
	. = ..()
	if(.)
		return .

	if(message_mode == MODE_BINARY)
		if(binarycheck())
			robot_talk(message)
			return 1
	return 0

/mob/living/silicon/treat_message(message, genesay = 0)
	message = ..()
	message = "<span class='siliconsay'>[message]</span>"
	return message