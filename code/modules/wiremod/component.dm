/**
 * # Integrated Circuit Component
 *
 * A component that performs a function when given an input
 *
 * Can be attached to an integrated circuitboard, where it can then
 * be connected between other components to provide an output or to receive
 * an input. This is the base type of all components
 */
/obj/item/circuit_component
	name = COMPONENT_DEFAULT_NAME
	icon = 'icons/obj/module.dmi'
	icon_state = "component"
	inhand_icon_state = "electronic"

	/// The name of the component shown on the UI
	var/display_name = "Generic"

	/// The integrated_circuit that this component is attached to.
	var/obj/item/integrated_circuit/parent

	/// A list that contains the outpurt ports on this component
	/// Used to connect between the ports
	var/list/datum/port/output/output_ports = list()

	/// A list that contains the components the input ports on this component
	/// Used to connect between the ports
	var/list/datum/port/input/input_ports = list()

	/// Generic trigger input for triggering this component
	var/datum/port/input/trigger_input
	var/datum/port/output/trigger_output

	var/has_trigger = FALSE

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

/obj/item/circuit_component/Initialize()
	. = ..()
	if(name == COMPONENT_DEFAULT_NAME)
		name = "[lowertext(display_name)] [COMPONENT_DEFAULT_NAME]"
	if(length(options))
		current_option = options[1]

	return INITIALIZE_HINT_LATELOAD

/obj/item/circuit_component/LateInitialize()
	. = ..()
	if(has_trigger)
		trigger_input = add_input_port("Trigger", PORT_TYPE_SIGNAL)
		trigger_output = add_output_port("Triggered", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/Destroy()
	if(parent)
		parent.remove_component(src)
		parent = null

	trigger_input = null
	trigger_output = null

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
/obj/item/circuit_component/proc/register_shell(atom/movable/shell)
	return

/**
 * Called when a shell is unregistered from the component/the component is removed from a circuit.
 *
 * Unregister all signals here on the shell.
 * Arguments:
 * * shell - Shell being unregistered
 */
/obj/item/circuit_component/proc/unregister_shell(atom/movable/shell)
	return

/**
 * Disconnects a component from other components
 *
 * Disconnects both the input and output ports of the component
 */
/obj/item/circuit_component/proc/disconnect()
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
/obj/item/circuit_component/proc/set_option(option)
	current_option = option
	input_received()

/**
 * Matches the output port's datatype with the input port's current connected port.
 *
 * Returns true if datatype was changed, otherwise returns false.
 * Arguments:
 * * input_port - The input port to check the connected port from.
 * * output_port - The output port to convert. Warning, this does change the output port.
 */
/obj/item/circuit_component/proc/match_port_datatype(datum/port/input/input_port, datum/port/output/output_port)
	if(input_port.connected_port)
		var/datum/port/connected_port = input_port.connected_port
		if(connected_port.datatype != output_port.datatype)
			output_port.set_datatype(connected_port.datatype)
			return TRUE
	return FALSE


/**
 * Adds an input port and returns it
 *
 * Arguments:
 * * name - The name of the input port
 * * type - The datatype it handles
 * * trigger - Whether this input port triggers an update on the component when updated.
 */
/obj/item/circuit_component/proc/add_input_port(name, type, trigger = TRUE, default = null)
	var/datum/port/input/input_port = new(src, name, type, trigger, default)
	input_ports += input_port
	return input_port


/**
 * Adds an output port and returns it
 *
 * Arguments:
 * * name - The name of the output port
 * * type - The datatype it handles.
 */
/obj/item/circuit_component/proc/add_output_port(name, type)
	var/datum/port/output/output_port = new(src, name, type)
	output_ports += output_port
	return output_port

/**
 * Called whenever an input is received from one of the ports.
 *
 * Return value indicates that the circuit should not do anything
 * Arguments:
 * * port - Can be null. The port that sent the input
 */
/obj/item/circuit_component/proc/input_received(datum/port/input/port)
	SHOULD_CALL_PARENT(TRUE)
	if(!parent?.on)
		return TRUE

	var/obj/item/stock_parts/cell/cell = parent.get_cell()
	if(!cell?.use(power_usage_per_input))
		return TRUE

	if(has_trigger && !COMPONENT_TRIGGERED_BY(trigger_input, port))
		return TRUE
