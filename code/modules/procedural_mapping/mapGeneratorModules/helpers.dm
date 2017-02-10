//Helper Modules


// Helper to repressurize the area in case it was run in space
/datum/mapGeneratorModule/bottomLayer/repressurize
	spawnableAtoms = list()
	spawnableTurfs = list()

/datum/mapGeneratorModule/bottomLayer/repressurize/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/T in map)
		START_ATMOS_PROCESSING(T, SSAIR_ACTIVETURFS)
	for(var/turf/open/T in map)
		if(T.air)
			T.air.copy_from_turf(T)
		START_ATMOS_PROCESSING(T, SSAIR_ACTIVETURFS)

/datum/mapGeneratorModule/bottomLayer/massdelete
	spawnableAtoms = list()
	spawnableTurfs = list()

/datum/mapGeneratorModule/bottomLayer/massdelete/generate()
	if(!mother)
		return
	for(var/V in mother.map)
		var/turf/T = V
		T.empty()

//Only places atoms/turfs on area borders
/datum/mapGeneratorModule/border
	clusterCheckFlags = CLUSTER_CHECK_NONE

/datum/mapGeneratorModule/border/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/T in map)
		if(is_border(T))
			place(T)

/datum/mapGeneratorModule/border/proc/is_border(turf/T)
	for(var/direction in list(SOUTH,EAST,WEST,NORTH))
		if (get_step(T,direction) in mother.map)
			continue
		return 1
	return 0

/datum/mapGenerator/repressurize
	modules = list(/datum/mapGeneratorModule/bottomLayer/repressurize)

/datum/mapGenerator/massdelete
	modules = list(/datum/mapGeneratorModule/bottomLayer/massdelete)