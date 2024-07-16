/datum/movespeed_modifier/status_effect/bloodchill
	multiplicative_slowdown = 3

/datum/movespeed_modifier/status_effect/bonechill
	multiplicative_slowdown = 3

/datum/movespeed_modifier/status_effect/lightpink
	multiplicative_slowdown = -0.5
	blacklisted_movetypes = (FLYING|FLOATING)

/datum/movespeed_modifier/status_effect/tarfoot
	multiplicative_slowdown = 0.5
	blacklisted_movetypes = (FLYING|FLOATING)

/datum/movespeed_modifier/status_effect/sepia
	variable = TRUE
	blacklisted_movetypes = (FLYING|FLOATING)

/datum/movespeed_modifier/status_effect/power_chord
	multiplicative_slowdown = -0.2

/datum/movespeed_modifier/status_effect/hazard_area
	multiplicative_slowdown = 4

/datum/movespeed_modifier/status_effect/lobster_rush
	multiplicative_slowdown = -0.5
	blacklisted_movetypes = (FLYING|FLOATING)

/datum/movespeed_modifier/status_effect/brimdust_concussion
	multiplicative_slowdown = 1.5

/datum/movespeed_modifier/status_effect/inflated
	multiplicative_slowdown = 3.5

/datum/movespeed_modifier/status_effect/light_speed
	multiplicative_slowdown = -0.2 // lighting is pretty slow in BYOND

/datum/movespeed_modifier/status_effect/tired_post_charge
	multiplicative_slowdown = 3

/datum/movespeed_modifier/status_effect/tired_post_charge/lesser
	multiplicative_slowdown = 2

/// Get slower the more gold is in your system.
/datum/movespeed_modifier/status_effect/midas_blight
	id = MOVESPEED_ID_MIDAS_BLIGHT

/datum/movespeed_modifier/status_effect/midas_blight/soft
	multiplicative_slowdown = 0.25

/datum/movespeed_modifier/status_effect/midas_blight/medium
	multiplicative_slowdown = 0.75

/datum/movespeed_modifier/status_effect/midas_blight/hard
	multiplicative_slowdown = 1.5

/datum/movespeed_modifier/status_effect/midas_blight/gold
	multiplicative_slowdown = 2

/datum/movespeed_modifier/status_effect/guardian_shield
	multiplicative_slowdown = 1
