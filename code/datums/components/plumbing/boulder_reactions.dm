/**
 * The boulder machines take in many types of chems, but should only ever eject "waste" chems,
 */
/datum/component/plumbing/boulder_reactions
	demand_connects = NORTH
	supply_connects = SOUTH

/datum/component/plumbing/boulder_reactions/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/bouldertech/refinery))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/boulder_reactions/can_give(amount, reagent, datum/ductnet/net)
	if(amount <= 0 || !reagents.total_volume || !reagent)
		return FALSE

	var/obj/machinery/bouldertech/refinery/the_refinery = parent
	var/list/datum/reagents/boosters = the_refinery.booster_list

	if(is_path_in_list(reagent, boosters))
		return FALSE

	return ..()
