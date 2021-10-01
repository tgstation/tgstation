/// Designates the atom as a "point of interest", meaning it can be directly orbited
/datum/element/point_of_interest
	element_flags = ELEMENT_DETACH

/datum/element/point_of_interest/Attach(datum/target)
	if (!isatom(target))
		return ELEMENT_INCOMPATIBLE
	GLOB.poi_list += target
	return ..()

/datum/element/point_of_interest/Detach(datum/target)
	GLOB.poi_list -= target
	return ..()
