/datum/movespeed_modifier/obesity
	// large weight slows even if flying and floating
	multiplicative_slowdown = 1.5

/datum/movespeed_modifier/monkey_reagent_speedmod
	variable = TRUE

/datum/movespeed_modifier/monkey_health_speedmod
	variable = TRUE

/datum/movespeed_modifier/monkey_temperature_speedmod
	variable = TRUE

/datum/movespeed_modifier/hunger
	movetypes = GROUND|FLYING
	variable = TRUE

/datum/movespeed_modifier/golem_hunger
	variable = TRUE

/datum/movespeed_modifier/slaughter
	multiplicative_slowdown = -1

/datum/movespeed_modifier/resonance
	multiplicative_slowdown = 0.75

/datum/movespeed_modifier/basic_stamina_slowdown
	variable = TRUE

/datum/movespeed_modifier/damage_slowdown
	blacklisted_movetypes = FLOATING
	variable = TRUE

/// Movespeed modifier applied by worn equipment.
/datum/movespeed_modifier/equipment_speedmod
	variable = TRUE
	blacklisted_movetypes = FLOATING

/// Movespeed modifier applied by immutably slow worn equipment. Should never be ignored, because that's the point.
/datum/movespeed_modifier/equipment_speedmod/immutable

/datum/movespeed_modifier/grab_slowdown
	id = MOVESPEED_ID_MOB_GRAB_STATE
	blacklisted_movetypes = FLOATING

/datum/movespeed_modifier/grab_slowdown/aggressive
	multiplicative_slowdown = 3

/datum/movespeed_modifier/grab_slowdown/neck
	multiplicative_slowdown = 6

/datum/movespeed_modifier/grab_slowdown/kill
	multiplicative_slowdown = 9

/datum/movespeed_modifier/config_walk_run
	multiplicative_slowdown = 1
	id = MOVESPEED_ID_MOB_WALK_RUN
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/config_walk_run/proc/sync()

/datum/movespeed_modifier/config_walk_run/walk/sync()
	var/mod = CONFIG_GET(number/movedelay/walk_delay)
	multiplicative_slowdown = isnum(mod)? mod : initial(multiplicative_slowdown)

/datum/movespeed_modifier/config_walk_run/run/sync()
	var/mod = CONFIG_GET(number/movedelay/run_delay)
	multiplicative_slowdown = isnum(mod)? mod : initial(multiplicative_slowdown)

/datum/movespeed_modifier/turf_slowdown
	movetypes = GROUND
	blacklisted_movetypes = (FLYING|FLOATING)
	variable = TRUE

/datum/movespeed_modifier/bulky_drag
	variable = TRUE
	blacklisted_movetypes = FLOATING

/datum/movespeed_modifier/cold
	blacklisted_movetypes = FLOATING
	variable = TRUE

/datum/movespeed_modifier/staggered
	multiplicative_slowdown = STAGGERED_SLOWDOWN_STRENGTH

/datum/movespeed_modifier/human_carry
	multiplicative_slowdown = HUMAN_CARRY_SLOWDOWN
	blacklisted_movetypes = FLOATING

/datum/movespeed_modifier/limbless
	variable = TRUE
	movetypes = GROUND
	blacklisted_movetypes = FLOATING|FLYING
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/simplemob_varspeed
	variable = TRUE
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/fast_web
	multiplicative_slowdown = 0.2

/datum/movespeed_modifier/young_web
	multiplicative_slowdown = 0.5

/datum/movespeed_modifier/spiderling_web
	multiplicative_slowdown = 0.7

/datum/movespeed_modifier/average_web
	multiplicative_slowdown = 1.2

/datum/movespeed_modifier/below_average_web
	multiplicative_slowdown = 2.5

/datum/movespeed_modifier/slow_web
	multiplicative_slowdown = 5

/datum/movespeed_modifier/viper_defensive
	multiplicative_slowdown = 1.5

/datum/movespeed_modifier/gravity
	blacklisted_movetypes = FLOATING
	variable = TRUE
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/carbon_softcrit
	multiplicative_slowdown = SOFTCRIT_ADD_SLOWDOWN
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/carbon_crawling
	multiplicative_slowdown = CRAWLING_ADD_SLOWDOWN
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/mob_config_speedmod
	variable = TRUE
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/metabolicboost
	multiplicative_slowdown = -1.5

/datum/movespeed_modifier/dragon_rage
	multiplicative_slowdown = -0.5

/datum/movespeed_modifier/dragon_depression
	multiplicative_slowdown = 5

/datum/movespeed_modifier/morph_disguised
	multiplicative_slowdown = -1

/datum/movespeed_modifier/auto_wash
	multiplicative_slowdown = 3

/datum/movespeed_modifier/player_spider_modifier
	variable = TRUE

/datum/movespeed_modifier/health_scaling_speed_buff
	variable = TRUE

/datum/movespeed_modifier/alien_speed
	variable = TRUE

/datum/movespeed_modifier/grown_killer_tomato
	variable = TRUE

/datum/movespeed_modifier/goliath_mount
	multiplicative_slowdown = -26

/datum/movespeed_modifier/goldgrub_mount
	multiplicative_slowdown = -3

/datum/movespeed_modifier/settler
	multiplicative_slowdown = 0.2
	blacklisted_movetypes = FLOATING|FLYING

/datum/movespeed_modifier/basilisk_overheat
	multiplicative_slowdown = -18

/datum/movespeed_modifier/magic_ties
	multiplicative_slowdown = 0.5

///Speed bonus given by the fish tail organ when inside water.
/datum/movespeed_modifier/fish_on_water
	blacklisted_movetypes = MOVETYPES_NOT_TOUCHING_GROUND
	multiplicative_slowdown = - /turf/open/water::slowdown

///Slowdown for swimming on deep water tiles
/datum/movespeed_modifier/swimming_deep
	blacklisted_movetypes = MOVETYPES_NOT_TOUCHING_GROUND
	multiplicative_slowdown = 7

/datum/movespeed_modifier/tail_dragger
	multiplicative_slowdown = 4
