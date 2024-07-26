/area/forestplanet
	icon = 'icons/area/areas_station.dmi'
	icon_state = "mining"
	has_gravity = STANDARD_GRAVITY
	flags_1 = NONE
	area_flags = UNIQUE_AREA | FLORA_ALLOWED
	//ambience_index = AMBIENCE_ICEMOON
	sound_environment = SOUND_ENVIRONMENT_PLAIN
	ambient_buzz = 'monkestation/code/modules/outdoors/sound/weather/forest_ambience.ogg'
	name = "Forest Planet"
	icon_state = "explored"
	always_unpowered = TRUE
	power_environ = FALSE
	power_equip = FALSE
	power_light = FALSE
	requires_power = TRUE
	min_ambience_cooldown = 70 SECONDS
	max_ambience_cooldown = 220 SECONDS

/area/forestplanet/outdoors // parent that defines if something is on the exterior of the station.
	name = "Woodlands"
	outdoors = TRUE

/area/forestplanet/outdoors/nospawn

/area/forestplanet/outdoors/unexplored
	icon_state = "unexplored"
	area_flags = UNIQUE_AREA | FLORA_ALLOWED | MOB_SPAWN_ALLOWED | CAVES_ALLOWED
	map_generator = /datum/map_generator/cave_generator/forest

/area/forestplanet/outdoors/unexplored/deep
	name = "Mushroom Caves"
	map_generator = /datum/map_generator/cave_generator/forest/mushroom

	sound_environment = SOUND_ENVIRONMENT_CAVE
