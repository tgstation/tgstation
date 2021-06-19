/datum/map_generator_module/bottom_layer/shuttle_floor
	spawnableTurfs = list(/turf/open/floor/iron/shuttle = 100)

/datum/map_generator_module/border/shuttle_walls
	spawnableAtoms = list()
	spawnableTurfs = list(/turf/closed/wall/mineral/titanium = 100)
// Generators

/datum/map_generator/shuttle/full
	modules = list(/datum/map_generator_module/bottom_layer/shuttle_floor, \
		/datum/map_generator_module/border/shuttle_walls,\
		/datum/map_generator_module/bottom_layer/repressurize)
	buildmode_name = "Pattern: Shuttle Room"

/datum/map_generator/shuttle/floor
	modules = list(/datum/map_generator_module/bottom_layer/shuttle_floor)
	buildmode_name = "Block: Shuttle Floor"
