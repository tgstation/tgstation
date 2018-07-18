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
	var/static/datum/config_entry/keyed_number_list/multiplicative_movespeed/config_entry
	if(!istype(config_entry))
		config_entry = CONFIG_GET_DATUM(keyed_number_list/multiplicative_movespeed)
	if(islist(config_entry.config_entry_value))
		if(m_intent == MOVE_INTENT_WALK)
			mod = config_entry.config_entry_value["walk"]
		else
			mod = config_entry.config_entry_value["run"]
	if(!isnum(mod))
		mod = 1
	add_movespeed_modifier(MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED, TRUE, 100, override = TRUE, legacy_slowdown = mod)

/mob/living/proc/update_turf_movespeed(turf/open/T)
	if(isopenturf(T) && !is_flying())
		add_movespeed_modifier(MOVESPEED_ID_LIVING_TURF_SPEEDMOD, TRUE, 100, override = TRUE, legacy_slowdown = T.slowdown)
	else
		remove_movespeed_modifier(MOVESPEED_ID_LIVING_TURF_SPEEDMOD)
