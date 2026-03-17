/**
 * The boulder machines take in many types of chems, but should only ever eject "waste" chems, 
 */
/datum/component/plumbing/boulder_reactions
	demand_connects = NORTH
	supply_connects = SOUTH

/datum/component/plumbing/reaction_chamber/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/bouldertech))
		return COMPONENT_INCOMPATIBLE
	return ..()


