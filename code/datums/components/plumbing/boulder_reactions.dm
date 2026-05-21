/**
 * The boulder machines take in many types of chems, but should only ever eject "waste" chems,
 */
/datum/component/plumbing/boulder_reactions
	demand_connects = NORTH
	supply_connects = SOUTH
	supply_offset = 4
	demand_offset = 4

/datum/component/plumbing/boulder_reactions/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/bouldertech/refinery))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/boulder_reactions/can_give(amount, reagent, datum/ductnet/net)
	if(amount <= 0 || !reagents.total_volume || !reagent)
		return FALSE

	var/obj/machinery/bouldertech/refinery/the_refinery = parent
	var/list/datum/reagents/boosters = the_refinery.booster_list

	if(istype(amount, the_refinery.waste_chemical))
		return TRUE //Always allow waste chemicals to leave.

	if(!length(boosters))
		return ..()
	for(var/datum/chem as anything in boosters)
		if(chem.type == reagent) // Need to check strict subtype since most acids are subtypes of eachother.
			return FALSE
	return ..()
