//Parent types

/area/ruin
	name = "\improper Unexplored Location"
	icon = 'icons/area/areas_ruins.dmi'
	icon_state = "ruins"
	has_gravity = STANDARD_GRAVITY
	area_flags = HIDDEN_AREA | BLOBS_ALLOWED | UNIQUE_AREA
	static_lighting = TRUE
	ambience_index = AMBIENCE_RUINS
	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_ENVIRONMENT_STONEROOM

/area/ruin/unpowered
	always_unpowered = TRUE

/area/ruin/unpowered/no_grav
	has_gravity = FALSE

/area/ruin/powered
	requires_power = FALSE

