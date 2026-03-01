/obj/item/circuit_component/wire_bundle
	display_name = "Wire Bundle"
	desc = "A bundle of exposed wires that assemblies can be attached to. Ports will only show up once the circuit is inserted into a shell."
	category = "Utility"
	circuit_flags = CIRCUIT_FLAG_REFUSE_MODULE

	var/datum/wires/wire_bundle_component/tracked_wires

	var/list/wire_input_ports = list()
	var/list/wire_output_ports = list()

/obj/item/circuit_component/wire_bundle/get_ui_notices()
	. = ..()
	. += create_ui_notice("Port count is proportional to shell capacity.", "orange", "plug")
	. += create_ui_notice("Max port count: [MAX_WIRE_COUNT]", "orange", "plug")
	. += create_ui_notice("Incompatible with assembly shell.", "red", "plug-circle-xmark")

/obj/item/circuit_component/wire_bundle/register_shell(atom/movable/shell)
	. = ..()
	if(isassembly(shell) && !parent.admin_only)
		return
	if(shell.wires) // Don't add wires to shells that already have some.
		return
	tracked_wires = new(shell)
	shell.set_wires(tracked_wires)
	for(var/wire in tracked_wires.wires)
		wire_input_ports[add_input_port("Pulse [wire]", PORT_TYPE_SIGNAL)] = wire
		wire_output_ports[wire] = add_output_port("[wire] Pulsed", PORT_TYPE_SIGNAL)
	RegisterSignal(tracked_wires, COMSIG_PULSE_WIRE, PROC_REF(on_pulse_wire))
	RegisterSignal(shell, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_shell_requesting_context))
	RegisterSignal(shell, COMSIG_ATOM_ITEM_INTERACTION_SECONDARY, PROC_REF(on_shell_secondary_interaction))

/obj/item/circuit_component/wire_bundle/unregister_shell(atom/movable/shell)
	. = ..()
	if(shell.wires != tracked_wires)
		return
	UnregisterSignal(shell, list(COMSIG_ATOM_ITEM_INTERACTION_SECONDARY, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM))
	for(var/color in tracked_wires.colors)
		var/obj/item/assembly/assembly = tracked_wires.detach_assembly(color)
		if(assembly)
			assembly.forceMove(drop_location())
	shell.set_wires(null)
	QDEL_NULL(tracked_wires)
	for(var/datum/port/input/in_port in wire_input_ports)
		remove_input_port(in_port)
	for(var/wire in wire_output_ports)
		var/datum/port/output/out_port = wire_output_ports[wire]
		remove_output_port(out_port)
	wire_input_ports.Cut()
	wire_output_ports.Cut()

/obj/item/circuit_component/wire_bundle/add_to(obj/item/integrated_circuit/added_to)
	. = ..()
	if(HAS_TRAIT(added_to, TRAIT_COMPONENT_WIRE_BUNDLE))
		return FALSE
	ADD_TRAIT(added_to, TRAIT_COMPONENT_WIRE_BUNDLE, REF(src))

/obj/item/circuit_component/wire_bundle/removed_from(obj/item/integrated_circuit/removed_from)
	. = ..()
	REMOVE_TRAIT(removed_from, TRAIT_COMPONENT_WIRE_BUNDLE, REF(src))
	return ..()

/obj/item/circuit_component/wire_bundle/input_received(datum/port/input/port)
	. = ..()
	if(!port)
		return
	var/wire = wire_input_ports[port]
	if(!wire)
		return
	if(tracked_wires.is_cut(wire))
		return
	var/color = tracked_wires.get_color_of_wire(wire)
	var/obj/item/assembly/attached = tracked_wires.get_attached(color)
	attached?.activate()

/obj/item/circuit_component/wire_bundle/proc/on_pulse_wire(source, wire)
	SIGNAL_HANDLER
	if(tracked_wires.is_cut(wire))
		return
	var/datum/port/output/port = wire_output_ports[wire]
	if(!istype(port))
		return
	port.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/wire_bundle/proc/can_access_wires(atom/source)
	if(ismachinery(source))
		var/obj/machinery/machine = source
		return machine.panel_open
	return TRUE

/obj/item/circuit_component/wire_bundle/proc/on_shell_requesting_context(atom/source, list/context, obj/item/item, mob/user)
	SIGNAL_HANDLER
	. = NONE

	if(!is_wire_tool(item))
		return
	if(!can_access_wires(source))
		return
	context[SCREENTIP_CONTEXT_RMB] = "Interact with wires"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/circuit_component/wire_bundle/proc/on_shell_secondary_interaction(atom/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER
	if(!is_wire_tool(tool))
		return
	if(!can_access_wires(source))
		return
	var/datum/component/shell/shell_comp = source.GetComponent(/datum/component/shell)
	if(shell_comp.locked)
		source.balloon_alert(user, "locked!")
		return ITEM_INTERACT_FAILURE
	if(source.attempt_wire_interaction(user) == WIRE_INTERACTION_BLOCK)
		return ITEM_INTERACT_BLOCKING


