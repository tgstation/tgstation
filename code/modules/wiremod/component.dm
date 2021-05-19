/**
 * # Integrated Circuit Component
 *
 * A component that performs a function when given an input
 *
 * Can be attached to an integrated circuitboard, where it can then
 * be connected between other components to provide an output or to receive
 * an input. This is the base type of all components
 */
/obj/item/component
	name = "component"
	icon = 'icons/obj/module.dmi'
	icon_state = "circuit_map"
	inhand_icon_state = "electronic"

	/// The name of the component shown on the UI
	var/display_name = "Generic Component"

	/// The integrated_circuit that this component is attached to.
	var/obj/item/integrated_circuit/parent

	/// A list that contains the outpurt ports on this component
	/// Used to connect between the ports
	var/list/datum/port/output/output_ports = list()

	/// A list that contains the components the input ports on this component
	/// Used to connect between the ports
	var/list/datum/port/input/input_ports = list()

	/// Used to determine the x position of the component within the UI
	var/rel_x = 0
	/// Used to determine the y position of the component within the UI
	var/rel_y = 0

	/// The power usage whenever this component receives an input
	var/power_usage_per_input = 1

	/// The current selected option
	var/current_option
	/// The options that this component can take on. Limited to strings
	var/list/options

	// Whether the component is removable or not. Only affects user UI
	var/removable = TRUE

/obj/item/component/Initialize()
	. = ..()
	if(length(options))
		current_option = options[1]

/obj/item/component/Destroy()
	if(parent)
		parent.remove_component(src)

	QDEL_LIST(output_ports)
	QDEL_LIST(input_ports)
	return ..()

/**
 * Called when a shell is registered from the component/the component is added to a circuit.
 *
 * Register all signals here on the shell.
 * Arguments:
 * * shell - Shell being registered
 */
/obj/item/component/proc/register_shell(atom/movable/shell)
	return

/**
 * Called when a shell is unregistered from the component/the component is removed from a circuit.
 *
 * Unregister all signals here on the shell.
 * Arguments:
 * * shell - Shell being unregistered
 */
/obj/item/component/proc/unregister_shell(atom/movable/shell)
	return

/**
 * Disconnects a component from other components
 *
 * Disconnects both the input and output ports of the component
 */
/obj/item/component/proc/disconnect()
	for(var/datum/port/output/port_to_disconnect as anything in output_ports)
		port_to_disconnect.disconnect()

	for(var/datum/port/input/port_to_disconnect as anything in input_ports)
		port_to_disconnect.disconnect()

/**
 * Sets the option on this component
 *
 * Can only be a value from the options variable
 * Arguments:
 * * option - The option that has been switched to.
 */
/obj/item/component/proc/set_option(option)
	current_option = option
	input_received()

/**
 * Adds an input port and returns it
 *
 * Arguments:
 * * name - The name of the input port
 * * type - The datatype it handles
 * * trigger - Whether this input port triggers an update on the component when updated.
 */
/obj/item/component/proc/add_input_port(name, type, trigger = TRUE)
	var/datum/port/input/input_port = new(src, name, type, trigger)
	input_ports += input_port
	return input_port


/**
 * Adds an output port and returns it
 *
 * Arguments:
 * * name - The name of the output port
 * * type - The datatype it handles.
 */
/obj/item/component/proc/add_output_port(name, type)
	var/datum/port/output/output_port = new(src, name, type)
	output_ports += output_port
	return output_port

/**
 * Called whenever an input is received from one of the ports.
 *
 * Arguments:
 * * port - Can be null. The port that sent the input
 */
/obj/item/component/proc/input_received(datum/port/input/port)
	SHOULD_CALL_PARENT(TRUE)
	if(!parent)
		return TRUE

	if(!parent.on)
		return TRUE

	var/obj/item/stock_parts/cell/cell = parent.get_cell()
	if(!cell || !cell.use(power_usage_per_input))
		return TRUE
