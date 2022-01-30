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
	var/datum/circuit_datatype/datatype_handler

	/// The port color. If unset, appears as blue.
	var/color

	/// The weight of the port. Determines the
	var/order = 1

/datum/port/New(obj/item/circuit_component/to_connect, name, datatype, order = 1)
	if(!to_connect)
		qdel(src)
		return
	. = ..()
	connected_component = to_connect
	src.name = name
	src.order = order
	set_datatype(datatype)

/datum/port/Destroy(force)
	disconnect_all()
	connected_component = null
	datatype_handler = null
	return ..()

/**
 * Sets the port's value to value.
 * Casts to the port's datatype (e.g. number -> string), and assumes this can be done.
 */
/datum/port/proc/set_value(value, force = FALSE)
	if(isweakref(value))
		var/datum/weakref/reference_to_obj = value
		value = reference_to_obj.resolve()

	if(src.value != value || force)
		if(isdatum(src.value))
			UnregisterSignal(src.value, COMSIG_PARENT_QDELETING)
		if(datatype_handler.is_extensive)
			src.value = datatype_handler.convert_value_extensive(src, value, force)
		else
			src.value = datatype_handler.convert_value(src, value, force)
		if(isdatum(value))
			RegisterSignal(value, COMSIG_PARENT_QDELETING, .proc/null_value)
	SEND_SIGNAL(src, COMSIG_PORT_SET_VALUE, value)

/**
 * Updates the value of the input and calls input_received on the connected component
 */
/datum/port/input/proc/set_input(value, list/return_values)
	if(QDELETED(src)) //Pain
		return
	set_value(value)
	if(trigger)
		connected_component.trigger_component(src, return_values)

/datum/port/output/proc/set_output(value)
	set_value(value)

/**
 * Sets the datatype of the port.
 *
 * Arguments:
 * * new_type - The type this port is to be set to.
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
	src.value = null
	SEND_SIGNAL(src, COMSIG_PORT_SET_TYPE, type_to_set)
	if(connected_component?.parent)
		SStgui.update_uis(connected_component.parent)

/datum/port/input/set_datatype(new_type)
	for(var/datum/port/output/output as anything in connected_ports)
		check_type(output)
	..()

/**
 * Returns the data from the datatype
 */
/datum/port/proc/datatype_ui_data(mob/user)
	return datatype_handler.datatype_ui_data(src)

/**
 * # Output Port
 *
 * An output port that many input ports can connect to
 *
 * Sends a signal whenever the output value is changed
 */
/datum/port/output

/**
 * Disconnects a port from all other ports.
 *
 * Called by [/obj/item/circuit_component] whenever it is disconnected from
 * an integrated circuit
 */
/datum/port/proc/disconnect_all()
	value = null
	SEND_SIGNAL(src, COMSIG_PORT_DISCONNECT)

/datum/port/input/disconnect_all()
	..()
	for(var/datum/port/output/output as anything in connected_ports)
		disconnect(output)

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
 * # Input Port
 *
 * An input port remembers connected output ports.
 *
 * Registers the PORT_SET_VALUE signal on each connected port,
 * and keeps its value equal to the last such signal received.
 */
/datum/port/input
	/// The proc that this trigger will call on the connected component.
	var/trigger

	/// The ports this port is wired to.
	var/list/datum/port/output/connected_ports

/datum/port/input/New(obj/item/circuit_component/to_connect, name, datatype, order = 1, trigger = null, default = null)
	. = ..()
	set_value(default)
	if(trigger)
		src.trigger = trigger
	src.connected_ports = list()

/**
 * Connects an input port to an output port.
 *
 * Arguments:
 * * output - The output port to connect to.
 */
/datum/port/input/proc/connect(datum/port/output/output)
	if(output in connected_ports)
		return
	connected_ports += output
	RegisterSignal(output, COMSIG_PORT_SET_VALUE, .proc/receive_value)
	RegisterSignal(output, COMSIG_PORT_SET_TYPE, .proc/check_type)
	RegisterSignal(output, COMSIG_PORT_DISCONNECT, .proc/disconnect)
	// For signals, we don't update the input to prevent sending a signal when connecting ports.
	if(!(datatype_handler.datatype_flags & DATATYPE_FLAG_AVOID_VALUE_UPDATE))
		set_input(output.value)

/datum/port/input/set_datatype(new_type)
	. = ..()
	for(var/datum/port/output/port as anything in connected_ports)
		check_type(port)

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
 * Mirror value updates from connected output ports after an input_receive_delay.
 */
/datum/port/input/proc/receive_value(datum/port/output/output, value)
	SIGNAL_HANDLER
	SScircuit_component.add_callback(src, CALLBACK(src, .proc/set_input, value))

/// Signal handler proc to null the input if an atom is deleted. An update is not sent because this was not set by anything.
/datum/port/proc/null_value(datum/source)
	SIGNAL_HANDLER
	if(value == source)
		value = null

/**
 * Handle type updates from connected output ports, breaking uncastable connections.
 */
/datum/port/input/proc/check_type(datum/port/output/output)
	SIGNAL_HANDLER
	if(!can_receive_from_datatype(output.datatype))
		disconnect(output)
