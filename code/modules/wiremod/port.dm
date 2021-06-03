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
	src.datatype = datatype
	src.color = datatype_to_color()


///Converts the datatype into an appropriate colour
/datum/port/proc/datatype_to_color()
	switch(datatype)
		if(PORT_TYPE_ATOM)
			return "purple"
		if(PORT_TYPE_NUMBER)
			return "green"
		if(PORT_TYPE_STRING)
			return "orange"
		if(PORT_TYPE_LIST)
			return "white"
		if(PORT_TYPE_SIGNAL)
			return "teal"

/datum/port/Destroy(force)
	if(!force && !QDELETED(connected_component))
		// This should never happen. Ports should be deleted with their components
		stack_trace("Attempted to delete a port with a non-destroyed connected_component! (port name: [name], component type: [connected_component.type])")
		return QDEL_HINT_LETMELIVE
	connected_component = null
	return ..()

/**
 * Returns the value to be set for the port
 *
 * Used for implicit conversions between outputs and inputs (e.g. number -> string)
 * and applying/removing signals on inputs
 */
/datum/port/proc/convert_value(prev_value, value_to_convert)
	if(prev_value == value_to_convert)
		return prev_value
	. = value_to_convert

	switch(datatype)
		if(PORT_TYPE_STRING)
			// So that they can't easily get the name like this.
			if(isatom(value_to_convert))
				return PORT_TYPE_ATOM
			else
				return "[value_to_convert]"

	if(isatom(value_to_convert))
		var/atom/atom_to_check = value_to_convert
		if(QDELETED(atom_to_check))
			return null

/**
 * Sets the datatype of the port.
 *
 * Arguments:
 * * type_to_set - The type this port is set to.
 */
/datum/port/proc/set_datatype(type_to_set)
	datatype = type_to_set
	color = datatype_to_color()
	disconnect()
	if(connected_component)
		SStgui.update_uis(connected_component)

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
	output_value = convert_value(output_value, value)
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
 * Determines if a datatype is compatible with this port.
 *
 * Arguments:
 * * other_datatype - The datatype to check
 */
/datum/port/output/proc/compatible_datatype(datatype_to_check)
	if(datatype_to_check == datatype)
		return TRUE

	switch(datatype)
		if(PORT_TYPE_NUMBER)
			// Can easily convert a number to string. Everything else has to use a tostring component
			return datatype_to_check == PORT_TYPE_STRING || datatype_to_check == PORT_TYPE_SIGNAL
		if(PORT_TYPE_SIGNAL)
			// A signal port is just a number port but distinguishable
			return datatype_to_check == PORT_TYPE_NUMBER

	return FALSE

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
	set_input(connected_port.output_value)


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
		addtimer(CALLBACK(src, .proc/set_input, new_value), input_receive_delay, timer_subsystem = SScircuit_component)
	else
		set_input(new_value)

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
	input_value = convert_value(input_value, new_value)
	if(isatom(input_value))
		RegisterSignal(input_value, COMSIG_PARENT_QDELETING, .proc/null_output)

	SEND_SIGNAL(src, COMSIG_PORT_SET_INPUT, input_value)
	if(trigger && send_update)
		connected_component.input_received(src)

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
