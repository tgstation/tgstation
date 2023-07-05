/**
 * Converts a player to a cluwne basic mob.
 * Swaps their body and drops all their items.
 */
/mob/living/proc/cluwne_transform_mob()
	var/datum/mind/player_mind = mind

	to_chat(player_mind, span_danger("You're feeling unusually giggly. Was that a honk in the distance?"))
	playsound_local(src, 'sound/misc/honk_echo_distant.ogg', 50, 2)
	do_jitter_animation(300)

	sleep(3 SECONDS)
	if(QDELETED(src) || stat == DEAD)
		return

	to_chat(player_mind, span_danger("Your mind is being ripped apart like threads in fabric, everything you've ever known is gone."))
	drop_all_held_items()
	Paralyze(3 SECONDS)

	sleep(3 SECONDS)
	if(QDELETED(src) || stat == DEAD)
		return

	to_chat(player_mind, span_honknosis("There is only the <b><i>Honkmother</i></b> now."))

	sleep(1 SECONDS)
	if(QDELETED(src) || stat == DEAD)
		return

	var/mob/living/basic/cluwne/newmob = new(get_turf(src))
	player_mind.transfer_to(newmob)

	if(key)  // afk
		newmob.key = key

	to_chat(player_mind, span_userdanger("<i>Honk honk!</i>"))
	qdel(src)

	return TRUE
