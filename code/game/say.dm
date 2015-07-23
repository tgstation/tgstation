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
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/say() called tick#: [world.time]")
	if(!can_speak())
		return
	if(message == "" || !message)
		return
	send_speech(message, world.view, speaking)

/atom/movable/proc/Hear(message, atom/movable/speaker, var/datum/language/speaking, raw_message, radio_freq)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/Hear() called tick#: [world.time]")
	return

/atom/movable/proc/can_speak()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/can_speak() called tick#: [world.time]")
	return 1

/atom/movable/proc/send_speech(message, range, var/datum/language/speaking)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/send_speech() called tick#: [world.time]")
	//say_testing(src, "send speech start, msg = [message]; message_range = [range]; language = [speaking ? speaking.name : "None"];")
	if(isnull(range)) range = 7
	var/rendered = compose_message(src, speaking, message)
	for(var/atom/movable/AM in get_hearers_in_view(range, src))
		AM.Hear(rendered, src, speaking, message)

/atom/movable/proc/compose_message(atom/movable/speaker, var/datum/language/speaking, raw_message, radio_freq)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/compose_message() called tick#: [world.time]")
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
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/compose_track_href() called tick#: [world.time]")
	return ""

/atom/movable/proc/compose_job(atom/movable/speaker, var/datum/language/speaking, raw_message, radio_freq)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/compose_job() called tick#: [world.time]")
	return ""

/atom/movable/proc/say_quote(var/text)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/say_quote() called tick#: [world.time]")
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
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/lang_treat() called tick#: [world.time]")
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
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/get_radio_span() called tick#: [world.time]")
	var/returntext = freqtospan["[freq]"]
	if(returntext)
		return returntext
	return "radio"

/proc/get_radio_name(freq)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/get_radio_name() called tick#: [world.time]")
	var/returntext = radiochannelsreverse["[freq]"]
	if(returntext)
		return returntext
	return "[copytext("[freq]", 1, 4)].[copytext("[freq]", 4, 5)]"

/proc/attach_spans(input, list/spans)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/attach_spans() called tick#: [world.time]")
	return "[message_spans(spans)][input]</span>"

/proc/message_spans(list/spans)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/message_spans() called tick#: [world.time]")
	var/output = "<SPAN CLASS='"

	for(var/span in spans)
		output = "[output][span] "

	output = "[output]'>"
	return output


/atom/movable/proc/GetVoice()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/GetVoice() called tick#: [world.time]")
	return name

/atom/movable/proc/IsVocal()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/IsVocal() called tick#: [world.time]")
	return 1

/atom/movable/proc/get_alt_name()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/get_alt_name() called tick#: [world.time]")
	return

//these exist mostly to deal with the AIs hrefs and job stuff.
/atom/movable/proc/GetJob()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/GetJob() called tick#: [world.time]")
	return

/atom/movable/proc/GetTrack()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/GetTrack() called tick#: [world.time]")
	return

/atom/movable/proc/GetSource()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/GetSource() called tick#: [world.time]")
	return src

/atom/movable/proc/GetRadio()
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/atom/movable/proc/GetRadio() called tick#: [world.time]")

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
	//writepanic("[__FILE__].[__LINE__] \\/proc/handle_render() called tick#: [world.time]")
	if(istype(mob, /mob/new_player)) return //One extra layer of sanity
	if(istype(mob,/mob/dead/observer))
		var/reference = "<a href='?src=\ref[mob];follow=\ref[speaker]'>(Follow)</a> "
		message = reference+message
		mob << message
	else
		mob << message

var/global/resethearers = 0

/proc/sethearing()
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/sethearing() called tick#: [world.time]")
	var/atom/A
	for(var/mob/virtualhearer/VH in virtualhearers)
		if(isnull(VH.attached))
			returnToPool(VH)
			continue
		for(A=VH.attached.loc, A && !isturf(A), A=A.loc);
		VH.loc = A
	resethearers = world.time + 5

// Returns a list of hearers in range of R from source. Used in saycode.
/proc/get_hearers_in_view(var/R, var/atom/source)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/get_hearers_in_view() called tick#: [world.time]")
	if(world.time>resethearers) sethearing()

	var/turf/T = get_turf(source)
	. = new/list()

	if(!T)
		return

	for(var/mob/virtualhearer/VH in hearers(R, T))
		. += VH.attached

/**
 * Returns a list of mobs who can hear any of the radios given in @radios.
 */
/proc/get_mobs_in_radio_ranges(list/obj/item/device/radio/radios)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/get_mobs_in_radio_ranges() called tick#: [world.time]")
	if(world.time>resethearers) sethearing()

	. = new/list()

	for(var/obj/item/device/radio/radio in radios)
		if(radio)
			var/turf/turf = get_turf(radio)

			if(turf)
				for(var/mob/virtualhearer/VH in hearers(radio.canhear_range, turf))
					. |= VH.attached

/* Unused
/proc/get_movables_in_radio_ranges(var/list/obj/item/device/radio/radios)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/get_movables_in_radio_ranges() called tick#: [world.time]")
	. = new/list()
	// Returns a list of mobs who can hear any of the radios given in @radios
	for(var/i = 1; i <= radios.len; i++)
		var/obj/item/device/radio/R = radios[i]
		if(R)
			. |= get_hearers_in_view(R)
	. |= get_mobs_in_radio_ranges(radios)

//But I don't want to check EVERYTHING to find a hearer you say? I agree
//This is the new version of recursive_mob_check, used for say().
//The other proc was left intact because morgue trays use it.
/proc/recursive_hear_check(atom/O)
	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/recursive_hear_check() called tick#: [world.time]")
	var/list/processing_list = list(O)
	var/list/processed_list = list()
	var/found_atoms = list()

	while (processing_list.len)
		var/atom/A = processing_list[1]

		if (A.flags & HEAR)
			found_atoms |= A

		for (var/atom/B in A)
			if (!processed_list[B])
				processing_list |= B

		processing_list.Cut(1, 2)
		processed_list[A] = A

	return found_atoms

Even further legacy saycode
// Will recursively loop through an atom's contents and check for mobs, then it will loop through every atom in that atom's contents.
// It will keep doing this until it checks every content possible. This will fix any problems with mobs, that are inside objects,
// being unable to hear people due to being in a box within a bag.

/proc/recursive_mob_check(var/atom/O,var/client_check=1,var/sight_check=1,var/include_radio=1)

	//writepanic("[__FILE__].[__LINE__] (no type)([usr ? usr.ckey : ""])  \\/proc/recursive_mob_check() called tick#: [world.time]")

	var/list/processing_list = list(O)
	var/list/processed_list = list()
	var/list/found_mobs = list()

	while(processing_list.len)

		var/atom/A = processing_list[1]
		var/passed = 0

		if(ismob(A))
			var/mob/A_tmp = A
			passed=1

			if(client_check && !A_tmp.client)
				passed=0

			if(sight_check && !isInSight(A_tmp, O))
				passed=0

		else if(include_radio && istype(A, /obj/item/device/radio))
			passed=1

			if(sight_check && !isInSight(A, O))
				passed=0

		if(passed)
			found_mobs |= A

		for(var/atom/B in A)
			if(!processed_list[B])
				processing_list |= B

		processing_list.Cut(1, 2)
		processed_list[A] = A

	return found_mobs*/
