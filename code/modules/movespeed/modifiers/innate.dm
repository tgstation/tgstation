/datum/movespeed_modifier/strained_muscles
	id = MOVESPEED_ID_CHANGELING_MUSCLES
	multiplicative_slowdown = -1
	blacklisted_movetypes = (FLYING|FLOATING)

/datum/movespeed_modifier/pai_spacewalk
	id = MOVESPEED_ID_PAI_SPACEWALK_SPEEDMOD
	multiplicative_slowdown = 2

/datum/movespeed_modifier/species
	id = MOVESPEED_ID_SPECIES
	movetypes = ~FLYING
	variable = TRUE

/datum/movespeed_modifier/dna_vault_speedup
	id = MOVESPEED_ID_DNA_VAULT
	blacklisted_movetypes = (FLYING|FLOATING)
	multiplicative_slowdown = -0.4
