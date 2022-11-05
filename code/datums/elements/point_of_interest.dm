/// Designates the atom as a "point of interest", meaning it can be directly orbited
/datum/element/point_of_interest
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/point_of_interest/Attach(datum/target)
	if (!isatom(target))
		return ELEMENT_INCOMPATIBLE

	// New players are abstract mobs assigned to people who are still in the lobby screen.
	// As a result, they are not a valid POI and should never be a valid POI. If they
	// somehow get this element attached to them, there's something we need to debug.
	if(isnewplayer(target))
		return ELEMENT_INCOMPATIBLE

	SSpoints_of_interest.on_poi_element_added(target)
	return ..()

/datum/element/point_of_interest/Detach(datum/target)
	SSpoints_of_interest.on_poi_element_removed(target)
	return ..()
