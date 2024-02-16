
/datum/map_generator_module/bottom_layer/lavaland_default
	spawnableTurfs = list(/turf/open/misc/asteroid/basalt/lava_land_surface = 100)

/datum/map_generator_module/bottom_layer/lavaland_mineral
	spawnableTurfs = list(/turf/closed/mineral/volcanic = 100)

/datum/map_generator_module/bottom_layer/lavaland_mineral/dense
	spawnableTurfs = list(/turf/closed/mineral/volcanic = 100)

/datum/map_generator_module/splatter_layer/lavaland_monsters
	spawnableTurfs = list()
	spawnableAtoms = list(
		/obj/effect/spawner/random/lavaland_mob/goliath = 10,
		/obj/effect/spawner/random/lavaland_mob/legion = 10,
		/obj/effect/spawner/random/lavaland_mob/watcher = 10,
	)

/datum/map_generator_module/splatter_layer/lavaland_tendrils
	spawnableTurfs = list()
	spawnableAtoms = list(/obj/structure/spawner/lavaland = 5,
	/obj/structure/spawner/lavaland/legion = 5,
	/obj/structure/spawner/lavaland/goliath = 5)

/datum/map_generator/lavaland/ground_only
	modules = list(/datum/map_generator_module/bottom_layer/lavaland_default)
	buildmode_name = "Block: Lavaland Floor"

/datum/map_generator/lavaland/dense_ores
	modules = list(/datum/map_generator_module/bottom_layer/lavaland_mineral/dense)
	buildmode_name = "Block: Lavaland Ores: Dense"

/datum/map_generator/lavaland/normal_ores
	modules = list(/datum/map_generator_module/bottom_layer/lavaland_mineral)
	buildmode_name = "Block: Lavaland Ores"
