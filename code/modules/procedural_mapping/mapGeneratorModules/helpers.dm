//Helper Modules


// Helper to repressurize the area in case it was run in space
/datum/map_generator_module/bottom_layer/repressurize
	spawnableAtoms = list()
	spawnableTurfs = list()

/datum/map_generator_module/bottom_layer/repressurize/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/T in map)
		SSair.remove_from_active(T)
	for(var/turf/open/T in map)
		if(T.air)
			T.air.copy_from_turf(T)
		SSair.add_to_active(T, TRUE)

/datum/map_generator_module/bottom_layer/massdelete
	spawnableAtoms = list()
	spawnableTurfs = list()
	var/deleteturfs = TRUE //separate var for the empty type.
	var/list/ignore_typecache

/datum/map_generator_module/bottom_layer/massdelete/generate()
	if(!mother)
		return
	for(var/V in mother.map)
		var/turf/T = V
		T.empty(deleteturfs? null : T.type, null, ignore_typecache, CHANGETURF_FORCEOP)

/datum/map_generator_module/bottom_layer/massdelete/no_delete_mobs/New()
	..()
	ignore_typecache = GLOB.typecache_mob

/datum/map_generator_module/bottom_layer/massdelete/leave_turfs
	deleteturfs = FALSE

/datum/map_generator_module/bottom_layer/massdelete/regeneration_delete
	deleteturfs = FALSE

/datum/map_generator_module/bottom_layer/massdelete/regeneration_delete/New()
	..()
	ignore_typecache = GLOB.typecache_mob

//Only places atoms/turfs on area borders
/datum/map_generator_module/border
	clusterCheckFlags = CLUSTER_CHECK_NONE

/datum/map_generator_module/border/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/T in map)
		if(is_border(T))
			place(T)

/datum/map_generator_module/border/proc/is_border(turf/T)
	for(var/direction in list(SOUTH,EAST,WEST,NORTH))
		if (get_step(T,direction) in mother.map)
			continue
		return 1
	return 0

/datum/map_generator/repressurize
	modules = list(/datum/map_generator_module/bottom_layer/repressurize)
	buildmode_name = "Block: Restore Roundstart Air Contents"

/datum/map_generator/massdelete
	modules = list(/datum/map_generator_module/bottom_layer/massdelete)
	buildmode_name = "Block: Full Mass Deletion"

/datum/map_generator/massdelete/nomob
	modules = list(/datum/map_generator_module/bottom_layer/massdelete/no_delete_mobs)
	buildmode_name = "Block: Mass Deletion - Leave Mobs"

/datum/map_generator/massdelete/noturf
	modules = list(/datum/map_generator_module/bottom_layer/massdelete/leave_turfs)
	buildmode_name = "Block: Mass Deletion - Leave Turfs"

/datum/map_generator/massdelete/regen
	modules = list(/datum/map_generator_module/bottom_layer/massdelete/regeneration_delete)
	buildmode_name = "Block: Mass Deletion - Leave Mobs and Turfs"
