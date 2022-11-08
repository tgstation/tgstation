// Areas that don't fit any of the other files, or only serve one purpose.

/area/space
	icon_state = "space"
	requires_power = TRUE
	always_unpowered = TRUE
	static_lighting = FALSE

	base_lighting_alpha = 255
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	area_flags = UNIQUE_AREA
	outdoors = TRUE
	ambience_index = AMBIENCE_SPACE
	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_AREA_SPACE
	ambient_buzz = null //Space is deafeningly quiet

/area/space/nearstation
	icon_state = "space_near"
	area_flags = UNIQUE_AREA | AREA_USES_STARLIGHT

/area/misc/start
	name = "start area"
	icon_state = "start"
	requires_power = FALSE
	static_lighting = FALSE
	base_lighting_alpha = 255
	has_gravity = STANDARD_GRAVITY

/area/misc/testroom
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	name = "Test Room"
	icon_state = "test_room"

/// External "asteroid" portions that are still part of the astral body that the station rests on. Do not use in planetary settings for an "outdoors" area.
/// Should only be used when the asteroid is perfectly replacable with a space turf/area.
/area/asteroid
	name = "\improper Asteroid Exterior"
	icon_state = "asteroid"
	always_unpowered = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	requires_power = TRUE
	ambience_index = AMBIENCE_MINING
	sound_environment = SOUND_AREA_ASTEROID
	area_flags = VALID_TERRITORY | UNIQUE_AREA
	flags_1 = CAN_BE_DIRTY_1
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS
