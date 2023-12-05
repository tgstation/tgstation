/datum/saymode/darkspawn
	key = MODE_KEY_DARKSPAWN
	mode = MODE_DARKSPAWN

/datum/saymode/darkspawn/handle_message(mob/living/user, message, datum/language/language)
	var/datum/mind = user.mind
	if(!mind)
		return TRUE
	if(is_darkspawn_or_veil(user))
		user.log_talk(message, LOG_SAY, tag="darkspawn")
		var/msg = span_velvet("<b>\[Mindlink\] [user.real_name]:</b> \"[message]\"")
		for(var/mob/M in GLOB.player_list)
			if(M in GLOB.dead_mob_list)
				var/link = FOLLOW_LINK(M, user)
				to_chat(M, "[link] [msg]")
			else if(is_darkspawn_or_veil(M))
				var/turf/receiver = get_turf(M)
				var/turf/sender = get_turf(user)
				if(receiver.z != sender.z)
					if(prob(25))
						to_chat(M, span_warning("Your mindlink trembles with words, but they are too far to make out..."))
					continue
				to_chat(M, msg)
	return FALSE
