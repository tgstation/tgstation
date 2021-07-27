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

	/// The ports this port is wired to.
	var/list/datum/port/connected_ports

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
	src.connected_ports = list()


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
 * Casts to the port's datatype (e.g. number -> string), and assumes this can be done.
 */
/datum/port/proc/set_value(v)
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
	set_value(compatible_datatypes(old_type, new_type) ? value : null)
	color = datatype_to_color()
	if(connected_component?.parent)
		SStgui.update_uis(connected_component.parent)

/datum/port/output/set_datatype(new_type)
	for(var/datum/port/input/input as anything in connected_ports)
		if(!compatible_datatypes(datatype,input.datatype))
			disconnect(input)
	..()

/datum/port/input/set_datatype(new_type)
	for(var/datum/port/output/output as anything in connected_ports)
		if(!compatible_datatypes(output.datatype,datatype))
			disconnect(input)
	..()

/**
 * Disconnects a port from all other ports.
 */
/datum/port/proc/disconnect_all()
	for(var/datum/port/port as anything in connected_ports)
		disconnect(port)

/**
 * Sets the output value of the port
 *
 * Arguments:
 * * v - The value to set it to
 */
/datum/port/proc/set_output(v)
	set_value(v)
	for(var/datum/port/input/input as anything in connected_ports)
		input.receive_output(value)


/datum/port/proc/disconnect(datum/port/tgt)
	src.connected_ports -= tgt
	tgt.connected_ports -= src

/// Signal handler proc to null the output if an atom is deleted. An update is not sent because this was not set.
/datum/port/proc/null_output(datum/source)
	SIGNAL_HANDLER
	if(value == source)
		value = null

/**
 * Determines if a datatype can be cast to another.
 *
 * Arguments:
 * * from - The datatype to cast from.
 * * to - The datatype to cast to.
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

	/// The default value of this input
	var/default

/datum/port/input/New(obj/item/circuit_component/to_connect, name, datatype, trigger, default)
	. = ..()
	src.trigger = trigger
	src.default = default
	set_input(default, FALSE)

/**
 * Introduces two ports to one another.
 */
/datum/port/input/proc/connect(datum/port/output/tgt)
	if(!compatible_datatypes(tgt.datatype, src.datatype))
		return
	src.connected_ports |= tgt
	tgt.connected_ports |= src
	// For signals, we don't update the input to prevent sending a signal when connecting ports.
	if(datatype != PORT_TYPE_SIGNAL)
		set_input(tgt.value)


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
/datum/port/input/proc/set_input(v, send_update = TRUE)
	set_value(v)
	if(trigger && send_update)
		TRIGGER_CIRCUIT_COMPONENT(connected_component, src)
