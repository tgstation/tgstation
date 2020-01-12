/datum/movespeed_modifier/obesity
	id = MOVESPEED_ID_FAT
	multiplicative_slowdown = 1.5

/datum/movespeed_modifier/monkey_reagent_speedmod
	variable = TRUE
	id = MOVESPEED_ID_MONKEY_REAGENT_SPEEDMOD

/datum/movespeed_modifier/monkey_health_speedmod
	variable = TRUE
	id = MOVESPEED_ID_MONKEY_HEALTH_SPEEDMOD

/datum/movespeed_modifier/monkey_temperature_speedmod
	variable = TRUE
	id = MOVESPEED_ID_MONKEY_TEMPERATURE_SPEEDMOD

/datum/movespeed_modifier/hunger
	id = MOVESPEED_ID_HUNGRY
	variable = TRUE

/datum/movespeed_modifier/slaughter
	id = MOVESPEED_ID_SLAUGHTER
	multiplicative_slowdown = -1

/datum/movespeed_modifier/damage_slowdown
	id = MOVESPEED_ID_DAMAGE_SLOWDOWN
	blacklisted_movetypes = FLOATING|FLYING

/datum/movespeed_modifier/damage_slowdown_flying
	id = MOVESPEED_ID_DAMAGE_SLOWDOWN_FLYING
	movetypes = FLOATING

/datum/movespeed_modifier/equipment_speedmod
	variable = TRUE
	id = MOVESPEED_ID_MOB_EQUIPMENT
	blacklisted_movetypes = FLOATING

/datum/movespeed_modifier/grab_slowdown
	id = MOVESPEED_ID_MOB_GRAB_STATE
	blacklisted_movetypes = FLOATING

/datum/movespeed_modifier/grab_slowdown/aggressive
	multiplicative_slowdown = 3

/datum/movespeed_modifier/grab_slowdown/neck
	multiplicative_slowdown = 6

/datum/movespeed_modifier/grab_slowdown/kill
	multiplicative_slowdown = 9

/datum/movespeed_modifier/slime_reagentmod
	id = MOVESPEED_ID_SLIME_REAGENTMOD
	variable = TRUE

/datum/movespeed_modifier/slime_healthmod
	id = MOVESPEED_ID_SLIME_HEALTHMOD
	variable = TRUE

/datum/movespeed_modifier/config_walk_run
	id = MOVESPEED_ID_MOB_WALK_RUN_CONFIG_SPEED
	multiplicative_slowdown = 1

/datum/movespeed_modifier/config_walk_run/proc/sync()

/datum/movespeed_modifier/config_walk_run/walk/sync()
	var/mod = CONFIG_GET(number/movedelay/walk_delay)
	multiplicative_slowdown = isnum(mod)? mod : initial(multiplicative_slowdown)

/datum/movespeed_modifier/config_walk_run/run/sync()
	var/mod = CONFIG_GET(number/movedelay/run_delay)
	multiplicative_slowdown = isnum(mod)? mod : initial(multiplicative_slowdown)

/datum/movespeed_modifier/turf_slowdown
	id = MOVESPEED_ID_LIVING_TURF_SPEEDMOD
	movetypes = GROUND
	variable = TRUE

/datum/movespeed_modifier/bulky_drag
	id = MOVESPEED_ID_BULKY_DRAGGING
	variable = TRUE

/datum/movespeed_modifier/cold
	id = MOVESPEED_ID_COLD
	blacklisted_movetypes = FLOATING
	variable = TRUE

/datum/movespeed_modifier/shove
	id = MOVESPEED_ID_SHOVE
	multiplicative_slowdown = SHOVE_SLOWDOWN_STRENGTH

/datum/movespeed_modifier/human_carry
	id = MOVESPEED_ID_HUMAN_CARRYING
	multiplicative_slowdown = HUMAN_CARRY_SLOWDOWN

/datum/movespeed_modifier/limbless
	id = MOVESPEED_ID_LIVING_LIMBLESS
	variable = TRUE
	movetypes = GROUND

/datum/movespeed_modifier/simplemob_varspeed
	id = MOVESPEED_ID_SIMPLEMOB_VARSPEED
	variable = TRUE

/datum/movespeed_modifier/tarantula_web
	id = MOVESPEED_ID_TARANTULA_WEB
	multiplicative_slowdown = 3

/datum/movespeed_modifier/gravity
	id = MOVESPEED_ID_MOB_GRAVITY
	blacklisted_movetypes = FLOATING
	variable = TRUE

/datum/movespeed_modifier/carbon_softcrit
	id = MOVESPEED_ID_CARBON_SOFTCRIT
	multiplicative_slowdown = SOFTCRIT_ADD_SLOWDOWN

/datum/movespeed_modifier/slime_tempmod
	id = MOVESPEED_ID_SLIME_TEMPMOD
	variable = TRUE
