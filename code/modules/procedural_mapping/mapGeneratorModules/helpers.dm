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
		SSair.remove_from_active(T)
	for(var/turf/open/T in map)
		if(T.air)
			T.air.copy_from_turf(T)
		SSair.add_to_active(T)

/datum/mapGeneratorModule/bottomLayer/massdelete
	spawnableAtoms = list()
	spawnableTurfs = list()
	var/deletemobs = TRUE
	var/deleteturfs = TRUE

/datum/mapGeneratorModule/bottomLayer/massdelete/generate()
	if(!mother)
		return
	for(var/V in mother.map)
		var/turf/T = V
		T.empty(deleteturfs? null : T.type, delmobs = deletemobs, forceop = TRUE)

/datum/mapGeneratorModule/bottomLayer/massdelete/no_delete_mobs
	deletemobs = FALSE

/datum/mapGeneratorModule/bottomLayer/massdelete/leave_turfs
	deleteturfs = FALSE

/datum/mapGeneratorModule/bottomLayer/massdelete/regeneration_delete
	deletemobs = FALSE
	deleteturfs = FALSE

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