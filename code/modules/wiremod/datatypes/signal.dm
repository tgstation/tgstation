/datum/circuit_datatype/signal
	datatype = PORT_TYPE_SIGNAL
	color = "teal"
	datatype_flags = DATATYPE_FLAG_ALLOW_MANUAL_INPUT|DATATYPE_FLAG_AVOID_VALUE_UPDATE
	can_receive_from = list(
		PORT_TYPE_NUMBER,
		PORT_TYPE_INSTANT_SIGNAL,
		PORT_TYPE_RESPONSE_SIGNAL,
		PORT_TYPE_SIGNAL,
	)

/datum/circuit_datatype/signal/handle_manual_input(datum/port/input/port, mob/user, user_input)
	var/atom/parent = port.connected_component
	if(parent)
		parent.balloon_alert(user, "triggered [port.name]")
	return COMPONENT_SIGNAL

/datum/circuit_datatype/signal/instant_signal
	datatype = PORT_TYPE_INSTANT_SIGNAL

/datum/circuit_datatype/signal/instant_signal/is_compatible(datum/port/port)
	return istype(port, /datum/port/output)

/datum/circuit_datatype/signal/response_signal
	datatype = PORT_TYPE_RESPONSE_SIGNAL

/datum/circuit_datatype/signal/response_signal/is_compatible(datum/port/port)
	return istype(port, /datum/port/input)
