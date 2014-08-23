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

/atom/movable/proc/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq)
	return

/atom/movable/proc/can_speak()
	return 1

/atom/movable/proc/send_speech(message, range)
	for(var/atom/movable/AM in get_hearers_in_view(range, src))
		AM.Hear(message, src, languages, message)

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
		var/atom/movable/AM = speaker.GetSource()
		if(AM)
			return AM.say_quote(raw_message)
		else
			return speaker.say_quote(raw_message)
	else if(message_langs & HUMAN)
		var/atom/movable/AM = speaker.GetSource()
		if(AM)
			return AM.say_quote(stars(raw_message))
		else
			return speaker.say_quote(stars(raw_message))
	else if(message_langs & MONKEY)
		return "chimpers."
	else if(message_langs & ALIEN)
		return "hisses."
	else if(message_langs & ROBOT)
		return "beeps rapidly."
	else
		return "makes a strange sound."

/proc/get_radio_span(freq)
	switch(freq)
		if(SCI_FREQ)
			return "sciradio"
		if(MED_FREQ)
			return "medradio"
		if(ENG_FREQ)
			return "engradio"
		if(SEC_FREQ)
			return "secradio"
		if(COMM_FREQ)
			return "comradio"
		if(SUPP_FREQ)
			return "suppradio"
		if(AIPRIV_FREQ)
			return "aiprivradio"
		if(SYND_FREQ)
			return "syndradio"
		if(SERV_FREQ)
			return "servradio"
		if(DSQUAD_FREQ)
			return "dsquadradio"
	return "radio"

/proc/get_radio_name(freq) //There's probably a way to use the list var of channels in code\game\communications.dm to make the dept channels non-hardcoded, but I wasn't in an experimentive mood. --NEO
	switch(freq)
		if(COMM_FREQ)
			return "Command"
		if(SCI_FREQ)
			return "Science"
		if(MED_FREQ)
			return "Medical"
		if(ENG_FREQ)
			return "Engineering"
		if(SEC_FREQ)
			return "Security"
		if(SUPP_FREQ)
			return "Supply"
		if(AIPRIV_FREQ)
			return "AI Private"
		if(SYND_FREQ)
			return "#unkn"
		if(SERV_FREQ)
			return "Service"
	return "[copytext("[freq]", 1, 4)].[copytext("[freq]", 4, 5)]"

/atom/movable/proc/GetVoice()
	return name

/atom/movable/proc/IsVocal()
	return 1

/atom/movable/proc/get_alt_name()
	return

//these exist mostly to deal with the AIs hrefs and job stuff.
/atom/movable/proc/GetJob()
	return

/atom/movable/proc/GetTrack()
	return

/atom/movable/proc/GetSource()
	return

/atom/movable/proc/GetRadio()

/atom/movable/virtualspeaker
	var/job
	var/faketrack
	var/atom/movable/source
	var/obj/item/device/radio/radio

/atom/movable/virtualspeaker/GetJob()
	return job

/atom/movable/virtualspeaker/GetTrack()
	return faketrack

/atom/movable/virtualspeaker/GetSource()
	return source

/atom/movable/virtualspeaker/GetRadio()
	return radio

/atom/movable/verb/say_something(message as text)
	set name = "make honk"
	set category = "IC"
	set src in view()

	say(message)
