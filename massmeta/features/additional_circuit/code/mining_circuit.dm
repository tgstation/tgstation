/**
 * # Mining Component
 *
 * Allows for mining of mineral walls (walls with ores). Requires a shell.
 */
/obj/item/circuit_component/mining
	display_name = "Mine"
	desc = "A component that can force the shell to mine a target. Only works with drone shells. Only works on mining surfaces."
	category = "Action"

	/// Frequency input
	var/datum/port/input/target
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/mining/populate_ports()
	target = add_input_port("Target", PORT_TYPE_ATOM)

/obj/item/circuit_component/mining/input_received(datum/port/input/port)
	var/atom/target_atom = target.value
	if(!istype(target_atom, /turf/closed/mineral))
		return
	var/turf/closed/mineral/target_mineral = target_atom

	var/mob/shell = parent.shell
	if(!istype(shell) || get_dist(shell, target_mineral) > 1 || shell.z != target_mineral.z)
		return

	target_mineral.gets_drilled(shell, FALSE)
