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

/datum/movespeed_modifier/pai_spacewalk
	id = MOVESPEED_ID_PAI_SPACEWALK_SPEEDMOD
	multiplicative_slowdown = 2
