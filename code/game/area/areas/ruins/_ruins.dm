//Parent types

/area/ruin
	name = "\improper Unexplored Location"
	icon = 'icons/area/areas_ruins.dmi'
	icon_state = "ruins"
	has_gravity = STANDARD_GRAVITY
	area_flags = HIDDEN_AREA | BLOBS_ALLOWED | UNIQUE_AREA | NO_ALERTS
	static_lighting = TRUE
	ambience_index = AMBIENCE_RUINS
	atom_flags = CAN_BE_DIRTY
	sound_environment = SOUND_ENVIRONMENT_STONEROOM

/area/ruin/unpowered
	always_unpowered = TRUE

/area/ruin/unpowered/no_grav
	has_gravity = FALSE

/area/ruin/powered
	requires_power = FALSE
