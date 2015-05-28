/*
 	Miauw's big Say() rewrite.
	This file has the basic atom/movable level speech procs.
	And the base of the send_speech() proc, which is the core of saycode.
*/
var/list/freqtospan = list(
	"1351" = "sciradio",
	"1355" = "medradio",
	"1357" = "engradio",
	"1347" = "supradio",
	"1349" = "serradio",
	"1359" = "secradio",
	"1353" = "comradio",
	"1447" = "aiprivradio",
	"1213" = "syndradio",
	"1441" = "dsquadradio",
	"1345" = "resteamradio",
	)

var/list/freqtoname = list(
	"1351" = "Science",
	"1353" = "Command",
	"1355" = "Medical",
	"1357" = "Engineering",
	"1359" = "Security",
	"1441" = "Deathsquad",
	"1213" = "Syndicate",
	"1347" = "Supply",
	"1349" = "Service",
	"1447" = "AI Private",
	"1345" = "Response Team",
)

/atom/movable/proc/say(message, var/datum/language/speaking) //so we can force nonmobs to speak a certain language
	if(!can_speak())
		return
	if(message == "" || !message)
		return
	send_speech(message, speaking)

/atom/movable/proc/Hear(message, atom/movable/speaker, var/datum/language/speaking, raw_message, radio_freq)
	return

/atom/movable/proc/can_speak()
	return 1

/atom/movable/proc/send_speech(message, range, var/datum/language/speaking)
	say_testing(src, "send speech start, msg = [message]; message_range = [range]; language = [speaking ? speaking.name : "None"];")
	if(isnull(range)) range = 7
	var/rendered = compose_message(src, speaking, message)
	for(var/atom/movable/AM in get_hearers_in_view(range, src))
		AM.Hear(rendered, src, speaking, message)

/atom/movable/proc/compose_message(atom/movable/speaker, var/datum/language/speaking, raw_message, radio_freq)
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
	var/messagepart = "<span class='message'>[lang_treat(speaker, speaking, raw_message)]</span></span>"
	var/trackingpart = compose_track_href(speaker, speaking, raw_message, radio_freq)
	return "[spanpart1][spanpart2][trackingpart][namepart][trackingpart ? "</a>" : ""]\icon[speaker.GetRadio()][freqpart][compose_job(speaker, speaking, raw_message, radio_freq)][endspanpart][messagepart]"

/atom/movable/proc/compose_track_href(atom/movable/speaker, var/datum/language/speaking, raw_message, radio_freq)
	return ""

/atom/movable/proc/compose_job(atom/movable/speaker, var/datum/language/speaking, raw_message, radio_freq)
	return ""

/atom/movable/proc/say_quote(var/text)
	if(!text)
		return "says, \"...\""	//not the best solution, but it will stop a large number of runtimes. The cause is somewhere in the Tcomms code
	var/ending = copytext(text, length(text))
	if (ending == "?")
		return "asks, \"[text]\""
	if (ending == "!")
		return "exclaims, \"[text]\""

	return "says, \"[text]\""
var/global/image/ghostimg = image("icon"='icons/mob/mob.dmi',"icon_state"="ghost")
/atom/movable/proc/lang_treat(atom/movable/speaker, var/datum/language/speaking, raw_message)
	if(speaking)
		var/overRadio = (istype(speaker, /obj/item/device/radio) || istype(speaker.GetSource(), /obj/item/device/radio))
		var/atom/movable/AM = speaker.GetSource()
		if(say_understands((istype(AM) ? AM : speaker),speaking))
			if(overRadio)
				return speaking.format_message_radio(speaker, raw_message)
			return speaking.format_message(speaker, raw_message)
		else
			if(overRadio)
				return speaking.format_message_radio(speaker, speaking.scramble(raw_message))
			return speaking.format_message(speaker, speaking.scramble(raw_message))

	else
		var/atom/movable/AM = speaker.GetSource()
		var/rendered = raw_message
		if(!say_understands(speaker))
			rendered = stars(rendered)
		if(AM)
			return AM.say_quote(rendered)
		else
			return speaker.say_quote(rendered)
	/*else if(message_langs & SPOOKY)
		return "\icon[ghostimg] <span class='sinister'>Too spooky...</span> \icon[ghostimg]"
	else if(message_langs & MONKEY)
		return "chimpers."
	else if(message_langs & ALIEN)
		return "hisses."
	else if(message_langs & ROBOT)
		return "beeps rapidly."
	else if(message_langs & SIMPLE_ANIMAL)
		var/mob/living/simple_animal/SA = speaker.GetSource()
		if(!SA || !istype(SA))
			SA = speaker
		if(istype(SA))
			return "[pick(SA.speak_emote)]."
		else
			return "makes a strange sound."
	else
		return "makes a strange sound."*/

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

/proc/attach_spans(input, list/spans)
	return "[message_spans(spans)][input]</span>"

/proc/message_spans(list/spans)
	var/output = "<SPAN CLASS='"

	for(var/span in spans)
		output = "[output][span] "

	output = "[output]'>"
	return output


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
	return src

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

/atom/movable/virtualspeaker/resetVariables()
	job = null
	faketrack = null
	source = null
	radio = null

	..("job", "faketrack", "source", "radio")

proc/handle_render(var/mob,var/message,var/speaker)
	if(istype(mob, /mob/new_player)) return //One extra layer of sanity
	if(istype(mob,/mob/dead/observer))
		var/reference = "<a href='?src=\ref[mob];follow=\ref[speaker]'>(Follow)</a> "
		message = reference+message
		mob << message
	else
		mob << message
