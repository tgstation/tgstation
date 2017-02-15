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
/proc/_alert_drones(msg, dead_can_hear = 0, list/factions)
	for(var/W in mob_list)
		var/mob/living/simple_animal/drone/M = W
		if(istype(M) && M.stat != DEAD)
			if(factions && factions.len)
				var/list/friendly = factions&M.faction
				if(friendly.len)
					to_chat(M, msg)
			else
				to_chat(M, msg)
		if(dead_can_hear && (M in dead_mob_list))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [msg]")


//Wrapper for drones to handle factions
/mob/living/simple_animal/drone/proc/alert_drones(msg, dead_can_hear = 0)
	_alert_drones(msg, dead_can_hear, faction)


/mob/living/simple_animal/drone/proc/drone_chat(msg)
	var/rendered = "<i>Drone Chat: \
		<span class='name'>[name]</span>: \
		<span class='message'>[say_quote(msg, get_spans())]</span></i>"
	alert_drones(rendered, 1)

/mob/living/simple_animal/drone/binarycheck()
	return TRUE
