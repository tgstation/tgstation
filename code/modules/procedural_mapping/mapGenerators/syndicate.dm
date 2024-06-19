
// Modules

/datum/map_generator_module/bottom_layer/syndie_floor
	spawnableTurfs = list(/turf/open/floor/mineral/plastitanium/red = 100)

/datum/map_generator_module/border/syndie_walls
	spawnableAtoms = list()
	spawnableTurfs = list(/turf/closed/wall/r_wall/syndicate = 100)


/datum/map_generator_module/syndie_furniture
	clusterCheckFlags = CLUSTER_CHECK_ALL
	spawnableTurfs = list()
	spawnableAtoms = list(/obj/structure/table = 20,/obj/structure/chair = 15,/obj/structure/chair/stool = 10, \
		/obj/structure/frame/computer = 15, /obj/item/storage/toolbox/syndicate = 15 ,\
		/obj/structure/closet/syndicate = 25, /obj/machinery/suit_storage_unit/syndicate = 15)

/datum/map_generator_module/splatter_layer/syndie_mobs
	spawnableAtoms = list(
		/mob/living/basic/trooper/syndicate = 30,
		/mob/living/basic/trooper/syndicate/melee = 20,
		/mob/living/basic/trooper/syndicate/ranged = 20,
		/mob/living/basic/viscerator = 30
	)
	spawnableTurfs = list()

// Generators

/datum/map_generator/syndicate/empty //walls and floor only
	modules = list(/datum/map_generator_module/bottom_layer/syndie_floor, \
		/datum/map_generator_module/border/syndie_walls,\
		/datum/map_generator_module/bottom_layer/repressurize)
	buildmode_name = "Pattern: Shuttle Room: Syndicate"

/datum/map_generator/syndicate/mobsonly
	modules = list(/datum/map_generator_module/bottom_layer/syndie_floor, \
		/datum/map_generator_module/border/syndie_walls,\
		/datum/map_generator_module/splatter_layer/syndie_mobs, \
		/datum/map_generator_module/bottom_layer/repressurize)
	buildmode_name = "Pattern: Shuttle Room: Syndicate: Mobs"

/datum/map_generator/syndicate/furniture
	modules = list(/datum/map_generator_module/bottom_layer/syndie_floor, \
		/datum/map_generator_module/border/syndie_walls,\
		/datum/map_generator_module/syndie_furniture, \
		/datum/map_generator_module/bottom_layer/repressurize)
	buildmode_name = "Pattern: Shuttle Room: Syndicate: Furniture"

/datum/map_generator/syndicate/full
	modules = list(/datum/map_generator_module/bottom_layer/syndie_floor, \
		/datum/map_generator_module/border/syndie_walls,\
		/datum/map_generator_module/syndie_furniture, \
		/datum/map_generator_module/splatter_layer/syndie_mobs, \
		/datum/map_generator_module/bottom_layer/repressurize)
	buildmode_name = "Pattern: Shuttle Room: Syndicate: All"
