/datum/circuit_datatype/any
	datatype = PORT_TYPE_ANY
	color = "blue"
	datatype_flags = DATATYPE_FLAG_ALLOW_MANUAL_INPUT

/datum/circuit_datatype/any/can_receive_from_datatype(datatype_to_check)
	return TRUE

/datum/circuit_datatype/any/handle_manual_input(datum/port/input/port, mob/user, user_input)
	return text2num(user_input) || user_input
