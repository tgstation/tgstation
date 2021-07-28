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
 * Sets the port's value to v.
 * Casts to the port's datatype (e.g. number -> string), and assumes this can be done.
 */
/datum/port/proc/put(v)
	if(value == v)
		return
	if(isatom(value))
		UnregisterSignal(value, COMSIG_PARENT_QDELETING)
	value = v
	if(isnull(value))
		return
	value = cast(value, datatype)
	if(isatom(value))
		var/atom/atom_to_check = value
		if(QDELETED(atom_to_check))
			return null
		RegisterSignal(value, COMSIG_PARENT_QDELETING, .proc/null_output)

/**
 * Implicit conversion of a value to a type.
 * Assumes that the types are compatible.
 */
/proc/cast(value, type)
	switch(type)
		if(PORT_TYPE_STRING)
			// So that they can't easily get the name like this.
			if(isatom(value))
				return PORT_TYPE_ATOM
			return copytext("[value]", 1, PORT_MAX_STRING_LENGTH)
	return value

/**
 * Sets the datatype of the port.
 *
 * Arguments:
 * * new_type - The type this port is to be set to.
 */
/datum/port/proc/set_datatype(new_type)
	var/old_type = datatype
	datatype = new_type
	put(compatible_datatypes(old_type, new_type) ? value : null)
	color = datatype_to_color()
	if(connected_component?.parent)
		SStgui.update_uis(connected_component.parent)

/datum/port/output/set_datatype(new_type)
	SEND_SIGNAL(src, COMSIG_PORT_TYPE, new_type)
	..()

/datum/port/input/set_datatype(new_type)
	for(var/datum/port/output/output as anything in connected_ports)
		if(!compatible_datatypes(output.datatype,datatype))
			disconnect(output)
	..()

/**
 * Disconnects a port from all other ports.
 */
/datum/port/proc/disconnect_all()

/datum/port/input/disconnect_all()
	for(var/datum/port/port as anything in connected_ports)
		disconnect(port)

/datum/port/output/disconnect_all()
	SEND_SIGNAL(src, COMSIG_PORT_TYPE, null)


/**
 * Sets the output value of the port
 *
 * Arguments:
 * * v - The value to set it to
 */
/datum/port/output/put(v)
	..(v)
	SEND_SIGNAL(src, COMSIG_PORT_VALUE, v)


/datum/port/input/proc/disconnect(datum/port/output/output)
	connected_ports -= output
	UnregisterSignal(output, COMSIG_PORT_TYPE)
	UnregisterSignal(output, COMSIG_PORT_VALUE)

/// Signal handler proc to null the output if an atom is deleted. An update is not sent because this was not set.
/datum/port/proc/null_output(datum/source)
	SIGNAL_HANDLER
	if(value == source)
		value = null

/**
 * Determines if a datatype can be cast to another.
 *
 * Arguments:
 * * old_type - The datatype to cast from.
 * * new_type - The datatype to cast to.
 */
/proc/compatible_datatypes(old_type, new_type)
	if(isnull(old_type))
		return FALSE
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
	put(default)
	src.trigger = trigger
	src.connected_ports = list()

/**
 * Introduces two ports to one another.
 */
/datum/port/input/proc/connect(datum/port/output/output)
	SIGNAL_HANDLER
	if(!compatible_datatypes(output.datatype, src.datatype))
		return
	connected_ports |= output
	RegisterSignal(output, COMSIG_PORT_TYPE, .proc/receive_type)
	RegisterSignal(output, COMSIG_PORT_VALUE, .proc/receive_value)
	// For signals, we don't update the input to prevent sending a signal when connecting ports.
	if(datatype != PORT_TYPE_SIGNAL)
		put(output.value)

/**
 * Handle an output port update.
 */
/datum/port/input/proc/receive_type(datum/port/output/output, new_type)
	SIGNAL_HANDLER
	if(!compatible_datatypes(new_type, src.datatype))
		disconnect(output)

/**
 * Sets a timer depending on the value of the input_receive_delay
 *
 * The timer will call a proc that updates the value.
 * Arguments:
 * * connected_port - The connected output port
 * * new_value - The new value received from the output port
 */
/datum/port/input/proc/receive_value(datum/port/output/connected_port, new_value)
	SScircuit_component.add_callback(CALLBACK(src, .proc/put, new_value))

/**
 * Updates the value of the input
 *
 * It updates the value of the input and calls input_received on the connected component
 * Arguments:
 * * port_to_register - The port to connect the input port to
 */
/datum/port/input/put(v)
	..(v)
	if(trigger)
		TRIGGER_CIRCUIT_COMPONENT(connected_component, src)
