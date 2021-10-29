#define RESTING_STATE_NONE 0
#define RESTING_STATE_SIT 1
#define RESTING_STATE_REST 2

/mob/living/simple_animal/pet/dog/corgi/ian
	var/resting_state = 0
	var/old = FALSE

/mob/living/simple_animal/pet/dog/corgi/ian/Life(delta_time = SSMOBS_DT, times_fired)
	if(!stat && SSticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory(FALSE)
		memory_saved = TRUE
	if(!stat && !buckled && !client && !inventory_head && !inventory_back)
		if(DT_PROB(0.5, delta_time))
			manual_emote(pick("flops forward laying flat.", "wags [p_their()] tail.", "lies down."))
			set_rest_state(RESTING_STATE_REST)
		else if(DT_PROB(0.5, delta_time))
			manual_emote(pick("sits down.", "crouches on [p_their()] hind legs.", "looks alert."))
			set_rest_state(RESTING_STATE_SIT)
		else if(DT_PROB(0.5, delta_time))
			if (resting_state)
				manual_emote(pick("gets up and barks.", "walks around.", "stops resting."))
				set_rest_state(RESTING_STATE_NONE)
			else
				manual_emote(pick("grooms [p_their()] fur.", "twitches [p_their()] ears.", "shakes [p_their()] fur."))
	..()

/mob/living/simple_animal/pet/dog/corgi/ian/Moved()
	. = ..()
	if(resting_state)
		manual_emote(pick("gets up and barks.", "walks around.", "stops resting."))
		set_rest_state(RESTING_STATE_NONE)

/mob/living/simple_animal/pet/dog/corgi/ian/proc/set_rest_state(state)
	resting_state = state
	update_icons()

/mob/living/simple_animal/pet/dog/corgi/ian/update_icons()
	. = ..()
	if(old && !stat)
		icon_state = "[initial(icon_state)]_old[shaved ? "_shaved" : ""]"
	else if(!stat)
		switch(resting_state)
			if(RESTING_STATE_NONE)
				icon_state = initial(icon_state)
			if(RESTING_STATE_SIT)
				icon_state = "[initial(icon_state)]_sit[shaved ? "_shaved" : ""]"
			if(RESTING_STATE_REST)
				icon_state = "[initial(icon_state)]_rest[shaved ? "_shaved" : ""]"
	else
		icon_state = icon_dead

#undef RESTING_STATE_NONE
#undef RESTING_STATE_SIT
#undef RESTING_STATE_REST
