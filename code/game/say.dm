<<<<<<< HEAD
=======
var/global/nextDecTalkDelay = 5 //seconds
var/global/lastDecTalkUse = 0

/proc/dectalk(msg)
	if(!msg) return 0
	if (world.timeofday > (lastDecTalkUse + (nextDecTalkDelay * 10)))
		lastDecTalkUse = world.timeofday
		msg = copytext(msg, 1, 2000)
		var/res[] = world.Export("[config.tts_server]?tts=[url_encode(msg)]")
		//var/res[] = world.Export("http://localhost:1203/?tts=[url_encode(msg)]") //change server
		if(!res || !res["CONTENT"])
			return 0

		var/audio = file2text(res["CONTENT"])
		return list("audio" = audio, "message" = msg)
	else
		return list("cooldown" = 1)

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/*
 	Miauw's big Say() rewrite.
	This file has the basic atom/movable level speech procs.
	And the base of the send_speech() proc, which is the core of saycode.
*/
var/list/freqtospan = list(
	"1351" = "sciradio",
	"1355" = "medradio",
	"1357" = "engradio",
<<<<<<< HEAD
	"1347" = "suppradio",
	"1349" = "servradio",
=======
	"1347" = "supradio",
	"1349" = "serradio",
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	"1359" = "secradio",
	"1353" = "comradio",
	"1447" = "aiprivradio",
	"1213" = "syndradio",
<<<<<<< HEAD
	"1337" = "centcomradio"
	)

/atom/movable/proc/say(message)
=======
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

/atom/movable/proc/say(message, var/datum/language/speaking, var/atom/movable/radio=src) //so we can force nonmobs to speak a certain language
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	if(!can_speak())
		return
	if(message == "" || !message)
		return
<<<<<<< HEAD
	var/list/spans = get_spans()
	send_speech(message, 7, src, , spans)

/atom/movable/proc/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
=======
	var/datum/speech/speech = create_speech(message, null, radio)
	speech.language=speaking
	send_speech(speech, world.view)
	returnToPool(speech)

/atom/movable/proc/Hear(var/datum/speech/speech, var/rendered_speech="")
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	return

/atom/movable/proc/can_speak()
	return 1

<<<<<<< HEAD
/atom/movable/proc/send_speech(message, range = 7, obj/source = src, bubble_type, list/spans)
	var/rendered = compose_message(src, languages_spoken, message, , spans)
	for(var/atom/movable/AM in get_hearers_in_view(range, src))
		AM.Hear(rendered, src, languages_spoken, message, , spans)

//To get robot span classes, stuff like that.
/atom/movable/proc/get_spans()
	return list()

/atom/movable/proc/compose_message(atom/movable/speaker, message_langs, raw_message, radio_freq, list/spans)
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
	var/messagepart = " <span class='message'>[lang_treat(speaker, message_langs, raw_message, spans)]</span></span>"

	return "[spanpart1][spanpart2][freqpart][compose_track_href(speaker, namepart)][namepart][compose_job(speaker, message_langs, raw_message, radio_freq)][endspanpart][messagepart]"

/atom/movable/proc/compose_track_href(atom/movable/speaker, message_langs, raw_message, radio_freq)
	return ""

/atom/movable/proc/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	return ""

/atom/movable/proc/say_quote(input, list/spans=list())
	if(!input)
		return "says, \"...\""	//not the best solution, but it will stop a large number of runtimes. The cause is somewhere in the Tcomms code
	var/ending = copytext(input, length(input))
	if(copytext(input, length(input) - 1) == "!!")
		spans |= SPAN_YELL
		return "[verb_yell], \"[attach_spans(input, spans)]\""
	input = attach_spans(input, spans)
	if(ending == "?")
		return "[verb_ask], \"[input]\""
	if(ending == "!")
		return "[verb_exclaim], \"[input]\""

	return "[verb_say], \"[input]\""

/atom/movable/proc/lang_treat(atom/movable/speaker, message_langs, raw_message, list/spans)
	if(languages_understood & message_langs)
		var/atom/movable/AM = speaker.GetSource()
		if(AM) //Basically means "if the speaker is virtual"
			if(AM.verb_say != speaker.verb_say || AM.verb_ask != speaker.verb_ask || AM.verb_exclaim != speaker.verb_exclaim || AM.verb_yell != speaker.verb_yell) //If the saymod was changed
				return speaker.say_quote(raw_message, spans)
			return AM.say_quote(raw_message, spans)
		else
			return speaker.say_quote(raw_message, spans)
	else if((message_langs & HUMAN) || (message_langs & RATVAR)) //it's human or ratvar language
		var/atom/movable/AM = speaker.GetSource()
		if(message_langs & HUMAN)
			raw_message = stars(raw_message)
		if(message_langs & RATVAR)
			raw_message = text2ratvar(raw_message)
		if(AM)
			return AM.say_quote(raw_message, spans)
		else
			return speaker.say_quote(raw_message, spans)
