// Flags
#define SPEECH_ITALICS 1

/datum/speech
	var/name         = "" // Displayed name
	var/as_name      = "" // (as [as_name])
	var/message      = "" // Message to send. DO NOT INCLUDE HTML OR I WILL STAB YOU IN THE NECK.
	var/frequency    = "" // Displayed radio frequency
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

/datum/speech/proc/update_speaker(var/atom/movable/new_speaker, var/atom/movable/radio=null)
	speaker = new_speaker
	job = speaker.get_job(src)
	src.radio = radio
	name = new_speaker.GetVoice()
	as_name = new_speaker.get_alt_name()

/datum/speech/proc/clone()
	var/datum/speech/clone = getFromDPool(/datum/speech)

	clone.name=name
	clone.as_name=as_name
	clone.message=message
	clone.frequency=frequency
	clone.job=job
	clone.language=language
	clone.radio=radio
	clone.speaker=speaker

	clone.message_classes=message_classes
	clone.wrapper_classes=wrapper_classes
	return clone

/datum/speech/proc/scramble()
	var/datum/speech/clone = clone()
	clone.message = language.scramble(message)
	return clone

/datum/speech/proc/render_wrapper_classes()
	return list2text(wrapper_classes, " ")

/datum/speech/proc/render_message()
#ifdef SAY_DEBUG
	speaker << "[type]/render_message(): message_classes = {[list2text(message_classes, ", ")]}"
#endif
	var/rendered=message
	rendered="<span class='[list2text(message_classes, " ")]'>[lquote][rendered][rquote]</span>"
	if(language)
		rendered=language.render_speech(src, rendered)
#ifdef SAY_DEBUG
	speaker << "[type]/render_message(): message = \"[html_encode(rendered)]\""
#endif
	return rendered

/datum/speech/proc/render_as_name()
	if(as_name)
		return " (as [as_name])"
	return ""

/datum/speech/proc/toSignal(var/datum/signal/signal)
	signal.data["mob"] = speaker
	signal.data["message"] = message
	signal.data["name"] = name
	signal.data["job"] = job
	signal.data["left_quote"] = lquote
	signal.data["right_quote"] = rquote
	return signal

/datum/speech/proc/fromSignal(var/datum/signal/signal)
	if("mob" in signal.data)
		speaker = signal.data["mob"]
	message = signal.data["message"]
	name = signal.data["name"]
	job = signal.data["job"]
	lquote = signal.data["left_quote"]
	rquote = signal.data["right_quote"]

/datum/speech/proc/set_language(var/lang_id)
	language = all_languages[lang_id]