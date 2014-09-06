/mob/living/carbon/alien/say(var/message)
	return ..(message, "A")

/mob/living/proc/alien_talk(var/message)
	log_say("[key_name(src)] : [message]")
	message = trim(message)

	if (!message)
		return

	var/message_a = say_quote(message)
	var/rendered = "<i><span class='game say'>Hivemind, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i>"
	for(var/mob/S in player_list)
		if((!S.stat && (S.hivecheck())) || (S.stat == DEAD && !istype(S, /mob/new_player)))
			S << rendered

/mob/living/carbon/alien/handle_inherent_channels(message, message_mode)
	if(!..())
		if(message_mode == MODE_ALIEN)
			if(hivecheck())
				alien_talk(message)
			return 1
		return 0

/mob/living/carbon/alien/hivecheck()
	return 1
