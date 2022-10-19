
//Contents exist primarily for the nature generator test type.


//Pine Trees
/datum/map_generator_module/pine_trees
	spawnableAtoms = list(/obj/structure/flora/tree/pine/style_random = 30)

//Dead Trees
/datum/map_generator_module/dead_trees
	spawnableAtoms = list(/obj/structure/flora/tree/dead/style_random = 10)

//Random assortment of bushes
/datum/map_generator_module/rand_bushes
	spawnableAtoms = list()

/datum/map_generator_module/rand_bushes/New()
	..()
	spawnableAtoms = typesof(/obj/structure/flora/bush) - typesof(/obj/structure/flora/bush/snow)
	for(var/i in spawnableAtoms)
		spawnableAtoms[i] = 20


//Random assortment of rocks and rockpiles
/datum/map_generator_module/rand_rocks
	spawnableAtoms = list(/obj/structure/flora/rock/style_random = 40, /obj/structure/flora/rock/pile/style_random = 20)


//Grass turfs
/datum/map_generator_module/bottom_layer/grass_turfs
	spawnableTurfs = list(/turf/open/floor/grass = 100)


//Grass tufts with a high spawn chance
/datum/map_generator_module/dense_layer/grass_tufts
	spawnableTurfs = list()
	spawnableAtoms = list(/obj/structure/flora/bush/grassy/style_random = 75)
