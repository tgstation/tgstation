/**
 * # Component Port
 *
 * A base type port used by a component
 *
 * Connects to other ports. This is an abstract type that should not be instanciated
 */
/datum/port
	/// The component this port is attached to
	var/obj/item/circuit_component/connected_component

	/// Name of the port. Used when displaying the port.
	var/name

	/// The port type. Ports can only connect to each other if the type matches
	var/datatype

	/// The default port type. Stores the original datatype of the port set on Initialize.
	var/datum/circuit_datatype/datatype_handler

	/// The port color. If unset, appears as blue.
	var/color

/datum/port/New(obj/item/circuit_component/to_connect, name, datatype)
	if(!to_connect)
		qdel(src)
		return
	. = ..()
	// Don't need to do src.connected_component here, but it looks inline
	// with the other variable declarations
	src.connected_component = to_connect
	src.name = name
	set_datatype(datatype)

/datum/port/Destroy(force)
	connected_component = null
	datatype_handler = null
	return ..()

/**
 * Returns the value to be set for the port
 *
 * Used for implicit conversions between outputs and inputs (e.g. number -> string)
 * and applying/removing signals on inputs
 */
/datum/port/proc/convert_value(value_to_convert)
	return datatype_handler.convert_value(src, value_to_convert)

/**
 * Sets the datatype of the port.
 *
 * Arguments:
 * * type_to_set - The type this port is set to.
 */
/datum/port/proc/set_datatype(type_to_set)
	if(type_to_set == datatype)
		return

	if(datatype_handler)
		datatype_handler.on_loss(src)
	datatype_handler = null

	var/datum/circuit_datatype/handler = GLOB.circuit_datatypes[type_to_set]
	if(!handler || !handler.is_compatible(src))
		type_to_set = PORT_TYPE_ANY
		handler = GLOB.circuit_datatypes[type_to_set]
		// We can't leave this port without a type or else it'll just keep spewing out unnecessary and unneeded runtimes as well as leaving the circuit in a broken state.
		stack_trace("[src] port attempted to be set to an incompatible datatype! (target datatype to set: [type_to_set])")

	datatype = type_to_set
	datatype_handler = handler
	color = datatype_handler.color
	datatype_handler.on_gain(src)
	if(connected_component?.parent)
		SStgui.update_uis(connected_component.parent)

/**
 * Returns the data from the datatype
 */
/datum/port/proc/datatype_ui_data()
	return datatype_handler.datatype_ui_data(src)

/**
 * Disconnects a port from all other ports
 *
 * Called by [/obj/item/circuit_component] whenever it is disconnected from
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

/datum/port/output/Destroy(force)
	output_value = null
	return ..()

/**
 * Sets the output value of the port
 *
 * Arguments:
 * * value - The value to set it to
 */
/datum/port/output/proc/set_output(value)
	if(isatom(output_value))
		UnregisterSignal(output_value, COMSIG_PARENT_QDELETING)
	output_value = convert_value(value)
	if(isatom(output_value))
		RegisterSignal(output_value, COMSIG_PARENT_QDELETING, .proc/null_output)

	SEND_SIGNAL(src, COMSIG_PORT_SET_OUTPUT, output_value)

/// Signal handler proc to null the output if an atom is deleted. An update is not sent because this was not set.
/datum/port/output/proc/null_output(datum/source)
	SIGNAL_HANDLER
	if(output_value == source)
		output_value = null

/datum/port/output/set_datatype(type_to_set)
	. = ..()
	set_output(null)

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

	/// Whether this port triggers an update whenever an output is received.
	var/trigger = FALSE

	/// The default value of this input
	var/default

/datum/port/input/New(obj/item/circuit_component/to_connect, name, datatype, trigger, default)
	. = ..()
	src.trigger = trigger
	src.default = default
	set_input(default, FALSE)

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
	RegisterSignal(port_to_register, list(
		COMSIG_PORT_DISCONNECT,
		COMSIG_PARENT_QDELETING
	), .proc/unregister_output_port)

	connected_port = port_to_register
	SEND_SIGNAL(connected_port, COMSIG_PORT_OUTPUT_CONNECT, src)
	// For signals, we don't update the input to prevent sending a signal when connecting ports.
	if(!(datatype_handler.datatype_flags & DATATYPE_FLAG_AVOID_VALUE_UPDATE))
		set_input(connected_port.output_value)

/**
 * Determines if a datatype is compatible with another port of a different type.
 *
 * Arguments:
 * * other_datatype - The datatype to check
 */
/datum/port/input/proc/can_receive_from_datatype(datatype_to_check)
	return datatype_handler.can_receive_from_datatype(datatype_to_check)

/**
 * Determines if a datatype is compatible with another port of a different type.
 *
 * Arguments:
 * * other_datatype - The datatype to check
 */
/datum/port/input/proc/handle_manual_input(mob/user, manual_input)
	if(datatype_handler.datatype_flags & DATATYPE_FLAG_ALLOW_MANUAL_INPUT)
		return datatype_handler.handle_manual_input(src, user, manual_input)
	return null

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
	SScircuit_component.add_callback(CALLBACK(src, .proc/set_input, new_value))

/**
 * Updates the value of the input
 *
 * It updates the value of the input and calls input_received on the connected component
 * Arguments:
 * * port_to_register - The port to connect the input port to
 */
/datum/port/input/proc/set_input(new_value, send_update = TRUE)
	if(isatom(input_value))
		UnregisterSignal(input_value, COMSIG_PARENT_QDELETING)
	input_value = convert_value(new_value)
	if(isatom(input_value))
		RegisterSignal(input_value, COMSIG_PARENT_QDELETING, .proc/null_output)

	SEND_SIGNAL(src, COMSIG_PORT_SET_INPUT, input_value)
	if(connected_component && trigger && send_update)
		TRIGGER_CIRCUIT_COMPONENT(connected_component, src)

/// Signal handler proc to null the input if an atom is deleted. An update is not sent because this was not set by anything.
/datum/port/input/proc/null_output(datum/source)
	SIGNAL_HANDLER
	if(input_value == source)
		input_value = null

/datum/port/input/disconnect()
	unregister_output_port()
	return ..()

/datum/port/input/set_datatype(type_to_set)
	. = ..()
	set_input(default)

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
	set_input(default)

/datum/port/input/Destroy()
	unregister_output_port()
	connected_port = null
	return ..()
