/// The boulder machines take in many types of chems, but should only ever eject "waste" chems,
/datum/component/plumbing/boulder_reactions
	demand_connects = WEST
	supply_connects = EAST

/datum/component/plumbing/boulder_reactions/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/bouldertech/refinery))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/boulder_reactions/send_request(dir)
	var/obj/machinery/bouldertech/refinery/the_refinery = parent
	var/list/datum/reagents/boosters = the_refinery.get_booster_reagents()

	for(var/datum/reagent/booster as anything in boosters)
		process_request(MACHINE_REAGENT_TRANSFER, booster, dir, TRUE)

/datum/component/plumbing/boulder_reactions/can_give(amount, reagent, datum/ductnet/net)
	if(!reagents.total_volume || amount <= 0)
		return FALSE

	var/obj/machinery/bouldertech/refinery/the_refinery = parent
	if(reagent)
		if(reagent != the_refinery.waste_chemical) //Always allow waste chemicals to enter.
			return FALSE

	return !!reagents.has_reagent(the_refinery.waste_chemical)

/datum/component/plumbing/boulder_reactions/transfer_to(datum/component/plumbing/target, amount, reagent, datum/ductnet/net, round_robin)
	var/obj/machinery/bouldertech/refinery/the_refinery = parent

	reagents.trans_to(target.recipient_reagents_holder(), amount, target_id = the_refinery.waste_chemical, methods = round_robin ? LINEAR : NONE)
