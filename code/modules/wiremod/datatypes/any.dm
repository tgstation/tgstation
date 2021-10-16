/datum/circuit_datatype/any
	datatype = PORT_TYPE_ANY
	color = "blue"
	datatype_flags = DATATYPE_FLAG_ALLOW_MANUAL_INPUT|DATATYPE_FLAG_ALLOW_ATOM_INPUT

/datum/circuit_datatype/any/can_receive_from_datatype(datatype_to_check)
	return TRUE

/datum/circuit_datatype/any/handle_manual_input(datum/port/input/port, mob/user, user_input)
	var/result = text2num(user_input)
	if(isnull(result))
		return user_input
	return result
