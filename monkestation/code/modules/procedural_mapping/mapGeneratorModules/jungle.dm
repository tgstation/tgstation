//Jungle Map Generation
//Whoa, thought it was a nightmare. Lord, it's all so true.

/datum/mapGeneratorModule/bottomLayer/jungle_underbrush
	spawnableTurfs = list(/turf/open/floor/grass = 100)

/datum/mapGeneratorModule/jungle_trees
	spawnableAtoms = list(/obj/structure/flora/tree/jungle = 5,
							/obj/structure/flora/tree/jungle/small = 25)

/datum/mapGeneratorModule/jungle_shrubs
	clusterCheckFlags = CLUSTER_CHECK_NONE
	spawnableAtoms = list(/obj/structure/flora/junglebush = 20,
							/obj/structure/flora/junglebush/large = 10)

/datum/mapGeneratorModule/jungle_rocks
	clusterCheckFlags = CLUSTER_CHECK_SAME_ATOMS
	spawnableAtoms = list(/obj/structure/flora/rock/jungle = 25,
							/obj/structure/flora/rock/pile/largejungle = 10)

/datum/mapGeneratorModule/jungle_water
	clusterCheckFlags = CLUSTER_CHECK_NONE
	spawnableTurfs = list(/turf/open/water/jungle = 10)

/datum/mapGeneratorModule/bottomLayer/jungle_dirt
	spawnableTurfs = list(/turf/open/floor/plating/dirt/jungle = 2,
							/turf/open/floor/plating/dirt/jungle/dark = 2,
							/turf/open/floor/plating/dirt/jungle/wasteland = 2,
							/turf/open/floor/plating/grass/jungle = 2)

