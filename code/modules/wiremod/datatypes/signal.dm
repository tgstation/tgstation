/datum/circuit_datatype/signal
	datatype = PORT_TYPE_SIGNAL
	color = "teal"
	datatype_flags = DATATYPE_FLAG_ALLOW_MANUAL_INPUT|DATATYPE_FLAG_AVOID_VALUE_UPDATE

/datum/circuit_datatype/signal/can_receive_from_datatype(datatype_to_check)
	. = ..()
	if(.)
		return

	return datatype_to_check == PORT_TYPE_NUMBER

/datum/circuit_datatype/signal/handle_manual_input(datum/port/input/port, mob/user, user_input)
	var/atom/parent = port.connected_component
	if(parent)
		parent.balloon_alert(user, "triggered [port.name]")
	return COMPONENT_SIGNAL
