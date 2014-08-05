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

/atom/movable/proc/Hear(message, atom/movable/speaker, message_langs, raw_message, steps = 0, radio_freq)
	return

/atom/movable/proc/can_speak()
	return 1

/atom/movable/proc/send_speech(message, range, steps)
	for(var/atom/movable/AM in get_hearers_in_view(range))
		AM.Hear(message, src, languages, message, steps)

/atom/movable/proc/say_quote(var/text)
	if(!text)
		return "says, \"...\""	//not the best solution, but it will stop a large number of runtimes. The cause is somewhere in the Tcomms code
	var/ending = copytext(text, length(text))
	if (ending == "?")
		return "asks, \"[text]\""
	if (ending == "!")
		return "exclaims, \"[text]\""

	return "says, \"[text]\""

/atom/movable/proc/lang_treat(message, atom/movable/speaker, message_langs, raw_message)
	if(languages & message_langs)
		return message
	else if(message_langs & HUMAN)
		return "<span class='game say'><span class='name'>[speaker.GetVoice()]</span> <span class='message'>[say_quote(stars(raw_message))]</span></span>"
	else if(message_langs & MONKEY)
		return "<span class='game say'><span class='name'>[speaker.GetVoice()]</span> <span class='message'>chimpers.</span></span>"
	else if(message_langs & ALIEN)
		return "<span class='game say'><span class='name'>[speaker.GetVoice()] </span><span class='message'>hisses.</span></span>"
	else if(message_langs & ROBOT)
		return "<span class='game say'><span class='name'>[speaker.GetVoice()]</span> <span class='message'>beeps rapidly.</span></span>"
	else
		return "<span class='game say'><span class='name'>[speaker.GetVoice()]</span> <span class='message'>makes a strange sound.</span></span>"

/atom/movable/proc/GetVoice()
	return name
