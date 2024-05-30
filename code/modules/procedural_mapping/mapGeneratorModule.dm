
/datum/map_generator_module
	var/datum/map_generator/mother = null
	var/list/spawnableAtoms = list()
	var/list/spawnableTurfs = list()
	var/clusterMax = 5
	var/clusterMin = 1
	var/clusterCheckFlags = CLUSTER_CHECK_SAME_ATOMS
	var/allowAtomsOnSpace = FALSE

/datum/map_generator_module/Destroy(force)
	mother = null
	return ..()

//Syncs the module up with its mother
/datum/map_generator_module/proc/sync(datum/map_generator/mum)
	mother = null
	if(mum)
		mother = mum


//Generates its spawnable atoms and turfs
/datum/map_generator_module/proc/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/T in map)
		place(T)


//Place a spawnable atom or turf on this turf
/datum/map_generator_module/proc/place(turf/T)
	if(!T)
		return 0

	var/clustering = 0
	var/skipLoopIteration = FALSE

	//Turfs don't care whether atoms can be placed here
	for(var/turfPath in spawnableTurfs)

		//Clustering!
		if(clusterMax && clusterMin)

			//You're the same as me? I hate you I'm going home
			if(clusterCheckFlags & CLUSTER_CHECK_SAME_TURFS)
				clustering = rand(clusterMin,clusterMax)
				for(var/turf/F in RANGE_TURFS(clustering,T))
					if(istype(F,turfPath))
						skipLoopIteration = TRUE
						break
				if(skipLoopIteration)
					skipLoopIteration = FALSE
					continue

			//You're DIFFERENT to me? I hate you I'm going home
			if(clusterCheckFlags & CLUSTER_CHECK_DIFFERENT_TURFS)
				clustering = rand(clusterMin,clusterMax)
				for(var/turf/F in RANGE_TURFS(clustering,T))
					if(!(istype(F,turfPath)))
						skipLoopIteration = TRUE
						break
				if(skipLoopIteration)
					skipLoopIteration = FALSE
					continue

		//Success!
		if(prob(spawnableTurfs[turfPath]))
			T.ChangeTurf(turfPath)


	//Atoms DO care whether atoms can be placed here
	if(checkPlaceAtom(T))

		for(var/atomPath in spawnableAtoms)

			//Clustering!
			if(clusterMax && clusterMin)

				//You're the same as me? I hate you I'm going home
				if(clusterCheckFlags & CLUSTER_CHECK_SAME_ATOMS)
					clustering = rand(clusterMin, clusterMax)
					for(var/atom/movable/M in range(clustering,T))
						if(istype(M,atomPath))
							skipLoopIteration = TRUE
							break
					if(skipLoopIteration)
						skipLoopIteration = FALSE
						continue

				//You're DIFFERENT from me? I hate you I'm going home
				if(clusterCheckFlags & CLUSTER_CHECK_DIFFERENT_ATOMS)
					clustering = rand(clusterMin, clusterMax)
					for(var/atom/movable/M in range(clustering,T))
						if(!(istype(M,atomPath)))
							skipLoopIteration = TRUE
							break
					if(skipLoopIteration)
						skipLoopIteration = FALSE
						continue

			//Success!
			if(prob(spawnableAtoms[atomPath]))
				new atomPath(T)

	. = 1


//Checks and Rejects dense turfs
/datum/map_generator_module/proc/checkPlaceAtom(turf/T)
	if(!T || (T.turf_flags & TURF_BLOCKS_POPULATE_TERRAIN_FLORAFEATURES))
		return FALSE
	if(T.density)
		return FALSE
	for(var/atom/A in T)
		if(A.density)
			return FALSE
	if(!allowAtomsOnSpace && (isspaceturf(T)))
		return FALSE
	return TRUE


///////////////////////////////////////////////////////////
//                 PREMADE BASE TEMPLATES                //
//           Appropriate settings for usable types       //
// Not usable types themselves, use them as parent types //
// Seriously, don't use these on their own, just parents //
///////////////////////////////////////////////////////////
//The /atom and /turf examples are just so these compile, replace those with your typepaths in your subtypes.

//Settings appropriate for a turf that covers the entire map region, eg a fill colour on a bottom layer in a graphics program.
//Should only have one of these in your mapGenerator unless you want to waste CPU
/datum/map_generator_module/bottom_layer
	clusterCheckFlags = CLUSTER_CHECK_NONE
	spawnableAtoms = list()//Recommended: No atoms.
	spawnableTurfs = list(/turf = 100)

//Settings appropriate for turfs/atoms that cover SOME of the map region, sometimes referred to as a splatter layer.
/datum/map_generator_module/splatter_layer
	clusterCheckFlags = CLUSTER_CHECK_ALL
	spawnableAtoms = list(/atom = 30)
	spawnableTurfs = list(/turf = 30)

//Settings appropriate for turfs/atoms that cover a lot of the map region, eg a dense forest.
/datum/map_generator_module/dense_layer
	clusterCheckFlags = CLUSTER_CHECK_NONE
	spawnableAtoms = list(/atom = 75)
	spawnableTurfs = list(/turf = 75)
