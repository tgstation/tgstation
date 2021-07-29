/**
 * # Component Port
 *
 * A port used by a component. Connects to other ports.
 */
/datum/port
	/// The component this port is attached to
	var/obj/item/circuit_component/connected_component

	/// Name of the port. Used when displaying the port.
	var/name

	/// The port type. Ports can only connect to each other if the type matches
	var/datatype

	/// The value that's currently in the port. It's of the above type.
	var/value

	/// The default port type. Stores the original datatype of the port set on Initialize.
	var/default_datatype

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
	src.default_datatype = datatype
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
		if(PORT_TYPE_TABLE)
			return "grey"

/datum/port/Destroy(force)
	disconnect_all()
	connected_component = null
	return ..()

/**
 * Sets the port's value to value.
 * Casts to the port's datatype (e.g. number -> string), and assumes this can be done.
 */
/datum/port/proc/set_value(value)
	SEND_SIGNAL(src, COMSIG_PORT_SET_VALUE, value)
	if(src.value == value)
		return
	if(isatom(src.value))
		UnregisterSignal(src.value, COMSIG_PARENT_QDELETING)
	if(datatype == PORT_TYPE_STRING)
		// So that they can't easily get the name like this.
		value = isatom(value) ? PORT_TYPE_ATOM : copytext("[value]", 1, PORT_MAX_STRING_LENGTH)
	if(datatype == PORT_TYPE_NUMBER)
		if(istext(value))
			value = text2num(value)
	if(isatom(value))
		var/atom/atom_to_check = value
		if(!QDELETED(atom_to_check))
			RegisterSignal(value, COMSIG_PARENT_QDELETING, .proc/on_value_qdeleting)
	src.value = value

/**
 * Updates the value of the input and calls input_received on the connected component
 */
/datum/port/input/proc/set_input(value)
	set_value(value)
	if(trigger)
		TRIGGER_CIRCUIT_COMPONENT(connected_component, src)

/datum/port/output/proc/set_output(value)
	set_value(value)

/**
 * Sets the datatype of the port.
 *
 * Arguments:
 * * new_type - The type this port is to be set to.
 */
/datum/port/proc/set_datatype(new_type)
	SEND_SIGNAL(src, COMSIG_PORT_SET_TYPE, new_type)
	var/old_type = datatype
	datatype = new_type
	set_value(compatible_datatypes(old_type, new_type) ? value : null)
	color = datatype_to_color()
	if(connected_component?.parent)
		SStgui.update_uis(connected_component.parent)

/datum/port/input/set_datatype(new_type)
	for(var/datum/port/output/output as anything in connected_ports)
		if(!compatible_datatypes(output.datatype,new_type))
			disconnect(output)
	..()

/**
 * Disconnects a port from all other ports.
 */
/datum/port/proc/disconnect_all()
	SEND_SIGNAL(src, COMSIG_PORT_DISCONNECT)

/datum/port/input/disconnect_all()
	..()
	for(var/datum/port/port as anything in connected_ports)
		disconnect(port)

/datum/port/input/proc/disconnect(datum/port/output/output)
	SIGNAL_HANDLER
	connected_ports -= output
	UnregisterSignal(output, COMSIG_PORT_SET_VALUE)
	UnregisterSignal(output, COMSIG_PORT_SET_TYPE)
	UnregisterSignal(output, COMSIG_PORT_DISCONNECT)

/// Do our part in setting all source references anywhere to null.
/datum/port/proc/on_value_qdeleting(datum/source)
	SIGNAL_HANDLER
	if(value == source)
		value = null
	else
		stack_trace("Impossible? [src] should only receive COMSIG_PARENT_QDELETING from an atom currently in the port, not [source].")

/**
 * Determines if a datatype can be cast to another.
 *
 * Arguments:
 * * old_type - The datatype to cast from.
 * * new_type - The datatype to cast to.
 */
/proc/compatible_datatypes(old_type, new_type)
	if(new_type == PORT_TYPE_ANY)
		return TRUE
	if(new_type == old_type)
		return TRUE

	switch(old_type)
		if(PORT_TYPE_NUMBER)
			// Can easily convert a number to string. Everything else has to use a tostring component
			return new_type == PORT_TYPE_STRING || new_type == PORT_TYPE_SIGNAL
		if(PORT_TYPE_SIGNAL)
			// A signal port is just a number port but distinguishable
			return new_type == PORT_TYPE_NUMBER

	return FALSE

/datum/port/output
/datum/port/input
	/// Whether this port triggers an update whenever an output is received.
	var/trigger = FALSE

	/// The ports this port is wired to.
	var/list/datum/port/connected_ports

/datum/port/input/New(obj/item/circuit_component/to_connect, name, datatype, trigger, default)
	. = ..()
	set_input(default)
	src.trigger = trigger
	src.connected_ports = list()

/**
 * Introduces two ports to one another.
 */
/datum/port/input/proc/connect(datum/port/output/output)
	if(!compatible_datatypes(output.datatype, src.datatype))
		return
	connected_ports |= output
	RegisterSignal(output, COMSIG_PORT_SET_VALUE, .proc/receive_value)
	RegisterSignal(output, COMSIG_PORT_SET_TYPE, .proc/receive_type)
	RegisterSignal(output, COMSIG_PORT_DISCONNECT, .proc/disconnect)
	// For signals, we don't update the input to prevent sending a signal when connecting ports.
	if(datatype != PORT_TYPE_SIGNAL)
		set_input(output.value)

/**
 * Mirror value updates from connected output ports after an input_receive_delay.
 */
/datum/port/input/proc/receive_value(datum/port/output/output, value)
	SIGNAL_HANDLER
	SScircuit_component.add_callback(CALLBACK(src, .proc/set_input, value))

/**
 * Handle type updates from connected output ports, breaking uncastable connections.
 */
/datum/port/input/proc/receive_type(datum/port/output/output, new_type)
	SIGNAL_HANDLER
	if(!compatible_datatypes(new_type, src.datatype))
		disconnect(output)
