/// Pulled verbatim from Daedalus Dock.
/datum/config_entry/number/movedelay/sprint_delay
	integer = FALSE

/datum/config_entry/number/movedelay/sprint_delay/ValidateAndSet()
	. = ..()
	var/datum/movespeed_modifier/config_walk_run/M = get_cached_movespeed_modifier(/datum/movespeed_modifier/config_walk_run/sprint)
	M.sync()

/datum/movespeed_modifier/config_walk_run/sprint/sync()
	var/mod = CONFIG_GET(number/movedelay/sprint_delay)
	multiplicative_slowdown = isnum(mod) ? mod : initial(multiplicative_slowdown)

/datum/movespeed_modifier/living_exhaustion
	multiplicative_slowdown = STAMINA_EXHAUSTION_MOVESPEED_SLOWDOWN
	flags = IGNORE_NOSLOW
