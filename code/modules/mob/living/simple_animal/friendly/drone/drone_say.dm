/**
 * Broadcast a message to all drones in a faction
 *
 * Arguments:
 * * msg - The message to send
 * * dead_can_hear - Boolean that determines if ghosts can hear the message (`FALSE` by default)
 * * source - [/atom] source that created the message
 * * faction_checked_mob - [/mob/living] to determine faction matches from
 * * exact_faction_match - Passed to [/mob/proc/faction_check_mob]
 */
/proc/_alert_drones(msg, dead_can_hear = FALSE, atom/source, mob/living/faction_checked_mob, exact_faction_match)
	if (dead_can_hear && source)
		for (var/mob/M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, source)
			to_chat(M, "[link] [msg]")
	for(var/i in GLOB.drones_list)
		var/mob/living/simple_animal/drone/D = i
		if(istype(D) && D.stat != DEAD)
			if(faction_checked_mob)
				if(D.faction_check_mob(faction_checked_mob, exact_faction_match))
					to_chat(D, msg)
			else
				to_chat(D, msg)



/**
 * Wraps [/proc/_alert_drones] with defaults
 *
 * * source - `src`
 * * faction_check_mob - `src`
 * * dead_can_hear - `TRUE`
 */
/mob/living/simple_animal/drone/proc/alert_drones(msg, dead_can_hear = FALSE)
	_alert_drones(msg, dead_can_hear, src, src, TRUE)

/**
 * Wraps [/mob/living/simple_animal/drone/proc/alert_drones] as a Drone Chat
 *
 * Shares the same radio code with binary
 */
/mob/living/simple_animal/drone/proc/drone_chat(msg)
	alert_drones("<i>Drone Chat: <span class='name'>[name]</span> <span class='message'>[say_quote(msg)]</span></i>", TRUE)

/mob/living/simple_animal/drone/binarycheck()
	return TRUE
