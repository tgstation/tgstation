
//Exists primarily as a test type.

/datum/map_generator/nature
	modules = list(/datum/map_generator_module/bottom_layer/grass_turfs, \
	/datum/map_generator_module/pine_trees, \
	/datum/map_generator_module/dead_trees, \
	/datum/map_generator_module/rand_bushes, \
	/datum/map_generator_module/rand_rocks, \
	/datum/map_generator_module/dense_layer/grass_tufts)
	buildmode_name = "Pattern: Nature"
