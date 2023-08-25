/*
Unused icons for new areas are "awaycontent1" ~ "awaycontent30"
*/


// Away Missions
/area/awaymission
	name = "Strange Location"
	icon = 'icons/area/areas_away_missions.dmi'
	icon_state = "away"
	has_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_AWAY
	sound_environment = SOUND_ENVIRONMENT_ROOM
	area_flags = UNIQUE_AREA

/area/awaymission/beach
	name = "Beach"
	icon_state = "away"
	static_lighting = FALSE
	base_lighting_alpha = 255
	base_lighting_color = "#FFFFCC"
	requires_power = FALSE
	has_gravity = STANDARD_GRAVITY
	ambientsounds = list('sound/ambience/shore.ogg', 'sound/ambience/seag1.ogg','sound/ambience/seag2.ogg','sound/ambience/seag2.ogg','sound/ambience/ambiodd.ogg','sound/ambience/ambinice.ogg')

/area/awaymission/errorroom
	name = "Super Secret Room"
	static_lighting = FALSE
	base_lighting_alpha = 255
	area_flags = UNIQUE_AREA|NOTELEPORT
	has_gravity = STANDARD_GRAVITY

/area/awaymission/secret
	area_flags = UNIQUE_AREA|NOTELEPORT|HIDDEN_AREA

/area/awaymission/secret/unpowered
	always_unpowered = TRUE

/area/awaymission/secret/unpowered/outdoors
	outdoors = TRUE

/area/awaymission/secret/unpowered/no_grav
	has_gravity = FALSE

/area/awaymission/secret/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/awaymission/secret/powered
	requires_power = FALSE

/area/awaymission/secret/powered/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255
