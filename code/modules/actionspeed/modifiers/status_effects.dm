/datum/actionspeed_modifier/timecookie
	multiplicative_slowdown = -0.05

/datum/actionspeed_modifier/blunt_wound
	variable = TRUE

/datum/actionspeed_modifier/nooartrium
	multiplicative_slowdown = 0.5

/datum/actionspeed_modifier/power_chord
	multiplicative_slowdown = -0.15

/datum/actionspeed_modifier/status_effect/hazard_area
	multiplicative_slowdown = 4

/// Get slower the more gold is in your system.
/datum/actionspeed_modifier/status_effect/midas_blight
	id = ACTIONSPEED_ID_MIDAS_BLIGHT

/datum/actionspeed_modifier/status_effect/midas_blight/soft
	multiplicative_slowdown = 0.25

/datum/actionspeed_modifier/status_effect/midas_blight/medium
	multiplicative_slowdown = 0.75

/datum/actionspeed_modifier/status_effect/midas_blight/hard
	multiplicative_slowdown = 1.5

/datum/actionspeed_modifier/status_effect/midas_blight/gold
	multiplicative_slowdown = 2
