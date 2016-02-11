
/////////////
//DRONE SAY//
/////////////
//Drone speach
//Drone hearing

/mob/living/simple_animal/drone/lang_treat(atom/movable/speaker, message_langs, raw_message) //This is so drones can understand humans without being able to speak human
	. = ..()
	var/hear_override_langs = HUMAN
	if(message_langs & hear_override_langs)
		return ..(speaker, languages, raw_message)


/mob/living/simple_animal/drone/handle_inherent_channels(message, message_mode)
	if(message_mode == MODE_BINARY)
		drone_chat(message)
		return ITALICS | REDUCE_RANGE
	else
		..()


/mob/living/simple_animal/drone/proc/alert_drones(msg, dead_can_hear = 0)
	for(var/W in mob_list)
		var/mob/living/simple_animal/drone/M = W
		if(istype(M) && M.stat != DEAD && faction_check(M)) //if it's a living drone with matching factions, it gets a message
			M << msg
		if(dead_can_hear && (M in dead_mob_list))
			M << "<a href='?src=\ref[M];follow=\ref[src]'>(F)</a> [msg]"


/mob/living/simple_animal/drone/proc/drone_chat(msg)
	var/rendered = "<i>DRONE CHAT: <span class='name'>[name]</span>: [msg]</i>"
	alert_drones(rendered, 1)