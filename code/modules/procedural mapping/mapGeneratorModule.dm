
#define CLUSTER_CHECK_NONE	0 //No checks are done, cluster as much as possible
#define CLUSTER_CHECK_ATOMS	2 //Don't let atoms cluster, based on clusterMin and clusterMax as guides
#define CLUSTER_CHECK_TURFS	4 //Don't let turfs cluster, based on clusterMin and clusterMax as guides
#define CLUSTER_CHECK_ALL	6 //Don't let anything cluster, based on clusterMind and clusterMax as guides

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
		if(clusterCheckFlags & CLUSTER_CHECK_TURFS)
			if(clusterMax && clusterMin)
				clustering = rand(clusterMin,clusterMax)
				if(locate(/atom/movable) in range(clustering, T))
					continue
		if(prob(spawnableTurfs[turfPath]))
			T.ChangeTurf(turfPath)

	//Atoms DO care whether atoms can be placed here
	if(checkPlaceAtom(T))
		for(var/atomPath in spawnableAtoms)
			if(clusterCheckFlags & CLUSTER_CHECK_ATOMS)
				if(clusterMax && clusterMin)
					clustering = rand(clusterMin,clusterMax)
					if(locate(/atom/movable) in range(clustering, T))
						continue
			if(prob(spawnableAtoms[atomPath]))
				new atomPath (T)

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