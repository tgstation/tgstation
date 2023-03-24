/datum/map_generator_module/bottom_layer/cult_floor
	spawnableTurfs = list(/turf/open/floor/engine/cult = 100)

/datum/map_generator_module/border/cult_walls
	spawnableTurfs = list(/turf/closed/wall/mineral/cult = 100)

/datum/map_generator/cult //walls and floor only
	modules = list(/datum/map_generator_module/bottom_layer/cult_floor, \
		/datum/map_generator_module/border/cult_walls, \
		/datum/map_generator_module/bottom_layer/repressurize)
	buildmode_name = "Pattern: Cult Room"

/datum/map_generator/cult/floor //floors only
	modules = list(/datum/map_generator_module/bottom_layer/cult_floor, \
		/datum/map_generator_module/bottom_layer/repressurize)
	buildmode_name = "Block: Cult Floor"

/datum/map_generator/clock //walls and floor only
	modules = list(/datum/map_generator_module/bottom_layer/clockFloor, \
		/datum/map_generator_module/border/clockWalls, \
		/datum/map_generator_module/bottom_layer/repressurize)
	buildmode_name = "Pattern: Clockwork Room"

/datum/map_generator/clock/floor //floor only
	modules = list(/datum/map_generator_module/bottom_layer/clockFloor, \
		/datum/map_generator_module/bottom_layer/repressurize)
	buildmode_name = "Block: Clockwork Floor"

/datum/map_generator_module/bottom_layer/clockFloor
	spawnableTurfs = list(/turf/open/floor/clockwork = 100)

/datum/map_generator_module/border/clockWalls
	spawnableTurfs = list(/turf/closed/wall/clockwork = 100)
