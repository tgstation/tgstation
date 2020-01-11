/datum/movespeed_modifier/status_effect/bloodchill
	id = "bloodchilled"
	multiplicative_slowdown = 3

/datum/movespeed_modifier/status_effect/bonechill
	id = "bonechilled"
	multiplicative_slowdown = 3

/datum/movespeed_modifier/status_effect/lightpink
	id = MOVESPEED_ID_SLIME_STATUS
	multiplicative_slowdown = -0.5
	blacklisted_movetypes = (FLYING|FLOATING)

/datum/movespeed_modifier/status_effect/tarfoot
	id = MOVESPEED_ID_TARFOOT
	multiplicative_slowdown = 0.5
	blacklisted_movetypes = (FLYING|FLOATING)

/datum/movespeed_modifier/status_effect/sepia
	variable = TRUE
	id = MOVESPEED_ID_SEPIA
	blacklisted_movetypes = (FLYING|FLOATING)
