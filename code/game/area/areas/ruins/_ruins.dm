//Parent types

/area/ruin
	name = "\improper Unexplored Location"
	icon = 'icons/area/areas_ruins.dmi'
	icon_state = "ruins"
	default_gravity = STANDARD_GRAVITY
	area_flags = HIDDEN_AREA | UNIQUE_AREA
	ambience_index = AMBIENCE_RUINS
	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_ENVIRONMENT_STONEROOM

/area/ruin/unpowered
	always_unpowered = TRUE

/area/ruin/unpowered/no_grav
	default_gravity = ZERO_GRAVITY

/area/ruin/powered
	requires_power = FALSE

