/// Designates the atom as a "point of interest", meaning it can be directly orbited
/datum/element/point_of_interest
	element_flags = ELEMENT_DETACH

/datum/element/point_of_interest/Attach(datum/target)
	if (!isatom(target))
		return ELEMENT_INCOMPATIBLE

	// Do not ever attach to players in the lobby.
	if(isnewplayer(target))
		return ELEMENT_INCOMPATIBLE

	// Do not ever attach to stealthmins. This is not perfect, as mobs can ascend to stealthmin status later.
	// SSpois steps in at that point to make sure the stealthmin is not considered a POI.
	if(ismob(target))
		var/mob/target_mob = target
		if(target_mob.client?.holder?.fakekey)
			return ELEMENT_INCOMPATIBLE

	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_POI_ELEMENT_ADDED, target)
	return ..()

/datum/element/point_of_interest/Detach(datum/target)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_POI_ELEMENT_REMOVED, target)
	return ..()
