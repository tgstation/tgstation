/**
 * # Assembly Shell
 *
 * An assembly that triggers and can be triggered by wires.
 */
/obj/item/assembly/wiremod
	name = "circuit assembly"
	desc = "A small electronic device that can house an integrated circuit."
	icon_state = "wiremod"
	attachable = TRUE

/obj/item/assembly/wiremod/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, list(
		new /obj/item/circuit_component/assembly_input(),
		new /obj/item/circuit_component/assembly_output(),
	), SHELL_CAPACITY_SMALL)

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
	RegisterSignal(shell, list(COMSIG_ASSEMBLY_PULSED, COMSIG_ITEM_ATTACK_SELF), .proc/on_pulsed)

/obj/item/circuit_component/assembly_input/unregister_shell(atom/movable/shell)
	UnregisterSignal(shell, list(COMSIG_ASSEMBLY_PULSED, COMSIG_ITEM_ATTACK_SELF))

/obj/item/circuit_component/assembly_input/proc/on_pulsed()
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
	if(istype(shell, /obj/item/assembly))
		attached_assembly = shell

/obj/item/circuit_component/assembly_output/unregister_shell(atom/movable/shell)
	attached_assembly = null
	return ..()

/obj/item/circuit_component/assembly_output/input_received(datum/port/input/port, list/return_values)
	attached_assembly.pulse(FALSE)
