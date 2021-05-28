/**
 * # Self Component
 *
 * Return the current shell.
 */
/obj/item/circuit_component/self
	display_name = "Self"

	/// The shell this component is attached to.
	var/datum/port/output/output

/obj/item/circuit_component/self/Initialize()
	. = ..()
	output = add_output_port("Self", PORT_TYPE_ATOM)

/obj/item/circuit_component/self/Destroy()
	output = null
	return ..()

/obj/item/circuit_component/self/register_shell(atom/movable/shell)
	output.set_output(shell)

/obj/item/circuit_component/self/unregister_shell(atom/movable/shell)
	output.set_output(null)
