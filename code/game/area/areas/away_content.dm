/*
Unused icons for new areas are "awaycontent1" ~ "awaycontent30"
*/


// Away Missions
/area/awaymission
	name = "Strange Location"
	icon = 'icons/area/areas_away_missions.dmi'
	icon_state = "away"
	default_gravity = STANDARD_GRAVITY
	ambience_index = AMBIENCE_AWAY
	sound_environment = SOUND_ENVIRONMENT_ROOM
	skip_minimap_rendering = TRUE

/area/awaymission/museum
	name = "Nanotrasen Museum"
	icon_state = "awaycontent28"
	sound_environment = SOUND_ENVIRONMENT_CONCERT_HALL

/area/awaymission/museum/mothroachvoid
	static_lighting = FALSE
	base_lighting_alpha = 200
	base_lighting_color = "#FFF4AA"
	sound_environment = SOUND_ENVIRONMENT_PLAIN
	ambientsounds = list('sound/ambience/beach/shore.ogg', 'sound/ambience/misc/ambiodd.ogg','sound/ambience/medical/ambinice.ogg')

/area/awaymission/museum/cafeteria
	name = "Nanotrasen Museum Cafeteria"
	sound_environment = SOUND_ENVIRONMENT_ROOM

/area/awaymission/museum/inaccessible
	name = "Nanotrasen Museum (INACCESSIBLE)"
	icon_state = "away_inaccessible"
	area_flags = NOTELEPORT|HIDDEN_AREA

/area/awaymission/errorroom
	name = "Super Secret Room"
	static_lighting = FALSE
	base_lighting_alpha = 255
	area_flags = NOTELEPORT
	default_gravity = STANDARD_GRAVITY

/area/awaymission/secret
	area_flags = NOTELEPORT|HIDDEN_AREA

/area/awaymission/secret/unpowered
	always_unpowered = TRUE

/area/awaymission/secret/unpowered/outdoors
	outdoors = TRUE

/area/awaymission/secret/unpowered/no_grav
	default_gravity = ZERO_GRAVITY

/area/awaymission/secret/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/awaymission/secret/powered
	requires_power = FALSE

/area/awaymission/secret/powered/fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

///Denotes area of away missions that shouldn't be accessible through teleportation etc.
/area/awaymission/inaccessible
	name = "inaccessible away mission area"
	icon_state = "away_inaccessible"
	area_flags = NOTELEPORT|HIDDEN_AREA
