//clusterCheckFlags defines
//All based on clusterMin and clusterMax as guides

//Individual defines
#define CLUSTER_CHECK_NONE				0  //No checks are done, cluster as much as possible
#define CLUSTER_CHECK_DIFFERENT_TURFS	2  //Don't let turfs of DIFFERENT types cluster
#define CLUSTER_CHECK_DIFFERENT_ATOMS	4  //Don't let atoms of DIFFERENT types cluster
#define CLUSTER_CHECK_SAME_TURFS		8  //Don't let turfs of the SAME type cluster
#define CLUSTER_CHECK_SAME_ATOMS		16 //Don't let atoms of the SAME type cluster

//Combined defines
#define CLUSTER_CHECK_ALL_TURFS			32 //Don't let ANY turfs cluster same and different types
#define CLUSTER_CHECK_ALL_ATOMS			64 //Don't let ANY atoms cluster same and different types

//All
#define CLUSTER_CHECK_ALL				96 //Don't let anything cluster, like, at all

/datum/mapGeneratorModule
	var/datum/mapGenerator/mother = null
	var/list/spawnableAtoms = list()
	var/list/spawnableTurfs = list()
	var/clusterMax = 5
	var/clusterMin = 1
	var/clusterCheckFlags = CLUSTER_CHECK_ALL


//Syncs the module up with it's mother
/datum/mapGeneratorModule/proc/sync(var/datum/mapGenerator/mum)
	mother = null
	if(mum)
		mother = mum


//Generates it's spawnable atoms and turfs
/datum/mapGeneratorModule/proc/generate()
	if(!mother)
		return
	var/list/map = mother.map
	for(var/turf/T in map)
		place(T)


//Place a spawnable atom or turf on this turf
/datum/mapGeneratorModule/proc/place(var/turf/T)
	if(!T)
		return 0

	var/clustering = 0

	//Turfs don't care whether atoms can be placed here
	for(var/turfPath in spawnableTurfs)

		//Clustering!
		if(clusterMax && clusterMin)

			//You're the same as me? I hate you I'm going home
			if(clusterCheckFlags & CLUSTER_CHECK_SAME_TURFS)
				clustering = rand(clusterMin,clusterMax)
				if(locate(turfPath) in trange(clustering, T))
					continue

			//You're DIFFERENT to me? I hate you I'm going home
			if(clusterCheckFlags & CLUSTER_CHECK_DIFFERENT_TURFS)
				clustering = rand(clusterMin,clusterMax)
				for(var/turf/F in trange(clustering,T))
					if(istype(F, turfPath))
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
					if(locate(atomPath) in range(clustering,T))
						continue

				//You're DIFFERENT from me? I hate you I'm going home
				if(clusterCheckFlags & CLUSTER_CHECK_DIFFERENT_ATOMS)
					clustering = rand(clusterMin, clusterMax)
					for(var/atom/movable/M in range(clustering,T))
						if(istype(M, atomPath))
							continue

	. = 1


//Checks and Rejects dense turfs
/datum/mapGeneratorModule/proc/checkPlaceAtom(var/turf/T)
	. = 1
	if(!T)
		return 0
	if(T.density)
		. = 0
	for(var/atom/A in T)
		if(A.density)
			. = 0
			break


///////////////////////////////////////////////////////////
//                 PREMADE BASE TEMPLATES                //
//           Appropriate settings for usable types       //
// Not usable types themselves, use them as parent types //
// Seriously, don't use these on their own, just parents //
///////////////////////////////////////////////////////////
//The /atom and /turf examples are just so these compile, replace those with your typepaths in your subtypes.

//Settings appropriate for a turf that covers the entire map region, eg a fill colour on a bottom layer in a graphics program.
//Should only have one of these in your mapGenerator unless you want to waste CPU
/datum/mapGeneratorModule/bottomLayer
	clusterCheckFlags = CLUSTER_CHECK_NONE
	spawnableAtoms = list()//Recommended: No atoms.
	spawnableTurfs = list(/turf = 100)

//Settings appropriate for turfs/atoms that cover SOME of the map region, sometimes referred to as a splatter layer.
/datum/mapGeneratorModule/splatterLayer
	clusterCheckFlags = CLUSTER_CHECK_ALL
	spawnableAtoms = list(/atom = 30)
	spawnableTurfs = list(/turf = 30)

//Settings appropriate for turfs/atoms that cover a lot of the map region, eg a dense forest.
/datum/mapGeneratorModule/denseLayer
	clusterCheckFlags = CLUSTER_CHECK_NONE
	spawnableAtoms = list(/atom = 75)
	spawnableTurfs = list(/turf = 75)