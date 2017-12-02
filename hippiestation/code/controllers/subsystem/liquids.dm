PROCESSING_SUBSYSTEM_DEF(liquids)
	name = "Liquids"
	wait = 1
	priority = 15
	stat_tag = "L"

/datum/controller/subsystem/processing/liquids/fire(resumed = 0)
	..()
	if(currentrun)
		for(var/I in currentrun)
			var/datum/liquid_pool/P = I
			if(!P.liquids)
				qdel(P)
			else if(!LAZYLEN(P.liquids))
				qdel(P)
