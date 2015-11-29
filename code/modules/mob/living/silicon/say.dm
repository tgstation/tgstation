/mob/living/silicon/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, [text]";
	else if (ending == "!")
		return "declares, [text]";

	return "states, [text]";

/mob/living/silicon/say(var/message)
	return ..(message, "R")

/mob/living/silicon/robot/IsVocal()
		return !config.silent_borg

/mob/living/proc/robot_talk(var/message)


	var/turf/T = get_turf(src)
	log_say("[key_name(src)] (@[T.x],[T.y],[T.z] Binary: [message]")

	var/message_a = say_quote("\"[html_encode(message)]\"")
	var/rendered = text("<i><span class='game say'>Robotic Talk, <span class='name'>[]</span> <span class='message'>[]</span></span></i>",name,message_a)

	for (var/mob/S in player_list)
		if(istype(S , /mob/living/silicon/ai))
			var/renderedAI = "<i><span class='game say'>Robotic Talk, <a href='byond://?src=\ref[S];track2=\ref[S];track=\ref[src]'><span class='name'>[name]</span></a> <span class='message'>[message_a]</span></span></i>"
			to_chat(S, renderedAI)
		else if(S.binarycheck() || ((S in dead_mob_list) && !istype(S, /mob/new_player)))
			handle_render(S,rendered,src)

/mob/living/silicon/binarycheck()
	return 1

/mob/living/silicon/lingcheck()
	return 0 //Borged or AI'd lings can't speak on the ling channel.

/mob/living/silicon/radio(var/datum/speech/speech, var/message_mode)
	. = ..()
	if(. != 0)
		return .
	if(message_mode == "robot")
		if(radio)
			radio.talk_into(speech)
		return REDUCE_RANGE

	else if(message_mode in radiochannels)
		if(radio)
			radio.talk_into(speech, message_mode)
			return ITALICS | REDUCE_RANGE
	return 0

/mob/living/silicon/get_message_mode(message)
	. = ..()
	if(..() == MODE_HEADSET)
		return MODE_ROBOT
	else
		return .

/mob/living/silicon/handle_inherent_channels(var/datum/speech/speech, var/message_mode)
	. = ..()
	if(.)
		return .

	if(message_mode == MODE_BINARY)
		if(binarycheck())
			robot_talk(speech.message)
			return 1
	return 0

/mob/living/silicon/treat_speech(var/datum/speech/speech, genesay = 0)
	..(speech)
	speech.message_classes.Add("siliconsay")

/mob/living/silicon/say_understands(var/atom/movable/other,var/datum/language/speaking = null)
	//These only pertain to common. Languages are handled by mob/say_understands()
	if (!speaking)
		if(other) other = other.GetSource()
		if (istype(other, /mob/living/carbon))
			return 1
		if (istype(other, /mob/living/silicon))
			return 1
		if (istype(other, /mob/living/carbon/brain))
			return 1
		if (isanimal(other))
			return 1
	return ..()