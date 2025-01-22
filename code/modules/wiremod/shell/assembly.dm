/**
 * # Assembly Shell
 *
 * An assembly that triggers and can be triggered by wires.
 */
/obj/item/assembly/wiremod
	name = "circuit assembly"
	desc = "A small electronic device that can house an integrated circuit."
	icon_state = "wiremod"
	assembly_behavior = ASSEMBLY_ALL

	/// A reference to any holder to use power from instead of the circuit's own cell
	var/atom/movable/power_use_proxy

	/// Valid types for `power_use_proxy` to be
	var/static/list/power_use_override_types = list(/obj/machinery, /obj/vehicle/sealed/mecha, /obj/item/mod/control, /obj/item/pressure_plate, /mob/living/silicon/robot)

/obj/item/assembly/wiremod/Initialize(mapload)
	. = ..()
	var/datum/component/shell/shell = AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/assembly_input(),
		new /obj/item/circuit_component/assembly_output(),
	), SHELL_CAPACITY_SMALL)
	RegisterSignal(shell, COMSIG_SHELL_CIRCUIT_ATTACHED, PROC_REF(on_circuit_attached))
	RegisterSignal(shell, COMSIG_SHELL_CIRCUIT_REMOVED, PROC_REF(on_circuit_removed))
	RegisterSignal(src, COMSIG_ASSEMBLY_PRE_ATTACH, PROC_REF(on_pre_attach))
	RegisterSignals(src, list(COMSIG_ASSEMBLY_ATTACHED, COMSIG_ASSEMBLY_ADDED_TO_BUTTON, COMSIG_ASSEMBLY_ADDED_TO_PRESSURE_PLATE), PROC_REF(on_attached))
	RegisterSignals(src, list(COMSIG_ASSEMBLY_DETACHED, COMSIG_ASSEMBLY_REMOVED_FROM_BUTTON, COMSIG_ASSEMBLY_REMOVED_FROM_PRESSURE_PLATE), PROC_REF(on_detached))

/obj/item/assembly/wiremod/proc/on_circuit_attached(source, obj/item/integrated_circuit/circuit)
	SIGNAL_HANDLER
	RegisterSignal(circuit, COMSIG_CIRCUIT_PRE_POWER_USAGE, PROC_REF(override_circuit_power_usage))

/obj/item/assembly/wiremod/proc/on_circuit_removed(datum/component/shell/source)
	SIGNAL_HANDLER
	UnregisterSignal(source.attached_circuit, COMSIG_CIRCUIT_PRE_POWER_USAGE)

/obj/item/assembly/wiremod/proc/on_pre_attach(obj/item/circuit_component/wire_bundle/source, atom/holder)
	SIGNAL_HANDLER
	if(!istype(source))
		return
	if(source.parent.admin_only)
		return
	if(istype(holder.wires, /datum/wires/wire_bundle_component))
		var/datum/component/shell/shell_comp = GetComponent(/datum/component/shell)
		if(shell_comp.attached_circuit.admin_only)
			return
		return COMPONENT_CANCEL_ATTACH

/obj/item/assembly/wiremod/proc/on_attached(source, atom/movable/holder)
	SIGNAL_HANDLER
	if(is_type_in_list(holder, power_use_override_types))
		power_use_proxy = holder

/obj/item/assembly/wiremod/proc/on_detached(source)
	SIGNAL_HANDLER
	power_use_proxy = null

/obj/item/assembly/wiremod/proc/override_circuit_power_usage(obj/item/integrated_circuit/source, power_to_use)
	SIGNAL_HANDLER
	if(ismachinery(power_use_proxy))
		var/obj/machinery/machine = power_use_proxy
		if(!(machine.is_operational && machine.anchored))
			return
		if(machine.use_energy(power_to_use, AREA_USAGE_EQUIP))
			return COMPONENT_OVERRIDE_POWER_USAGE
	if(ismecha(power_use_proxy))
		var/obj/vehicle/sealed/mecha/mech = power_use_proxy
		if(mech.use_energy(power_to_use))
			return COMPONENT_OVERRIDE_POWER_USAGE
	if(istype(power_use_proxy, /obj/item/mod/control))
		var/obj/item/mod/control/modsuit = power_use_proxy
		if(modsuit.subtract_charge(power_to_use))
			return COMPONENT_OVERRIDE_POWER_USAGE
	if(istype(power_use_proxy, /obj/item/pressure_plate))
		if(!power_use_proxy.anchored)
			return
		var/area/our_area = get_area(power_use_proxy)
		if(our_area.apc?.use_energy(power_to_use, AREA_USAGE_EQUIP))
			return COMPONENT_OVERRIDE_POWER_USAGE
	if(iscyborg(power_use_proxy))
		var/mob/living/silicon/robot/borg = power_use_proxy
		if(borg.cell?.use(power_to_use, force = TRUE))
			return COMPONENT_OVERRIDE_POWER_USAGE

/obj/item/assembly/wiremod/examine(mob/user)
	. = ..()
	. += span_notice("You can also [secured && "un"]secure [src] by right-clicking it with a screwdriver, even if an integrated circuit is attached.")

// This is to bypass removing the circuit with a screwdriver left-click
/obj/item/assembly/wiremod/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	screwdriver_act(user, tool)

/obj/item/circuit_component/assembly_input
	display_name = "Assembly Input"
	desc = "Triggers when pulsed by an attached wire or assembly."

	var/datum/port/output/signal

/obj/item/circuit_component/assembly_input/populate_ports()
	signal = add_output_port("Signal", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/assembly_input/register_shell(atom/movable/shell)
	RegisterSignals(shell, list(COMSIG_ASSEMBLY_PULSED, COMSIG_ITEM_ATTACK_SELF), PROC_REF(on_pulsed))

/obj/item/circuit_component/assembly_input/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(COMSIG_ASSEMBLY_PULSED, COMSIG_ITEM_ATTACK_SELF))

/obj/item/circuit_component/assembly_input/proc/on_pulsed(datum/source, mob/pulser)
	SIGNAL_HANDLER
	signal.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/assembly_output
	display_name = "Assembly Output"
	desc = "Pulses an attached wire or assembly when triggered."

	var/obj/item/assembly/attached_assembly

	var/datum/port/input/signal

/obj/item/circuit_component/assembly_output/populate_ports()
	signal = add_input_port("Signal", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/assembly_output/register_shell(atom/movable/shell)
	. = ..()
	if(isassembly(shell))
		attached_assembly = shell

/obj/item/circuit_component/assembly_output/unregister_shell(atom/movable/shell)
	attached_assembly = null
	return ..()

/obj/item/circuit_component/assembly_output/input_received(datum/port/input/port, list/return_values)
	attached_assembly.pulse()
