// voidcrew TODO: all of the commented out code in here has to do with planet generation

/datum/overmap/planet
	///Name of the planet
	var/name = "Planet"
	///Description of the planet
	var/desc = "A generic planet, tell the Coders that you found this."
	///Icon of the planet
	var/icon_state = "globe"
	///Colour of the planet
	var/color = COLOR_WHITE

	/* Planet Generation */
	///Planet spawn rate
	var/spawn_rate = 20
	///The list of ruins that can spawn here
	var/ruin_type
	///The area the ruin needs
	var/area/planet_area

	///The map generator to use
	var/datum/map_generator/mapgen
	///The surface turf
	var/turf/surface = /turf/open/space
	///Z traits of the planet
	var/list/planet_ztraits


	// Area vars
	///Name of the area
	var/area_name = "\improper Planetoid"
	///Flags this area should have
	var/area_flags = (CAVES_ALLOWED | FLORA_ALLOWED | MOB_SPAWN_ALLOWED)
	///Ambience that should play on this planet
	var/ambientsounds = AMBIENCE_MINING
	///Sound environment of the planet
	var/sound_environment = SOUND_ENVIRONMENT_CAVE


/datum/overmap/planet/lava
	name = "strange lava planet"
	desc = "A very weak energy signal originating from a planet with lots of seismic and volcanic activity."
	color = COLOR_ORANGE

	/*
	planet_ztraits = list(
		ZTRAIT_ASHSTORM = TRUE,
		ZTRAIT_LAVA_RUINS = TRUE,
		ZTRAIT_BASETURF = /turf/open/lava/smooth/lava_land_surface,
	)

	ruin_type = ZTRAIT_LAVA_RUINS
	planet_area = /area/lavaland/surface
	surface = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	mapgen = /datum/map_generator/cave_generator/lavaland

	area_name = "\improper Volcanic Planetoid"
	sound_environment = SOUND_AREA_LAVALAND
	*/

/datum/overmap/planet/ice
	name = "strange ice planet"
	desc = "A very weak energy signal originating from a planet with traces of water and extremely low temperatures."
	color = COLOR_BLUE_LIGHT

	/*

	planet_ztraits = list(
		//VOID TODO weather type
		ZTRAIT_ICE_RUINS = TRUE,
		ZTRAIT_BASETURF = /turf/open/floor/plating/asteroid/snow/icemoon,
	)

	planet_area = /area/icemoon/surface
	ruin_type = ZTRAIT_ICE_RUINS
	mapgen = /datum/map_generator/cave_generator/icemoon
	surface = /turf/open/floor/plating/asteroid/snow/icemoon

	area_name = "\improper Frozen Planetoid"
	sound_environment = SOUND_AREA_ICEMOON
	ambientsounds = AMBIENCE_SPOOKY
	*/

/datum/overmap/planet/sand
	name = "strange sand planet"
	desc = "A very weak energy signal originating from a planet with many traces of silica."
	color = COLOR_GRAY

	/*
	planet_ztraits = list(
		//VOID TODO Weather type
		ZTRAIT_SAND_RUINS = TRUE,
		ZTRAIT_BASETURF = /turf/open/floor/plating/asteroid/whitesands,
	)

	planet_area = /area/planet/whitesands
	ruin_type = ZTRAIT_SAND_RUINS
	mapgen = /datum/map_generator/cave_generator/whitesands
	surface = /turf/open/floor/plating/asteroid/whitesands

	area_name = "\improper Sandy Planetoid"
	sound_environment = SOUND_ENVIRONMENT_QUARRY
	*/

/datum/overmap/planet/jungle
	name = "strange jungle planet"
	desc = "A very weak energy signal originating from a planet teeming with life."
	color = COLOR_LIME

	/*
	planet_ztraits = list(
		//VOID TODO WEATHER
		ZTRAIT_JUNGLE_RUINS = TRUE,
		ZTRAIT_BASETURF = /turf/open/floor/plating/dirt,
	)

	planet_area = /area/planet/jungle
	ruin_type = ZTRAIT_JUNGLE_RUINS
	mapgen = /datum/map_generator/jungle_generator
	surface = /turf/open/floor/plating/dirt/jungle

	area_name = "\improper Jungle Planetoid"
	sound_environment = SOUND_ENVIRONMENT_FOREST
	ambientsounds = AMBIENCE_AWAY
	*/

/datum/overmap/planet/rock
	name = "strange rock planet"
	desc = "A very weak energy signal originating from a abandoned industrial planet."
	color = COLOR_BROWN

	/*
	planet_ztraits = list(
		//VOID TODO WEATHER
		ZTRAIT_ROCK_RUINS = TRUE,
		ZTRAIT_BASETURF = /turf/open/floor/plating/asteroid
	)

	planet_area = /area/planet/rock
	ruin_type = ZTRAIT_ROCK_RUINS
	mapgen = /datum/map_generator/cave_generator/rockplanet
	surface = /turf/open/floor/plating/asteroid

	sound_environment = SOUND_ENVIRONMENT_HANGAR
	ambientsounds = AMBIENCE_MAINT
	*/
