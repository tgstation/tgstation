/*
 	Miauw's big Say() rewrite.
	This file has the basic atom/movable level speech procs.
	And the base of the send_speech() proc, which is the core of saycode.
*/
/atom/movable/proc/say(message)
	if(!can_speak())
		return
	if(message == "" || !message)
		return
	send_speech(message)

/atom/movable/proc/Hear(message, atom/movable/speaker, message_langs, raw_message)
	return

/atom/movable/proc/can_speak()
	return 1

/atom/movable/proc/can_hear()
	return 0

/atom/movable/proc/send_speech(message) //PLACEHOLDER
	for(var/atom/movable/AM in range(7))
		if(AM.can_hear())
			AM.Hear(message, src, languages, message)

/mob/say_quote(var/text)
	if(!text)
		return "says, \"...\""	//not the best solution, but it will stop a large number of runtimes. The cause is somewhere in the Tcomms code
	var/ending = copytext(text, length(text))
	if (stuttering)
		return "stammers, \"[text]\""
	if(isliving(src))
		var/mob/living/L = src
		if (L.getBrainLoss() >= 60)
			return "gibbers, \"[text]\""
	if (ending == "?")
		return "asks, \"[text]\""
	if (ending == "!")
		return "exclaims, \"[text]\""

	return "says, \"[text]\""
