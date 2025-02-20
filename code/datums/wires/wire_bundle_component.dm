#define CAPACITY_PER_WIRE 10

/datum/wires/wire_bundle_component
	holder_type = /atom //Anything that can have a shell component, really.
	randomize = TRUE
	wire_behavior = WIRES_ALL

/datum/wires/wire_bundle_component/New(atom/holder)
	var/datum/component/shell/shell_comp = holder.GetComponent(/datum/component/shell)
	if(!istype(shell_comp))
		CRASH("Holder does not have a shell component!")
	var/wire_count = clamp(round(shell_comp.capacity / CAPACITY_PER_WIRE, 1), 1, MAX_WIRE_COUNT)
	for(var/index in 1 to wire_count)
		wires += "Port [index]"
	..()

/datum/wires/wire_bundle_component/always_reveal_wire(color)
	return TRUE // Let's not make wiring up this stuff confusing - just give them what wires correspond to what ports.

/datum/wires/wire_bundle_component/ui_data(mob/user)
	proper_name = holder.name
	. = ..()

#undef CAPACITY_PER_WIRE
