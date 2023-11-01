/// Returns a list of all holoparasites that has this mob as a summoner.
/mob/living/proc/get_all_linked_holoparasites()
	RETURN_TYPE(/list)
	var/list/all_parasites = list()
	for(var/mob/living/basic/guardian/stand as anything in GLOB.parasites)
		if (stand.summoner != src)
			continue
		all_parasites += stand
	return all_parasites

/// Returns true if this holoparasite has the same summoner as the passed holoparasite.
/mob/living/basic/guardian/proc/shares_summoner(mob/living/basic/guardian/other_guardian)
	return istype(other_guardian) && other_guardian.summoner == summoner
