/datum/circuit_datatype/string
	datatype = PORT_TYPE_STRING
	color = "orange"
	datatype_flags = DATATYPE_FLAG_ALLOW_MANUAL_INPUT

/datum/circuit_datatype/string/can_receive_from_datatype(datatype_to_check)
	return TRUE

/datum/circuit_datatype/string/convert_value(datum/port/port, value_to_convert)
	if(isnull(value_to_convert))
		return

	// So that they can't easily get the name like this.
	if(isatom(value_to_convert))
		return PORT_TYPE_ATOM
	else
		return copytext("[value_to_convert]", 1, PORT_MAX_STRING_LENGTH)
