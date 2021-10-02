/datum/circuit_datatype/list_type
	datatype = PORT_TYPE_LIST
	color = "white"

/datum/circuit_datatype/list_type/can_receive_from_datatype(datatype_to_check)
	. = ..()
	if(.)
		return

	return datatype_to_check == PORT_TYPE_ASSOC_LIST
