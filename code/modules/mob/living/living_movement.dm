/mob/living/Moved()
	. = ..()
	update_turf_movespeed(loc)

/mob/living/toggle_move_intent()
	. = ..()
	update_move_intent_slowdown()

/mob/living/update_config_movespeed()
	update_move_intent_slowdown()

/mob/living/proc/update_move_intent_slowdown()
	var/mod = 0
	var/static/datum/config_entry/number/movedelay/walk_delay/walk_entry
	var/static/datum/config_entry/number/movedelay/run_delay/run_entry
	if(!istype(walk_entry) || !istype(run_entry))
		walk_entry = CONFIG_GET_DATUM(number/movedelay/walk_delay)
		run_entry = CONFIG_GET_DATUM(number/movedelay/run_delay)
	if(m_intent == MOVE_INTENT_WALK)
		mod = walk_entry.config_entry_value
	else
		mod = run_entry.config_entry_value
	if(!isnum(mod))
		mod = 1
	add_movespeed_modifier(MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED, TRUE, 100, override = TRUE, legacy_slowdown = mod)

/mob/living/proc/update_turf_movespeed(turf/open/T)
	if(isopenturf(T) && !is_flying())
		add_movespeed_modifier(MOVESPEED_ID_LIVING_TURF_SPEEDMOD, TRUE, 100, override = TRUE, legacy_slowdown = T.slowdown)
	else
		remove_movespeed_modifier(MOVESPEED_ID_LIVING_TURF_SPEEDMOD)