=======
/atom/movable/proc/send_speech(var/datum/speech/speech, var/range=7)
	say_testing(src, "/atom/movable/proc/send_speech() start, msg = [speech.message]; message_range = [range]; language = [speech.language ? speech.language.name : "None"];")
	if(isnull(range))
		range = 7
	var/rendered = render_speech(speech)
	for(var/atom/movable/AM in get_hearers_in_view(range, src))
		AM.Hear(speech, rendered)

/atom/movable/proc/create_speech(var/message, var/frequency=0, var/atom/movable/transmitter=null)
	if(!transmitter)
		transmitter=GetDefaultRadio()
	var/datum/speech/speech = getFromPool(/datum/speech)
	speech.message = message
	speech.frequency = frequency
	speech.job = get_job(speech)
	speech.radio = transmitter
	speech.speaker = src

	speech.name = GetVoice()
	speech.as_name = get_alt_name()
	return speech

/atom/movable/proc/render_speech_name(var/datum/speech/speech)
	// old getVoice-based shit
	//return "[speech.speaker.GetVoice()][speech.speaker.get_alt_name()]"
	return "[speech.name][speech.render_as_name()]"

/atom/movable/proc/render_speech(var/datum/speech/speech)
	say_testing(src, "render_speech() - Freq: [speech.frequency], radio=\ref[speech.radio]")
	var/freqpart = ""
	var/radioicon = ""
	if(speech.frequency)
		if(speech.radio)
			radioicon = "[bicon(speech.radio)]"
		freqpart = " [radioicon]\[[get_radio_name(speech.frequency)]\]"
		speech.wrapper_classes.Add(get_radio_span(speech.frequency))
	var/pooled=0
	var/datum/speech/filtered_speech
	if(speech.language)
		filtered_speech = speech.language.filter_speech(speech.clone())
	else
		filtered_speech = speech

	var/atom/movable/source = speech.speaker.GetSource()
	say_testing(speech.speaker, "Checking if [src]([type]) understands [source]([source.type])")
	if(!say_understands(source, speech.language))
		say_testing(speech.speaker," We don't understand this fuck, adding stars().")
		filtered_speech=filtered_speech.scramble()
		pooled=1
	else
		say_testing(speech.speaker," We <i>do</i> understand this gentle\[wo\]man.")

#ifdef SAY_DEBUG
	var/enc_wrapclass=jointext(filtered_speech.wrapper_classes, ", ")
	say_testing(src, "render_speech() - wrapper_classes = \[[enc_wrapclass]\]")
#endif
	// Below, but formatted nicely.
	/*
	return {"
		<span class='[filtered_speech.render_wrapper_classes()]'>
			<span class='name'>
				[render_speaker_track_start(filtered_speech)][render_speech_name(filtered_speech)][render_speaker_track_end(filtered_speech)]
				[freqpart]
				[render_job(filtered_speech)]
			</span>
			[filtered_speech.render_message()]
		</span>"}
	*/
	. = "<span class='[filtered_speech.render_wrapper_classes()]'><span class='name'>[render_speaker_track_start(filtered_speech)][render_speech_name(filtered_speech)][render_speaker_track_end(filtered_speech)][freqpart][render_job(filtered_speech)]</span> [filtered_speech.render_message()]</span>"
	say_testing(src, html_encode(.))
	if(pooled)
		returnToPool(filtered_speech)


/atom/movable/proc/render_speaker_track_start(var/datum/speech/speech)
	return ""

/atom/movable/proc/render_speaker_track_end(var/datum/speech/speech)
	return ""

/atom/movable/proc/get_job(var/datum/speech/speech)
	return ""

/atom/movable/proc/render_job(var/datum/speech/speech)
	if(speech.job)
		return " ([speech.job])"
	return ""

/atom/movable/proc/say_quote(var/text)
	if(!text)
		return "says, \"...\""	//not the best solution, but it will stop a large number of runtimes. The cause is somewhere in the Tcomms code
	var/ending = copytext(text, length(text))
	if (ending == "?")
		return "asks, [text]"
	if (ending == "!")
		return "exclaims, [text]"

	return "says, [text]"


