/datum/component/plumbing/automated_iv
	demand_connects = SOUTH
	supply_connects = NORTH
	distinct_reagent_cap = 3
	///Temporary holder to store all the reagents from the iv drip before transferring to the ducts
	var/datum/reagents/plumbing/holder

/datum/component/plumbing/automated_iv/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/iv_drip/plumbing))
		return COMPONENT_INCOMPATIBLE
	. = ..()
	var/obj/machinery/iv_drip/plumbing/drip = parent
	holder = new(drip.reagents.maximum_volume, drip.reagents.flags)
	holder.my_atom = drip

/datum/component/plumbing/automated_iv/Destroy(force)
	QDEL_NULL(holder)
	return ..()

/datum/component/plumbing/automated_iv/can_give(amount, reagent)
	var/obj/machinery/iv_drip/plumbing/drip = parent
	return ..() && drip.mode == IV_TAKING

/datum/component/plumbing/automated_iv/send_request(dir)
	var/obj/machinery/iv_drip/plumbing/drip = parent
	if(drip.mode == IV_INJECTING)
		return ..()

/datum/component/plumbing/automated_iv/transfer_to(datum/component/plumbing/target, amount, reagent, datum/ductnet/net, round_robin = TRUE)
	reagents.trans_to(holder, reagents.total_volume)
	reagents = holder
	. = ..()
	var/obj/machinery/iv_drip/plumbing/drip = parent
	reagents = drip.reagents
