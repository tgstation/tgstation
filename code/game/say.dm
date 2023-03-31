/*
Miauw's big Say() rewrite.
This file has the basic atom/movable level speech procs.
And the base of the send_speech() proc, which is the core of saycode.
*/
GLOBAL_LIST_INIT(freqtospan, list(
	"[FREQ_SCIENCE]" = "sciradio",
	"[FREQ_MEDICAL]" = "medradio",
	"[FREQ_ENGINEERING]" = "engradio",
	"[FREQ_SUPPLY]" = "suppradio",
	"[FREQ_SERVICE]" = "servradio",
	"[FREQ_SECURITY]" = "secradio",
	"[FREQ_COMMAND]" = "comradio",
	"[FREQ_AI_PRIVATE]" = "aiprivradio",
	"[FREQ_SYNDICATE]" = "syndradio",
	"[FREQ_UPLINK]" = "syndradio",  // this probably shouldnt appear ingame
	"[FREQ_CENTCOM]" = "centcomradio",
	"[FREQ_CTF_RED]" = "redteamradio",
	"[FREQ_CTF_BLUE]" = "blueteamradio",
	"[FREQ_CTF_GREEN]" = "greenteamradio",
	"[FREQ_CTF_YELLOW]" = "yellowteamradio"
	))

/atom/movable/proc/say(message, bubble_type, list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null, filterproof = FALSE, message_range = 7, datum/saymode/saymode = null)
	if(!try_speak(message, ignore_spam, forced, filterproof))
		return
	if(sanitize)
		message = trim(copytext_char(sanitize(message), 1, MAX_MESSAGE_LEN))
	if(!message || message == "")
		return
	spans |= speech_span
	if(!language)
		language = get_selected_language()
	send_speech(message, message_range, src, bubble_type, spans, message_language = language, forced = forced)

/atom/movable/proc/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), message_range=0)
	SEND_SIGNAL(src, COMSIG_MOVABLE_HEAR, args)


/**
 * Checks if our movable can speak the provided message, passing it through filters
 * and spam detection. Does not call can_speak. CAN include feedback messages about
 * why someone can or can't speak
 *
 * Used in [proc/say] and other methods of speech (radios) after a movable has inputted some message.
 * If you just want to check if the movable is able to speak in character, use [proc/can_speak] instead.
 *
 * Parameters:
 * - message (string): the original message
 * - ignore_spam (bool): should we ignore spam?
 * - forced (null|string): what was it forced by? null if voluntary
 * - filterproof (bool): are we filterproof?
 *
 * Returns:
 * 	TRUE of FASE depending on if our movable can speak
 */
/atom/movable/proc/try_speak(message, ignore_spam = FALSE, forced = null, filterproof = FALSE)
	return TRUE

/**
 * Checks if our movable can currently speak, vocally, in general.
 * Should NOT include feedback messages about why someone can or can't speak

 * Used in various places to check if a movable is simply able to speak in general,
 * regardless of OOC status (being muted) and regardless of what they're actually saying.
 *
 * Checked AFTER handling of xeno channels.
 * (I'm not sure what this comment means, but it was here in the past, so I'll maintain it here.)
 *
 * allow_mimes - Determines if this check should skip over mimes. (Only matters for living mobs and up.)
 * If FALSE, this check will always fail if the movable has a mind and is miming.
 * if TRUE, we will check if the movable can speak REGARDLESS of if they have an active mime vow.
 */
/atom/movable/proc/can_speak(allow_mimes = FALSE)
	return TRUE

/atom/movable/proc/send_speech(message, range = 7, obj/source = src, bubble_type, list/spans, datum/language/message_language, list/message_mods = list(), forced = FALSE)
	for(var/atom/movable/hearing_movable as anything in get_hearers_in_view(range, source))
		if(!hearing_movable)//theoretically this should use as anything because it shouldnt be able to get nulls but there are reports that it does.
			stack_trace("somehow theres a null returned from get_hearers_in_view() in send_speech!")
			continue
		hearing_movable.Hear(null, src, message_language, message, null, spans, message_mods, range)

/atom/movable/proc/compose_message(atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list(), face_name = FALSE)
	//This proc uses text() because it is faster than appending strings. Thanks BYOND.
	//Basic span
	var/spanpart1 = "<span class='[radio_freq ? get_radio_span(radio_freq) : "game say"]'>"
	//Start name span.
	var/spanpart2 = "<span class='name'>"
	//Radio freq/name display
	var/freqpart = radio_freq ? "\[[get_radio_name(radio_freq)]\] " : ""
	//Speaker name
	var/namepart = "[speaker.GetVoice()][speaker.get_alt_name()]"
	if(face_name && ishuman(speaker))
		var/mob/living/carbon/human/H = speaker
		namepart = "[H.get_face_name()]" //So "fake" speaking like in hallucinations does not give the speaker away if disguised
	//End name span.
	var/endspanpart = "</span>"

	//Message
	var/messagepart
	var/languageicon = ""
	if(message_mods[MODE_CUSTOM_SAY_ERASE_INPUT])
		messagepart = message_mods[MODE_CUSTOM_SAY_EMOTE]
	else
		messagepart = speaker.say_quote(raw_message, spans, message_mods)

		var/datum/language/dialect = GLOB.language_datum_instances[message_language]
		if(istype(dialect) && dialect.display_icon(src))
			languageicon = "[dialect.get_icon()] "

	messagepart = " <span class='message'>[say_emphasis(messagepart)]</span></span>"

	return "[spanpart1][spanpart2][freqpart][languageicon][compose_track_href(speaker, namepart)][namepart][compose_job(speaker, message_language, raw_message, radio_freq)][endspanpart][messagepart]"

