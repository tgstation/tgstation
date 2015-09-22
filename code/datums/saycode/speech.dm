// Flags
#define SPEECH_ITALICS 1

/datum/speech
	var/name         = "" // Displayed name
	var/as_name      = "" // (as [as_name])
	var/message      = "" // Message to send. DO NOT INCLUDE HTML OR I WILL STAB YOU IN THE NECK.
	var/frequency    = "" // Displayed radio frequency
	var/job          = ""
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

/datum/speech/proc/render_wrapper_classes()
	return list2text(" ",wrapper_classes)

/datum/speech/proc/render_message_classes()
	return list2text(" ",message_classes)

/datum/speech/proc/render_as_name()
	if(as_name)
		return " (as [as_name])"
	return ""

/datum/speech/proc/toSignal(var/datum/signal/signal)
	signal.data["message"] = message
	signal.data["name"] = name
	signal.data["job"] = job
	return signal

/datum/speech/proc/fromSignal(var/datum/signal/signal)
	message = signal.data["message"]
	name = signal.data["name"]
	job = signal.data["job"]