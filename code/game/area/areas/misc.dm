// Areas that don't fit any of the other files, or only serve one purpose.

/area/space
	icon_state = "space"
	requires_power = TRUE
	always_unpowered = TRUE
	static_lighting = FALSE

	base_lighting_alpha = 255
	base_lighting_color = COLOR_STARLIGHT
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE
	area_flags = UNIQUE_AREA
	outdoors = TRUE
	ambience_index = AMBIENCE_SPACE
	flags_1 = CAN_BE_DIRTY_1
	sound_environment = SOUND_AREA_SPACE
	ambient_buzz = null //Space is deafeningly quiet
	min_ambience_cooldown = 195 SECONDS //length of ambispace.ogg
	max_ambience_cooldown = 200 SECONDS

/area/space/nearstation
	icon_state = "space_near"
	area_flags = UNIQUE_AREA
	static_lighting = TRUE
	base_lighting_alpha = 0
	base_lighting_color = null

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
	// Mobs should be able to see inside the testroom
	static_lighting = FALSE
	base_lighting_alpha = 255
	name = "Test Room"
	icon_state = "test_room"

/area/misc/testroom/gateway_room
	name = "Gateway Room"
	icon = 'icons/area/areas_station.dmi'
	icon_state = "gateway"