/atom/movable/proc/compose_track_href(atom/movable/speaker, message_langs, raw_message, radio_freq)
	return ""

/atom/movable/proc/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	return ""

/atom/movable/proc/say_mod(input, list/message_mods = list())
	var/ending = copytext_char(input, -1)
	if(copytext_char(input, -2) == "!!")
		return verb_yell
	else if(message_mods[MODE_SING])
		. = verb_sing
	else if(message_mods[WHISPER_MODE])
		. = verb_whisper
	else if(ending == "?")
		return verb_ask
	else if(ending == "!")
		return verb_exclaim
	else
		return verb_say

/atom/movable/proc/say_quote(input, list/spans=list(speech_span), list/message_mods = list())
	if(!input)
		input = "..."

	var/say_mod = message_mods[MODE_CUSTOM_SAY_EMOTE]
	if (!say_mod)
		say_mod = say_mod(input, message_mods)

	SEND_SIGNAL(src, COMSIG_MOVABLE_SAY_QUOTE, args)

	if(copytext_char(input, -2) == "!!")
		spans |= SPAN_YELL

	var/spanned = attach_spans(input, spans)
	return "[say_mod], \"[spanned]\""

/// Transforms the speech emphasis mods from [/atom/movable/proc/say_emphasis] into the appropriate HTML tags. Includes escaping.
#define ENCODE_HTML_EMPHASIS(input, char, html, varname) \
	var/static/regex/##varname = regex("(?<!\\\\)[char](.+?)(?<!\\\\)[char]", "g");\
	input = varname.Replace_char(input, "<[html]>$1</[html]>")

/// Scans the input sentence for speech emphasis modifiers, notably |italics|, +bold+, and _underline_ -mothblocks
/atom/movable/proc/say_emphasis(input)
	ENCODE_HTML_EMPHASIS(input, "\\|", "i", italics)
	ENCODE_HTML_EMPHASIS(input, "\\+", "b", bold)
	ENCODE_HTML_EMPHASIS(input, "_", "u", underline)
	var/static/regex/remove_escape_backlashes = regex("\\\\(_|\\+|\\|)", "g") // Removes backslashes used to escape text modification.
	input = remove_escape_backlashes.Replace_char(input, "$1")
	return input

#undef ENCODE_HTML_EMPHASIS

///	Modifies the message by comparing the languages of the speaker with the languages of the hearer. Called on the hearer.
/atom/movable/proc/translate_language(atom/movable/speaker, datum/language/language, raw_message, list/spans, list/message_mods = list())
	if(!language)
		return "makes a strange sound."

	if(!has_language(language))
		var/datum/language/dialect = GLOB.language_datum_instances[language]
		raw_message = dialect.scramble(raw_message)

	return raw_message

/proc/get_radio_span(freq)
	var/returntext = GLOB.freqtospan["[freq]"]
	if(returntext)
		return returntext
	return "radio"

/proc/get_radio_name(freq)
	var/returntext = GLOB.reverseradiochannels["[freq]"]
	if(returntext)
		return returntext
	return "[copytext_char("[freq]", 1, 4)].[copytext_char("[freq]", 4, 5)]"

/proc/attach_spans(input, list/spans)
	return "[message_spans_start(spans)][input]</span>"

/proc/message_spans_start(list/spans)
	var/output = "<span class='"
	for(var/S in spans)
		output = "[output][S] "
	output = "[output]'>"
	return output

/proc/say_test(text)
	var/ending = copytext_char(text, -1)
	if (ending == "?")
		return "1"
	else if (ending == "!")
		return "2"
	return "0"

/atom/movable/proc/GetVoice()
	return "[src]" //Returns the atom's name, prepended with 'The' if it's not a proper noun

/atom/movable/proc/get_alt_name()

//HACKY VIRTUALSPEAKER STUFF BEYOND THIS POINT
//these exist mostly to deal with the AIs hrefs and job stuff.

/atom/movable/proc/GetJob() //Get a job, you lazy butte

/atom/movable/proc/GetSource()

/atom/movable/proc/GetRadio()

//VIRTUALSPEAKERS
/atom/movable/virtualspeaker
	var/job
	var/atom/movable/source
	var/obj/item/radio/radio

INITIALIZE_IMMEDIATE(/atom/movable/virtualspeaker)
/atom/movable/virtualspeaker/Initialize(mapload, atom/movable/M, _radio)
	. = ..()
	radio = _radio
	source = M
	if(istype(M))
		name = radio.anonymize ? "Unknown" : M.GetVoice()
		verb_say = M.verb_say
		verb_ask = M.verb_ask
		verb_exclaim = M.verb_exclaim
		verb_yell = M.verb_yell

	// The mob's job identity
	if(ishuman(M))
		// Humans use their job as seen on the crew manifest. This is so the AI
		// can know their job even if they don't carry an ID.
		var/datum/record/crew/found_record = find_record(name)
		if(found_record)
			job = found_record.rank
		else
			job = "Unknown"
	else if(iscarbon(M))  // Carbon nonhuman
		job = "No ID"
	else if(isAI(M))  // AI
		job = "AI"
	else if(iscyborg(M))  // Cyborg
		var/mob/living/silicon/robot/B = M
		job = "[B.designation] Cyborg"
	else if(ispAI(M))  // Personal AI (pAI)
		job = JOB_PERSONAL_AI
	else if(isobj(M))  // Cold, emotionless machines
		job = "Machine"
	else  // Unidentifiable mob
		job = "Unknown"

/atom/movable/virtualspeaker/GetJob()
	return job

/atom/movable/virtualspeaker/GetSource()
	return source

/atom/movable/virtualspeaker/GetRadio()
	return radio
