/datum/circuit_datatype/user
	datatype = PORT_TYPE_USER
	color = "label"

/datum/circuit_datatype/user/convert_value(datum/port/port, value_to_convert)
	var/datum/object = value_to_convert
	if(QDELETED(object))
		return null
	return object
