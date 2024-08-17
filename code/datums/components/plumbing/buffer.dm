#define READY 2

/datum/component/plumbing/buffer
	demand_connects = WEST
	supply_connects = EAST

/datum/component/plumbing/buffer/Initialize(start = TRUE, _turn_connects = TRUE, _ducting_layer, datum/reagents/custom_receiver)
	if(!istype(parent, /obj/machinery/plumbing/buffer))
		return COMPONENT_INCOMPATIBLE

	return ..()

/datum/component/plumbing/buffer/can_give(amount, reagent, datum/ductnet/net)
	var/obj/machinery/plumbing/buffer/buffer = parent
	return (buffer.mode == READY) ? ..() : FALSE

#undef READY
