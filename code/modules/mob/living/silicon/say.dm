
/mob/living/silicon/get_spans()
	return ..() | SPAN_ROBOT

/mob/living/proc/robot_talk(message)
	log_say("[key_name(src)] : [message]")
	var/desig = "Default Cyborg" //ezmode for taters
	if(issilicon(src))
		var/mob/living/silicon/S = src
		desig = trim_left(S.designation + " " + S.job)
	var/message_a = say_quote(message, get_spans())
	var/prerendered = "<i><span class='game say'>Robotic Talk, <span class='name'>"
	var/postrendered = "</span> <span class='message'>[message_a]</span></span></i>"
	var/rendered = "[prerendered][name][postrendered]"
	var/ghostrendered = "[prerendered][real_name][postrendered]"
	var/voice_print = get_voiceprint()
	for(var/mob/M in player_list)
		if(M.binarycheck())
			var/mob/living/silicon/ai/AI = isAI(M) ? M : null
			var/M_rendered = rendered
			if(voice_print || AI)
				var/datum/data/record/G
				var/record_id
				if(voice_print)
					G = find_record("voiceprint", voice_print, data_core.general)
				if(G)
					record_id = G.fields["id"]
				var/namepart = "[AI ? "<a href='?src=\ref[AI][AI.ai_track_href(src, record_id)]'>" : null]<span class='name'>[M.get_voiceprint_name(src, voice_print)][AI ? " ([desig])" : null]</span>[AI ? "</a>" : null]"
				M_rendered = "<i><span class='game say'>Robotic Talk, [M.compose_namepart(M, namepart)] <span class='message'>[message_a]</span></span></i>"
			to_chat (M, M_rendered)
		if(isobserver(M))
			var/following = src
			// If the AI talks on binary chat, we still want to follow
			// it's camera eye, like if it talked on the radio
			if(isAI(src))
				var/mob/living/silicon/ai/ai = src
				following = ai.eyeobj
			var/link = FOLLOW_LINK(M, following)
			to_chat(M, "[link] [ghostrendered]")

/mob/living/silicon/binarycheck()
	return 1

/mob/living/silicon/lingcheck()
	return 0 //Borged or AI'd lings can't speak on the ling channel.

/mob/living/silicon/radio(message, message_mode, list/spans)
	. = ..()
	if(. != 0)
		return .

	if(message_mode == "robot")
		if (radio)
			radio.talk_into(src, message, , spans)
		return REDUCE_RANGE

	else if(message_mode in radiochannels)
		if(radio)
			radio.talk_into(src, message, message_mode, spans)
			return ITALICS | REDUCE_RANGE

	return 0

/mob/living/silicon/get_message_mode(message)
	. = ..()
	if(..() == MODE_HEADSET)
		return MODE_ROBOT
	else
		return .

/mob/living/silicon/handle_inherent_channels(message, message_mode)
	. = ..()
	if(.)
		return .

	if(message_mode == MODE_BINARY)
		if(binarycheck())
			robot_talk(message)
		return 1
	return 0