var/global/image/ghostimg = image("icon"='icons/mob/mob.dmi',"icon_state"="ghost")
/atom/movable/proc/render_lang(var/datum/speech/speech)
	var/raw_message=speech.message
	if(speech.language)
		//var/overRadio = (istype(speech.speaker, /obj/item/device/radio) || istype(speech.speaker.GetSource(), /obj/item/device/radio))
		var/atom/movable/AM = speech.speaker.GetSource()
		if(say_understands((istype(AM) ? AM : speech.speaker),speech.language))
			return render_speech(speech)
			//if(overRadio)
			//	return speech.language.format_message_radio(speech.speaker, raw_message)
			//return speech.language.format_message(speech.speaker, raw_message)
		else
			return render_speech(speech.scramble())
			//if(overRadio)
			//	return speech.language.format_message_radio(speech.speaker, speech.language.scramble(raw_message))
			//return speech.language.format_message(speech.speaker, speech.language.scramble(raw_message))

	else
		var/atom/movable/AM = speech.speaker.GetSource()
		var/atom/movable/source = istype(AM) ? AM : speech.speaker

		var/rendered = raw_message

		say_testing(speech.speaker, "Checking if [src]([type]) understands [source]([source.type])")
		if(!say_understands(source))
			say_testing(speech.speaker," We don't understand this fuck, adding stars().")
			rendered = stars(rendered)
		else
			say_testing(speech.speaker," We <i>do</i> understand this gentle\[wo\]man.")

		rendered="[speech.lquote][html_encode(rendered)][speech.rquote]"

		if(AM)
			return AM.say_quote(rendered)
		else
			return speech.speaker.say_quote(rendered)
	/*else if(message_langs & SPOOKY)
		return "[bicon(ghostimg)] <span class='sinister'>Too spooky...</span> [bicon(ghostimg)]"
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	else if(message_langs & MONKEY)
		return "chimpers."
	else if(message_langs & ALIEN)
		return "hisses."
	else if(message_langs & ROBOT)
		return "beeps rapidly."
<<<<<<< HEAD
	else if(message_langs & DRONE)
		return "chitters."
	else if(message_langs & SWARMER)
		return "hums."
	else
		return "makes a strange sound."
=======
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

>>>>>>> ccb55b121a3fd5338fc56a602424016009566488

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

<<<<<<< HEAD
/proc/attach_spans(input, list/spans)
	return "[message_spans_start(spans)][input]</span>"

/proc/message_spans_start(list/spans)
	var/output = "<span class='"
	for(var/S in spans)
		output = "[output][S] "
	output = "[output]'>"
	return output

/proc/say_test(text)
	var/ending = copytext(text, length(text))
	if (ending == "?")
		return "1"
	else if (ending == "!")
		return "2"
	return "0"

=======
/* NO YOU FOOL
/proc/attach_spans(input, list/spans)
	return "[message_spans(spans)][input]</span>"

/proc/message_spans(list/spans)
	var/output = "<SPAN CLASS='"

	for(var/span in spans)
		output = "[output][span] "

	output = "[output]'>"
	return output
*/


/**
 * The "voice" of the thing that's speaking.  Shows up as name.
 */
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
/atom/movable/proc/GetVoice()
	return name

/atom/movable/proc/IsVocal()
	return 1

<<<<<<< HEAD
/atom/movable/proc/get_alt_name()

//HACKY VIRTUALSPEAKER STUFF BEYOND THIS POINT
//these exist mostly to deal with the AIs hrefs and job stuff.

/atom/movable/proc/GetJob() //Get a job, you lazy butte

/atom/movable/proc/GetSource()

/atom/movable/proc/GetRadio()

//VIRTUALSPEAKERS
/atom/movable/virtualspeaker
	var/job
=======
/**
 * The "voice" of the thing that's speaking.  Shows up as name.
 */
/atom/movable/proc/get_alt_name()
	return

//these exist mostly to deal with the AIs hrefs and job stuff.
/atom/movable/proc/GetJob()
	return

/**
 * Probably used for getting tracking coordinates?
 * TODO: verify
 */
/atom/movable/proc/GetTrack()
	return

/**
 * What is speaking for us?  Usually src.
 */
/atom/movable/proc/GetSource()
	return src

// GetRadio() removed because which radio is used can be different per message. (such as when using :L :R :I macros)
//  - N3X
/atom/movable/proc/GetDefaultRadio()
	return null

/atom/movable/virtualspeaker
	var/job
	var/faketrack
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
	var/atom/movable/source
	var/obj/item/device/radio/radio

/atom/movable/virtualspeaker/GetJob()
	return job

<<<<<<< HEAD
/atom/movable/virtualspeaker/GetSource()
	return source

/atom/movable/virtualspeaker/GetRadio()
	return radio

/atom/movable/virtualspeaker/Destroy()
	..()
	return QDEL_HINT_PUTINPOOL
=======
/atom/movable/virtualspeaker/GetTrack()
	return faketrack

/atom/movable/virtualspeaker/GetSource()
	return source

/atom/movable/virtualspeaker/GetDefaultRadio()
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
		to_chat(mob, message)
	else
		to_chat(mob, message)

var/global/resethearers = 0

/proc/sethearing()
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
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
