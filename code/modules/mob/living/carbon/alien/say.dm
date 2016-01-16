/mob/living/carbon/alien/say(var/message)
	. = ..(message, "A")
	if(.)
		playsound(loc, "hiss", 25, 1, 1)

/mob/living/proc/alien_talk(var/message)


	var/turf/T = get_turf(src)
	log_say("[key_name(src)] (@[T.x],[T.y],[T.z]) Alien Hivemind: [message]")
	message = trim(message)

	if (!message)
		return

	var/message_a = say_quote("\"[html_encode(message)]\"")
	var/rendered = text("<i><span class='game say'>Hivemind, <span class='name'>[]</span> <span class='message'>[]</span></span></i>",name,message_a)
	for (var/mob/S in player_list)
		if((!S.stat && S.hivecheck()) || ((S in dead_mob_list) && !istype(S, /mob/new_player)))
			handle_render(S,rendered,src)

/mob/living/carbon/alien/handle_inherent_channels(var/datum/speech/speech, var/message_mode)
	if(!..())
		if(message_mode == MODE_ALIEN)
			if(hivecheck())
				alien_talk(speech.message)
			return 1
		return 0

/mob/living/carbon/alien/hivecheck()
	return 1