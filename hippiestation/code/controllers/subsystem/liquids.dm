PROCESSING_SUBSYSTEM_DEF(liquids)
	name = "Liquids"
	wait = 1
	priority = 15
	stat_tag = "L"

/datum/controller/subsystem/processing/liquids/fire(resumed = 0)
	. = ..()
	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun
	while(currentrun.len)
		var/datum/liquid_pool/P = currentrun[currentrun.len]
		currentrun.len--
		if(!P.liquids)
			qdel(P)
			src.currentrun.Remove(P)
		else if(!LAZYLEN(P.liquids))
			qdel(P)
			src.currentrun.Remove(P)
