/datum/mapGeneratorModule/bottomLayer/desertTurfs
	spawnableTurfs = list(/turf/open/floor/plating/desert = 100)

/datum/mapGeneratorModule/bottomLayer/desertWalls
	spawnableTurfs = list(/turf/closed/mineral = 100)

/datum/mapGeneratorModule/border/desertWalls
	spawnableAtoms = list()
	spawnableTurfs = list(/turf/closed/indestructible/rock = 100)

/datum/mapGeneratorModule/splatterLayer/desertWalls
	clusterCheckFlags = CLUSTER_CHECK_NONE
	spawnableAtoms = list()
	spawnableTurfs = list(/turf/closed/mineral = 10)

/datum/mapGeneratorModule/randRocks
	spawnableAtoms = list(/obj/structure/flora/rock = 40)

/datum/mapGeneratorModule/randRifles
	spawnableAtoms = list(/obj/item/gun/ballistic/shotgun/boltaction/enchanted = 0.1)

/datum/mapGeneratorModule/randAmmo
	spawnableAtoms = list(/obj/item/storage/box/lethalshot = 2,
		/obj/item/ammo_casing/shotgun/frag12 = 1,
		/obj/item/ammo_casing/shotgun/dart/bioterror = 1
		)

/datum/mapGeneratorModule/randSupplies
	spawnableAtoms = list(/obj/item/storage/firstaid/ancient = 0.5,
		/obj/item/stack/medical/bruise_pack = 1,
		/obj/item/stack/medical/ointment = 1
		)

/datum/mapGeneratorModule/randSpawners
	spawnableAtoms = list(/obj/effect/mob_spawn/human/desertsurvivalist = 1)


// GENERATORS

/datum/mapGenerator/desert/
	modules = list(/datum/mapGeneratorModule/bottomLayer/desertTurfs, \
		/datum/mapGeneratorModule/border/desertWalls,
		/datum/mapGeneratorModule/randRocks,
		/datum/mapGeneratorModule/randSpawners,
		/datum/mapGeneratorModule/randSupplies,
		/datum/mapGeneratorModule/randAmmo,
		/datum/mapGeneratorModule/randRifles
		)
	buildmode_name = "Pattern: desert \[AIRLESS!\]"

/obj/effect/landmark/mapGenerator/desertarena
	mapGeneratorType = /datum/mapGenerator/desert
	endTurfX = 50
	endTurfY = 50
	startTurfX = 1
	startTurfY = 1