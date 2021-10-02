/datum/circuit_composite_template/assoc_list
	datatype = PORT_COMPOSITE_TYPE_ASSOC_LIST
	composite_datatype_path = /datum/circuit_datatype/composite_instance/assoc_list
	expected_types = 2

/datum/circuit_composite_template/assoc_list/generate_name(list/composite_datatypes)
	return "[composite_datatypes[1]], [composite_datatypes[2]] list"

/datum/circuit_datatype/composite_instance/assoc_list
	color = "white"
	datatype_flags = DATATYPE_FLAG_COMPOSITE
