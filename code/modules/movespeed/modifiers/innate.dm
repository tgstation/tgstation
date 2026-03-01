/datum/movespeed_modifier/strained_muscles
	multiplicative_slowdown = -0.55
	blacklisted_movetypes = (FLYING|FLOATING)

/datum/movespeed_modifier/pai_spacewalk
	multiplicative_slowdown = 2
	flags = IGNORE_NOSLOW

/datum/movespeed_modifier/snail
	blacklisted_movetypes = FLYING
	variable = TRUE

// no reason for leg loss (or gain) to affect speed if drifting
/datum/movespeed_modifier/bodypart
	blacklisted_movetypes = (FLYING|FLOATING)
	variable = TRUE

/datum/movespeed_modifier/dna_vault_speedup
	blacklisted_movetypes = (FLYING|FLOATING)
	multiplicative_slowdown = -0.4

/// The movespeed modifier from the heavy fish trait when applied to mobs.
/datum/movespeed_modifier/heavy_fish
	multiplicative_slowdown = 0.4
	flags = IGNORE_NOSLOW
