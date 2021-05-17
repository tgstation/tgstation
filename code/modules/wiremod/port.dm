/**
 * # Component Port
 *
 * A base type port used by a component
 *
 * Connects to other ports. This is an abstract type that should not be instanciated
 */
/datum/port
	/// The component this port is attached to
	var/obj/item/component/connected_component

	/// Name of the port. Used when displaying the port.
	var/name

	/// The port type. Ports can only connect to each other if the type matches
	var/datatype

/datum/port/New(obj/item/component/to_connect, name, datatype)
	if(!to_connect)
		qdel(src)
		return
	. = ..()
	// Don't need to do src.connected_component here, but it looks inline
	// with the other variable declarations
	src.connected_component = to_connect
	src.name = name
	src.datatype = datatype

/datum/port/Destroy()
	if(!connected_component.gc_destroyed)
		// This should never happen
		stack_trace("Attempted to delete a port with a non-destroyed connected_component! (port name: [name], component type: [connected_component.type])")
		return QDEL_HINT_LETMELIVE
	connected_component = null
	return ..()

/**
 * Disconnects a port from all other ports
 *
 * Called by [/obj/item/component] whenever it is disconnected from
 * an integrated circuit
 */
/datum/port/proc/disconnect()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_PORT_DISCONNECT)


/**
 * # Output Port
 *
 * An output port that many input ports can connect to
 *
 * Sends a signal whenever the output value is changed
 */
/datum/port/output
	/// The output value of the port
	var/output_value

/datum/port/output/disconnect()
	set_output(null)
	return ..()

/**
 * Sets the output value of the port
 *
 * Arguments:
 * * value - The value to set it to
 */
/datum/port/output/proc/set_output(value)
	output_value = value
	SEND_SIGNAL(src, COMSIG_PORT_SET_OUTPUT, value)

/**
 * # Input Port
 *
 * An input port that can only be connected to 1 output port
 *
 * Registers a signal on the target output port to listen out for any output
 * so that an update can be sent to the attached component
 */
/datum/port/input
	/// The output value of the port
	var/input_value

	/// The connected output port
	var/datum/port/output/connected_port

	/// The delay before updating the input value whenever a modification is made.
	/// This does not apply when when the output port is registered
	var/input_receive_delay = PORT_INPUT_RECEIVE_DELAY

	/// Whether this port triggers an update whenever an output is received.
	var/trigger = FALSE

/datum/port/input/New(obj/item/component/to_connect, name, datatype, trigger)
	. = ..()
	src.trigger = trigger

/**
 * Connects the input port to the output port
 *
 * Sets the input_value and registers a signal to receive future updates.
 * Arguments:
 * * port_to_register - The port to connect the input port to
 */
/datum/port/input/proc/register_output_port(datum/port/output/port_to_register)
	unregister_output_port()

	RegisterSignal(port_to_register, COMSIG_PORT_SET_OUTPUT, .proc/receive_output)
	RegisterSignal(port_to_register, COMSIG_PORT_DISCONNECT, .proc/unregister_output_port)
	RegisterSignal(port_to_register, COMSIG_PARENT_QDELETING, .proc/unregister_output_port)

	connected_port = port_to_register
	SEND_SIGNAL(connected_port, COMSIG_PORT_OUTPUT_CONNECT, src)


/**
 * Sets a timer depending on the value of the input_receive_delay
 *
 * The timer will call a proc that updates the value.
 * Arguments:
 * * connected_port - The connected output port
 * * new_value - The new value received from the output port
 */
/datum/port/input/proc/receive_output(datum/port/output/connected_port, new_value)
	SIGNAL_HANDLER
	if(input_receive_delay)
		addtimer(CALLBACK(src, .proc/set_value, new_value), input_receive_delay)
	else
		set_value(new_value)

/**
 * Updates the value of the input
 *
 * It updates the value of the input and calls input_received on the connected component
 * Arguments:
 * * port_to_register - The port to connect the input port to
 */
/datum/port/input/proc/set_value(var/new_value)
	input_value = new_value
	if(trigger)
		connected_component.input_received()

/datum/port/input/disconnect()
	unregister_output_port()
	return ..()

/datum/port/input/proc/unregister_output_port()
	SIGNAL_HANDLER
	if(!connected_port)
		return
	UnregisterSignal(connected_port, list(
		COMSIG_PARENT_QDELETING,
		COMSIG_PORT_SET_OUTPUT,
		COMSIG_PORT_DISCONNECT
	))
	connected_port = null
	set_value(null)

/datum/port/input/Destroy()
	unregister_output_port()
	return ..()
