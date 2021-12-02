/datum/port/input/option
	var/list/possible_options

/datum/port/input/option/New(obj/item/circuit_component/to_connect, name, datatype, order = 1, trigger = null, default = null, possible_options)
	. = ..()
	src.possible_options = possible_options
	if(length(possible_options))
		set_value(possible_options[1])

/datum/circuit_datatype/option
	datatype = PORT_TYPE_OPTION
	color = "violet"
	datatype_flags = DATATYPE_FLAG_ALLOW_MANUAL_INPUT
	can_receive_from = list(
		PORT_TYPE_STRING,
	)

/datum/circuit_datatype/option/is_compatible(datum/port/gained_port)
	return istype(gained_port, /datum/port/input/option)

/datum/circuit_datatype/option/convert_value(datum/port/input/option/port, value_to_convert, force = FALSE)
	if(force)
		return value_to_convert

	if(!port.possible_options)
		return null

	if(value_to_convert in port.possible_options)
		return value_to_convert
	return port.possible_options[1]

/datum/circuit_datatype/option/datatype_ui_data(datum/port/input/option/port)
	return port.possible_options
