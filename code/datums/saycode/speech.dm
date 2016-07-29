#define SPEECH_MODE_SAY     1
#define SPEECH_MODE_WHISPER 2
#define SPEECH_MODE_FINAL   3

/datum/speech
	var/name         = "" // Displayed name
	var/as_name      = "" // (as [as_name])
	var/message      = "" // Message to send. DO NOT INCLUDE HTML OR I WILL STAB YOU IN THE NECK.
	var/frequency    = null // Displayed radio frequency
	var/job          = ""
	var/lquote       = "\"" // Left quote character
	var/rquote       = "\"" // Right quote character
	var/datum/language/language
	var/atom/movable/radio = null
	var/atom/movable/speaker = null // Shouldn't really be used.

	// Additional CSS classes to slap onto the message <span>.
	var/list/message_classes=list("message")
	// CSS classes for the wrapper span
	var/list/wrapper_classes=list("game","say")

	var/mode = SPEECH_MODE_SAY

/**
 * Update Speaker
 *
 * Set the speaker mob/obj as well as radio and update the appropriate variables.
 */
/datum/speech/proc/update_speaker(var/atom/movable/new_speaker, var/atom/movable/radio=null)
	speaker = new_speaker
	job = speaker.get_job(src)
	src.radio = radio
	name = new_speaker.GetVoice()
	as_name = new_speaker.get_alt_name()

/datum/speech/Del()
	say_testing(speaker,"\[SPEECH\] Destroy() called!")
	..()

/datum/speech/proc/clone()
	var/datum/speech/clone = getFromPool(/datum/speech)

	clone.name=name
	clone.as_name=as_name
	clone.message=message
	clone.frequency=frequency
	clone.job=job
	clone.language=language
	clone.radio=radio
	clone.speaker=speaker
	clone.mode=mode

	clone.message_classes=message_classes.Copy()
	clone.wrapper_classes=wrapper_classes.Copy()
	return clone

/datum/speech/proc/scramble()
	var/datum/speech/clone = clone()
	if(language)
		clone.message = language.scramble(message)
	else
		clone.message = stars(message, 10)
	return clone

/datum/speech/proc/render_wrapper_classes(var/sep=" ")
	return jointext(wrapper_classes, sep)

/datum/speech/proc/render_message_classes(var/sep=" ")
	return jointext(message_classes, sep)

/datum/speech/proc/render_message()
#ifdef SAY_DEBUG
	to_chat(speaker, "[type]/render_message(): message_classes = {[jointext(message_classes, ", ")]}")
#endif
	var/rendered=message
	// Sanity
	if(!lquote)
		lquote="\""
	if(!rquote)
		rquote="\""
	rendered="<span class='[jointext(message_classes, " ")]'>[lquote][html_encode(rendered)][rquote]</span>"
	if(language)
		rendered=language.render_speech(src, rendered)
	else
		if(speaker)
			rendered=speaker.say_quote(rendered)
		else
			warning("Speaker not set! (message=\"[message]\")")
#ifdef SAY_DEBUG
	to_chat(speaker, "[type]/render_message(): message = \"[html_encode(rendered)]\"")
#endif
	return rendered

/datum/speech/proc/render_as_name()
	if(as_name && as_name != name)
		return " (as [as_name])"
	return ""

/datum/speech/resetVariables()
	..("wrapper_classes","message_classes")

	message_classes=list()
	wrapper_classes=list()

	language = null
	speaker = null
	radio = null

/datum/speech/proc/get_real_name()
	if(ismob(speaker))
		var/mob/M = speaker
		return M.real_name
	return name

/datum/speech/proc/get_key()
	if(ismob(speaker))
		var/mob/M = speaker
		if(M.client)
			return M.key
	return null

/datum/speech/proc/to_signal(var/datum/signal/signal)
	if(speaker)
		signal.data["mob"]      = speaker
		signal.data["mobtype"]  = speaker.type

	signal.data["message_classes"] = message_classes.Copy()
	signal.data["wrapper_classes"] = wrapper_classes.Copy()

	signal.data["realname"] = get_real_name()
	signal.data["name"]     = name
	signal.data["job"]      = job
	signal.data["key"]      = get_key()
	signal.data["message"]  = message
	signal.data["radio"]    = radio
	signal.data["mode"]     = mode

	signal.data["language"] = language

	signal.data["r_quote"]  = rquote
	signal.data["l_quote"]  = lquote

	signal.frequency = frequency // Quick frequency set
	return signal

/datum/speech/proc/from_signal(var/datum/signal/signal)
	frequency = signal.frequency

	if("mob" in signal.data)
		speaker = signal.data["mob"]

	message  = signal.data["message"]
	name     = signal.data["name"]
	job      = signal.data["job"]
	radio    = signal.data["radio"]
	language = signal.data["language"]
	mode     = signal.data["mode"]

	lquote   = signal.data["left_quote"]
	rquote   = signal.data["right_quote"]

	var/list/data = signal.data["message_classes"]
	if(data)
		message_classes=data.Copy()

	data = signal.data["wrapper_classes"]
	if(data)
		wrapper_classes=data.Copy()

/datum/speech/proc/set_language(var/lang_id)
	language = all_languages[lang_id]
