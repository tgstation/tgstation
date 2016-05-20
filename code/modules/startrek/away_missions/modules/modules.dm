

//--------------------------------
//Grassy generator, for testing.

/datum/mapGenerator/grassy
	modules = list(/datum/mapGeneratorModule/bottomLayer/grassTurfs2, \
	/datum/mapGeneratorModule/randBushes2, \
	/datum/mapGeneratorModule/randRocks2, \
	/datum/mapGeneratorModule/denseLayer/grassTufts2)


//Random assortment of bushes
/datum/mapGeneratorModule/randBushes2
	spawnableAtoms = list()

/datum/mapGeneratorModule/randBushes2/New()
	..()
	spawnableAtoms = typesof(/obj/structure/flora/ausbushes)
	for(var/i in spawnableAtoms)
		spawnableAtoms[i] = 3


//Random assortment of rocks and rockpiles
/datum/mapGeneratorModule/randRocks2
	spawnableAtoms = list(/obj/structure/flora/rock = 5, /obj/structure/flora/rock/pile = 5)

//Grass turfs
/datum/mapGeneratorModule/bottomLayer/grassTurfs2
	spawnableTurfs = list(/turf/open/floor/grass = 100) //100% chance of grass in every tile.

//Grass tufts with a high spawn chance
/datum/mapGeneratorModule/denseLayer/grassTufts2
	spawnableTurfs = list()
	spawnableAtoms = list(/obj/structure/flora/ausbushes/grassybush = 5)

//--------------------------------

//--------------------------------
//Desert generator, for testing.

/datum/mapGenerator/desert
	modules = list(/datum/mapGeneratorModule/bottomLayer/sand_floor, \
	/datum/mapGeneratorModule/randBushes_desert, \
	/datum/mapGeneratorModule/randRocks_desert, \
	/datum/mapGeneratorModule/desert_lizards )


//Random assortment of bushes
/datum/mapGeneratorModule/randBushes_desert
	spawnableAtoms = list()

/datum/mapGeneratorModule/randBushes_desert/New()
	..()
	spawnableAtoms = typesof(/obj/structure/flora/ausbushes)
	for(var/i in spawnableAtoms)
		spawnableAtoms[i] = 1


//Random assortment of rocks and rockpiles
/datum/mapGeneratorModule/randRocks_desert
	spawnableAtoms = list(/obj/structure/flora/rock = 2, /obj/structure/flora/rock/pile = 3)

//Sand turfs
/datum/mapGeneratorModule/bottomLayer/sand_floor
	spawnableTurfs = list(/turf/open/floor/plating/beach/sand = 100) //100% chance of beach sand in every tile.

/datum/mapGeneratorModule/desert_lizards
	spawnableAtoms = list(/mob/living/simple_animal/hostile/lizard = 2)



//--------------------------------