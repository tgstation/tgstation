#define READY 2

/datum/component/plumbing/buffer
	demand_connects = WEST
	supply_connects = EAST

/datum/component/plumbing/buffer/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/plumbing/buffer))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/buffer/supply_demand(dir)
	var/obj/machinery/plumbing/buffer/buffer = parent
	if(buffer.mode == READY)
		return ..()

#undef READY
