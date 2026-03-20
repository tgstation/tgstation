/**
 * The boulder machines take in many types of chems, but should only ever eject "waste" chems,
 */
/datum/component/plumbing/boulder_reactions
	demand_connects = NORTH
	supply_connects = SOUTH

/datum/component/plumbing/reaction_chamber/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/bouldertech/refinery))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/reaction_chamber/can_give(amount, reagent, datum/ductnet/net)
	if(amount <= 0 || !reagents.total_volume)
		return

	var/obj/machinery/bouldertech/refinery/the_refinery = parent
	var/list/datum/reagents/boosters = the_refinery.booster_list

	if(boosters[reagent]) //We don't want to toss out boosting reagents in case we want to use them for actually boosting the machine.
		return FALSE

	return ..()


