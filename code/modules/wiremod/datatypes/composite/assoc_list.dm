/datum/circuit_composite_template/assoc_list
	datatype = PORT_COMPOSITE_TYPE_ASSOC_LIST
	composite_datatype_path = /datum/circuit_datatype/composite_instance/assoc_list
	expected_types = 2

/datum/circuit_composite_template/assoc_list/generate_name(list/composite_datatypes)
	return "[composite_datatypes[1]], [composite_datatypes[2]] list"

/datum/circuit_datatype/composite_instance/assoc_list
	color = "white"
	datatype_flags = DATATYPE_FLAG_COMPOSITE

/datum/circuit_datatype/composite_instance/assoc_list/convert_value_extensive(datum/port/port, value_to_convert, force)
	var/datum/circuit_datatype/key_handler = GLOB.circuit_datatypes[composite_datatypes[1]]
	var/datum/circuit_datatype/value_handler = GLOB.circuit_datatypes[composite_datatypes[2]]

	var/list/converted_list = list()
	for(var/data in value_to_convert)
		converted_list[key_handler.convert_value(port, data)] = value_handler.convert_value(port, value_to_convert[data])
	return converted_list
