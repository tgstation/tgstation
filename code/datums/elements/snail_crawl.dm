/datum/element/snailcrawl
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/snailcrawl/Attach(datum/target)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE
	var/P
	if(iscarbon(target))
		P = PROC_REF(snail_crawl)
	else
		P = PROC_REF(lubricate)
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, P)

/datum/element/snailcrawl/Detach(mob/living/carbon/target)
	. = ..()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	if(istype(target))
		target.remove_movespeed_modifier(/datum/movespeed_modifier/snail_crawl)

/datum/element/snailcrawl/proc/snail_crawl(mob/living/carbon/snail)
	SIGNAL_HANDLER

	if(snail.resting && !snail.buckled && lubricate(snail))
		snail.add_movespeed_modifier(/datum/movespeed_modifier/snail_crawl)
	else
		snail.remove_movespeed_modifier(/datum/movespeed_modifier/snail_crawl)

/datum/element/snailcrawl/proc/lubricate(atom/movable/snail)
	SIGNAL_HANDLER

	var/turf/open/OT = get_turf(snail)
	if(istype(OT))
		OT.MakeSlippery(TURF_WET_LUBE, 20)
		return TRUE
