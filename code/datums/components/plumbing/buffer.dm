/datum/component/plumbing/buffer
	demand_connects = WEST
	supply_connects = EAST

/datum/component/plumbing/buffer/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/plumbing/buffer))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/buffer/send_request(dir)
	var/obj/machinery/plumbing/buffer/buffer = parent
	if(buffer.mode == AB_UNREADY)
		return ..()

/datum/component/plumbing/buffer/can_give(amount, reagent, datum/ductnet/net)
	var/obj/machinery/plumbing/buffer/buffer = parent
	return (buffer.mode == AB_READY) ? ..() : FALSE
