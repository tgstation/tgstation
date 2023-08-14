/mob/living/basic/jungle
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list(FACTION_JUNGLE)
	obj_damage = 30
	environment_smash = ENVIRONMENT_SMASH_WALLS
	minimum_survivable_temperature = T0C
	maximum_survivable_temperature = T0C + 450
	status_flags = NONE
	// Let's do a blue, since they'll be on green turfs if this shit is ever finished
	lighting_cutoff_red = 5
	lighting_cutoff_green = 20
	lighting_cutoff_blue = 25
	mob_size = MOB_SIZE_LARGE
