/datum/proc/add_trait(trait, source)
	if(isnull(status_traits))
		status_traits = list()
		
	if(!status_traits[trait])
		status_traits[trait] = list(source)
	else
		status_traits[trait] |= list(source)
		

/datum/proc/remove_trait(trait, list/sources, force)
	if(isnull(status_traits))
		status_traits = list()
		return //nothing to remove anyway
		
	if(!status_traits[trait])
		return

	if(locate(ROUNDSTART_TRAIT) in status_traits[trait] && !force) //mob traits applied through roundstart cannot normally be removed
		return

	if(!sources) // No defined source cures the trait entirely.
		status_traits -= trait
		return

	if(!islist(sources))
		sources = list(sources)

	if(LAZYLEN(sources))
		for(var/S in sources)
			if(S in status_traits[trait])
				status_traits[trait] -= S
	else
		status_traits[trait] = list()

	if(!LAZYLEN(status_traits[trait]))
		status_traits -= trait
		
/datum/proc/has_trait(trait, list/sources)
	if(isnull(status_traits))
		status_traits = list()
		return FALSE //well of course it doesn't have the trait
		
	if(!status_traits[trait])
		return FALSE

	. = FALSE

	if(sources && !islist(sources))
		sources = list(sources)
	if(LAZYLEN(sources))
		for(var/S in sources)
			if(S in status_traits[trait])
				return TRUE
	else if(LAZYLEN(status_traits[trait]))
		return TRUE
		
/datum/proc/remove_all_traits(remove_species_traits = FALSE, remove_organ_traits = FALSE, remove_quirks = FALSE)
	if(isnull(status_traits))
		status_traits = list()
		return //nothing to remove anyway
		
	var/list/blacklisted_sources = list()
	if(!remove_species_traits)
		blacklisted_sources += SPECIES_TRAIT
	if(!remove_organ_traits)
		blacklisted_sources += ORGAN_TRAIT
	if(!remove_quirks)
		blacklisted_sources += ROUNDSTART_TRAIT

	for(var/kebab in status_traits)
		var/skip
		for(var/S in blacklisted_sources)
			if(S in status_traits[kebab])
				skip = TRUE
				break
		if(!skip)
			remove_trait(kebab, null, TRUE)
		CHECK_TICK