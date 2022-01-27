//Parent types

/area/ruin
	name = "\improper Unexplored Location"
	icon_state = "away"
	has_gravity = STANDARD_GRAVITY
	area_flags = HIDDEN_AREA | BLOBS_ALLOWED | UNIQUE_AREA | NO_ALERTS
	static_lighting = TRUE
	ambience_index = AMBIENCE_RUINS
	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_ENVIRONMENT_STONEROOM


/area/ruin/unpowered
	name = "\improper Powerless Ruin" //let's be honest, you shouldn't be using these names
	always_unpowered = TRUE

/area/ruin/unpowered/no_grav
	name = "\improper Gravityless and Powerless Ruin"
	has_gravity = FALSE

/area/ruin/powered
	name = "\improper Powered Ruin"
	requires_power = FALSE


//Anywhere Ruins
/area/ruin/unpowered/fountainhall
	name = "\improper Fountain Hall"
