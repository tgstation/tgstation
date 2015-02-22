/*
 	Miauw's big Say() rewrite.
	This file has the basic atom/movable level speech procs.
	And the base of the send_speech() proc, which is the core of saycode.
*/
var/list/freqtospan = list(
	"1351" = "sciradio",
	"1355" = "medradio",
	"1357" = "engradio",
	"1347" = "suppradio",
	"1349" = "servradio",
	"1359" = "secradio",
	"1353" = "comradio",
	"1447" = "aiprivradio",
	"1213" = "syndradio",
	"1441" = "dsquadradio"
	)

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
	var/rendered = compose_message(src, languages, message)
	for(var/atom/movable/AM in get_hearers_in_view(range, src))
		AM.Hear(rendered, src, languages, message)

/atom/movable/proc/compose_message(atom/movable/speaker, message_langs, raw_message, radio_freq)
	//This proc uses text() because it is faster than appending strings. Thanks BYOND.
	//Basic span
	var/spanpart1 = "<span class='[radio_freq ? get_radio_span(radio_freq) : "game say"]'>"
	//Start name span.
	var/spanpart2 = "<span class='name'>"
	//Radio freq/name display
	var/freqpart = radio_freq ? "\[[get_radio_name(radio_freq)]\] " : ""
	//Speaker name
	var/namepart =  "[speaker.GetVoice()][speaker.get_alt_name()]"
	//End name span.
	var/endspanpart = "</span>"
	//Message
	var/messagepart = " <span class='message'>[lang_treat(speaker, message_langs, raw_message)]</span></span>"

	return "[spanpart1][spanpart2][freqpart][compose_track_href(speaker, message_langs, raw_message, radio_freq)][namepart][compose_job(speaker, message_langs, raw_message, radio_freq)][endspanpart][messagepart]"

/atom/movable/proc/compose_track_href(atom/movable/speaker, message_langs, raw_message, radio_freq)
	return ""

/atom/movable/proc/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	return ""

/atom/movable/proc/say_quote(var/text)
	if(!text)
		return "says, \"...\""	//not the best solution, but it will stop a large number of runtimes. The cause is somewhere in the Tcomms code
	var/ending = copytext(text, length(text))
	if(ending == "?")
		return "asks, \"[text]\""
	if(copytext(text, length(text) - 1) == "!!")
		return "yells, \"<span class = 'yell'>[text]</span>\""
	if(ending == "!")
		return "exclaims, \"[text]\""

	return "says, \"[text]\""

/atom/movable/proc/lang_treat(atom/movable/speaker, message_langs, raw_message)
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
	else if(message_langs & DRONE)
		return "chitters."
	else
		return "makes a strange sound."

/proc/get_radio_span(freq)
	var/returntext = freqtospan["[freq]"]
	if(returntext)
		return returntext
	return "radio"

/proc/get_radio_name(freq)
	var/returntext = radiochannelsreverse["[freq]"]
	if(returntext)
		return returntext
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
