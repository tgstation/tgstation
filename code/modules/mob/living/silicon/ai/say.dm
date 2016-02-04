/mob/living/silicon/ai/say(message)
	if(parent && istype(parent) && parent.stat != 2) //If there is a defined "parent" AI, it is actually an AI, and it is alive, anything the AI tries to say is said by the parent instead.
		parent.say(message)
		return
	..(message)

/mob/living/silicon/ai/compose_track_href(atom/movable/speaker, namepart)
	var/mob/M = speaker.GetSource()
	if(M)
		return "<a href='?src=\ref[src];track=[html_encode(namepart)]'>"
	return ""

/mob/living/silicon/ai/compose_job(atom/movable/speaker, message_langs, raw_message, radio_freq)
	//Also includes the </a> for AI hrefs, for convenience.
	return "[radio_freq ? " (" + speaker.GetJob() + ")" : ""]" + "[speaker.GetSource() ? "</a>" : ""]"

/mob/living/silicon/ai/IsVocal()
	return !config.silent_ai

/mob/living/silicon/ai/radio(message, message_mode, list/spans)
	if(!radio_enabled || aiRestorePowerRoutine || stat) //AI cannot speak if radio is disabled (via intellicard) or depowered.
		src << "<span class='danger'>Your radio transmitter is offline!</span>"
		return 0
	..()

/mob/living/silicon/ai/get_message_mode(message)
	if(copytext(message, 1, 3) in list(":h", ":H", ".h", ".H", "#h", "#H"))
		return MODE_HOLOPAD
	else
		return ..()

/mob/living/silicon/ai/handle_inherent_channels(message, message_mode)
	. = ..()
	if(.)
		return .

	if(message_mode == MODE_HOLOPAD)
		holopad_talk(message)
		return 1

//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(message)
	log_say("[key_name(src)] : [message]")

	message = trim(message)

	if (!message)
		return

	var/obj/machinery/hologram/holopad/T = current
	if(istype(T) && T.masters[src])//If there is a hologram and its master is the user.
		send_speech(message, 7, T, "robot", get_spans())
		src << "<i><span class='game say'>Holopad transmitted, <span class='name'>[real_name]</span> <span class='message robot'>\"[message]\"</span></span></i>"//The AI can "hear" its own message.
	else
		src << "No holopad connected."
	return
