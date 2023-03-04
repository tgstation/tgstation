/**
 * # Pull Component
 *
 * Tells the shell to start pulling on a designated atom. Only works on movable shells.
 */
/obj/item/circuit_component/pull
	display_name = "Start Pulling"
	desc = "A component that can force the shell to pull entities. Only works for drone shells."
	category = "Action"

	/// Frequency input
	var/datum/port/input/target
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/pull/populate_ports()
	target = add_input_port("Target", PORT_TYPE_ATOM)

/obj/item/circuit_component/pull/input_received(datum/port/input/port)
	var/atom/target_atom = target.value
	if(!target_atom)
		return

	var/mob/shell = parent.shell
	if(!istype(shell) || get_dist(shell, target_atom) > 1 || shell.z != target_atom.z)
		return

	INVOKE_ASYNC(shell, TYPE_PROC_REF(/atom/movable, start_pulling), target_atom)
