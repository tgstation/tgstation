/datum/component/snailcrawl
	var/mob/living/carbon/snail

/datum/component/snailcrawl/Initialize()
	RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), .proc/lubricate)
	snail = parent

/datum/component/snailcrawl/proc/lubricate()
	if(snail.resting) //s l i d e
		var/turf/open/OT = get_turf(snail)
		if(isopenturf(OT))
			OT.MakeSlippery(TURF_WET_LUBE, 20)
		snail.add_movespeed_modifier(MOVESPEED_ID_SNAIL_CRAWL, update=TRUE, priority=100, multiplicative_slowdown=-7, movetypes=GROUND)
	else
		snail.remove_movespeed_modifier(MOVESPEED_ID_SNAIL_CRAWL)

/datum/component/snailcrawl/_RemoveFromParent()
	snail.remove_movespeed_modifier(MOVESPEED_ID_SNAIL_CRAWL)
	return ..()