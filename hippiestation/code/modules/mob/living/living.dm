/* This is currently only supported for monkeys */
/mob/living/proc/hippie_equip_mob_with_items(rand_int)
	return
	
/mob/living/resist_grab(moving_resist)
	if(pulledby.grab_state)
		if(prob(30) && pulledby.grab_state != GRAB_KILL)
			visible_message("<span class='danger'>[src] has broken free of [pulledby]'s grip!</span>")
			add_logs(pulledby, src, "broke grab")
			pulledby.stop_pulling()
			return FALSE
		if(moving_resist && client) //we resisted by trying to move
			client.move_delay = world.time + 20
	else
		pulledby.stop_pulling()

/mob/living/proc/canGhost()
	return TRUE

/mob/living/proc/canSuccumb()
	return TRUE