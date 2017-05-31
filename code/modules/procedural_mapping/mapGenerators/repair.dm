/datum/mapGeneratorModule/bottomLayer/repairFloorPlasteel
	spawnableTurfs = list(/turf/open/floor/plasteel = 100)
	var/ignore_wall = FALSE

/datum/mapGeneratorModule/bottomLayer/repairFloorPlasteel/place(turf/T)
	if(isclosedturf(T))
		return FALSE
	return TRUE

/datum/mapGeneratorModule/bottomLayer/repairFloorPlasteel/flatten
	ignore_wall = TRUE

/datum/mapGeneratorModule/border/normalWalls
	spawnableAtoms = list()
	spawnableTurfs = list(/turf/closed/wall = 100)

/datum/mapGenerator/repair
	modules = list(/datum/mapGeneratorModule/bottomLayer/repairFloorPlasteel,
	/datum/mapGeneratorModule/bottomLayer/repressurize)

/datum/mapGenerator/repair/delete_walls
	modules = list(/datum/mapGeneratorModule/bottomLayer/repairFloorPlasteel/flatten,
	/datum/mapGeneratorModule/bottomLayer/repressurize)

/datum/mapGenerator/repair/enclose_room
	modules = list(/datum/mapGeneratorModule/bottomLayer/repairFloorPlasteel/flatten,
	/datum/mapGeneratorModule/border/normalWalls,
	/datum/mapGeneratorModule/bottomLayer/repressurize)

