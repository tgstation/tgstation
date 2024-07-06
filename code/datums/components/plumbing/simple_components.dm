
///has one pipe input that only takes, example is manual output pipe
/datum/component/plumbing/simple_demand
	demand_connects = SOUTH

///has one pipe output that only supplies. example is liquid pump and manual input pipe
/datum/component/plumbing/simple_supply
	supply_connects = SOUTH

///input and output, like a holding tank
/datum/component/plumbing/tank
	demand_connects = WEST
	supply_connects = EAST

/datum/component/plumbing/manifold
	demand_connects = NORTH
	supply_connects = SOUTH

/datum/component/plumbing/manifold/change_ducting_layer(obj/caller, obj/changer, new_layer)
	return

///Baby component for the buffer plumbing machine
#define READY 2

/datum/component/plumbing/buffer
	demand_connects = WEST
	supply_connects = EAST

/datum/component/plumbing/buffer/Initialize(start=TRUE, _turn_connects=TRUE, _ducting_layer, datum/reagents/custom_receiver)
	if(!istype(parent, /obj/machinery/plumbing/buffer))
		return COMPONENT_INCOMPATIBLE

	return ..()

/datum/component/plumbing/buffer/can_give(amount, reagent, datum/ductnet/net)
	var/obj/machinery/plumbing/buffer/buffer = parent
	return (buffer.mode == READY) ? ..() : FALSE

#undef READY

///Lazily demand from any direction. Overlays won't look good, and the aquarium sprite occupies about the entire 32x32 area anyway.
/datum/component/plumbing/aquarium
	demand_connects = SOUTH|NORTH|EAST|WEST
	use_overlays = FALSE
