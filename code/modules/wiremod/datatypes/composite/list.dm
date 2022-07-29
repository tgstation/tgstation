/datum/circuit_composite_template/list
	datatype = PORT_COMPOSITE_TYPE_LIST
	composite_datatype_path = /datum/circuit_datatype/composite_instance/list
	expected_types = 1

/datum/circuit_composite_template/list/generate_name(list/composite_datatypes)
	return "[composite_datatypes[1]] [datatype]"

/datum/circuit_datatype/composite_instance/list
	color = "white"
	datatype_flags = DATATYPE_FLAG_COMPOSITE

/datum/circuit_datatype/composite_instance/list/convert_value_extensive(datum/port/port, value_to_convert, force)
	var/datum/circuit_datatype/datatype_handler = GLOB.circuit_datatypes[composite_datatypes[1]]

	var/list/converted_list = list()
	for(var/data in value_to_convert)
		converted_list += list(datatype_handler.convert_value(port, data))
	return converted_list
