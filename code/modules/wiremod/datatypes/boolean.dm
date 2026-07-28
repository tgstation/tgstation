/datum/circuit_datatype/boolean
	datatype = PORT_TYPE_BOOLEAN
	color = "bad" // This should be close enough to dark red.
	datatype_flags = DATATYPE_FLAG_ALLOW_MANUAL_INPUT

/datum/circuit_datatype/boolean/can_receive_from_datatype(datatype_to_check)
	return TRUE

/datum/circuit_datatype/boolean/convert_value(datum/port/port, value_to_convert, force)
	return !!value_to_convert
