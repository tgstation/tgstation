/datum/circuit_datatype/number
	datatype = PORT_TYPE_NUMBER
	color = "green"
	datatype_flags = DATATYPE_FLAG_ALLOW_MANUAL_INPUT

/datum/circuit_datatype/number/can_receive_from_datatype(datatype_to_check)
	. = ..()
	if(.)
		return

	return datatype_to_check == PORT_TYPE_NUMBER

/datum/circuit_datatype/number/handle_manual_input(datum/port/input/port, mob/user, user_input)
	return text2num(user_input)
