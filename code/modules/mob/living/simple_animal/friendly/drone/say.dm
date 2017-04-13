/////////////
//DRONE SAY//
/////////////
//Drone speach

/mob/living/simple_animal/drone/handle_inherent_channels(message, message_mode)
	if(message_mode == MODE_BINARY)
		drone_chat(message)
		return 1
	else
		..()


/mob/living/simple_animal/drone/get_spans()
	return ..() | SPAN_ROBOT



//Base proc for anything to call
/proc/_alert_drones(msg, dead_can_hear = 0, mob/living/faction_checked_mob, exact_faction_match)
	for(var/W in GLOB.mob_list)
		var/mob/living/simple_animal/drone/M = W
		if(istype(M) && M.stat != DEAD)
			if(faction_checked_mob)
				if(M.faction_check_mob(faction_checked_mob, exact_faction_match))
					to_chat(M, msg)
			else
				to_chat(M, msg)
		if(dead_can_hear && (M in GLOB.dead_mob_list))
			var/link = FOLLOW_LINK(M, faction_checked_mob)
			to_chat(M, "[link] [msg]")


//Wrapper for drones to handle factions
/mob/living/simple_animal/drone/proc/alert_drones(msg, dead_can_hear = FALSE)
	_alert_drones(msg, dead_can_hear, src, TRUE)


/mob/living/simple_animal/drone/proc/drone_chat(msg)
	alert_drones("<i>Drone Chat: <span class='name'>[name]</span> <span class='message'>[say_quote(msg, get_spans())]</span></i>", TRUE)

/mob/living/simple_animal/drone/binarycheck()
	return TRUE
