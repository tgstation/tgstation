/datum/circuit_datatype/datum
	datatype = PORT_TYPE_DATUM
	color = "yellow"
	datatype_flags = DATATYPE_FLAG_ALLOW_MANUAL_INPUT|DATATYPE_FLAG_ALLOW_ATOM_INPUT
	can_receive_from = list(
		PORT_TYPE_ATOM,
	)

/datum/circuit_datatype/datum/convert_value(datum/port/port, value_to_convert)
	var/datum/object = value_to_convert
	if(QDELETED(object))
		return null
	return object
