//Helper procs for witches.

//To check if a mind is a witch. Standard syntax should be "is_witch([mind])".
//Example: is_witch(H) to check if H, a mind, is a witch.
/proc/is_witch(var/datum/mind/M)
	if(!M || !istype(M) || !M.witch)
		return 0
	return 1

//To check the elemental affinity of a mind. Standard syntax should be "get_affinity([mind], [define of affinity - check witch_datum.dm])".
//Example: get_affinity(X, AFFINITY_WATER) to check if X, a mind, is attuned to water.
/proc/check_affinity(var/datum/mind/M, var/req_affinity)
	if(!M || !istype(M) || !M.witch)
		return 0
	var/datum/witch/W = M.witch
	if(W.affinity == req_affinity)
		return 1
	return 0

//To make a mob or mind into a witch. Standard syntax should be "make_witch([mind])".
//Example: make_witch(A) to make A, a mind, into a witch.
/proc/make_witch(var/datum/mind/M)
	if(is_witch(M))
		return 0
	var/datum/witch/W = new (null)
	M.witch = W
	W.witch_mob = M.current
	return 1

//To change a witch's affinity. Standard syntax should be "adjust_affinity([mind], [define of affinity])". Providing no affinity will reset the existing affinity.
//Example: adjust_affinity(M, AFFINITY_EARTH) to attune M, a mind, to earth; adjust_affinity(H) to reset H's affinity (H being a mind).
/proc/adjust_affinity(var/datum/mind/M, var/new_affinity = null)
	if(!is_witch(M))
		return 0
	var/datum/witch/W = M.witch
	if(!new_affinity || (new_affinity < 0 || new_affinity > 5))
		W.affinity = 0
	else
		W.affinity = new_affinity
