/**
 * # Typecast Component
 *
 * A component that casts a value to a type if it matches or outputs null.
 */
/obj/item/circuit_component/typecast
	display_name = "Typecast"
	desc = "A component with a customizable output that allows typing of ambiguous inputs. If an input is NOT of the output's type, (or \
	, if a list, if its contents are not correctly typed) the component will return null."
	category = "Utility"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/input/option/typecast_options
	var/datum/port/input/option/list_type_options

	var/datum/port/input/input_value
	var/datum/port/input/list_type_input

	var/datum/port/output/output_value

	var/current_type
	var/current_list_type

/obj/item/circuit_component/typecast/populate_ports()
	current_type = typecast_options.value
	current_list_type = list_type_options.value
	input_value = add_input_port("Input", PORT_TYPE_ANY)
	output_value = add_output_port("Output", current_type)

/obj/item/circuit_component/typecast/populate_options()
	var/static/list/component_options = list(
		PORT_TYPE_STRING,
		PORT_TYPE_NUMBER,
		PORT_COMPOSITE_TYPE_LIST,
		PORT_COMPOSITE_TYPE_ASSOC_LIST,
		PORT_TYPE_ATOM,
		PORT_TYPE_TABLE,
	)

	typecast_options = add_option_port("Typecast Options", component_options)

	list_type_options = add_option_port("List Type", (GLOB.wiremod_basic_types) - PORT_TYPE_SIGNAL)

/obj/item/circuit_component/typecast/pre_input_received(datum/port/input/port)
	update_output()

/obj/item/circuit_component/typecast/input_received(datum/port/input/port)
	var/current_option = typecast_options.value
	var/value = input_value.value
	var/value_to_set = null

	if (current_option == PORT_COMPOSITE_TYPE_LIST || current_option == PORT_COMPOSITE_TYPE_ASSOC_LIST)
		if(islist(value))
			var/is_correct_format = TRUE
			var/is_correctly_typed = TRUE
			var/want_assoc = (current_option == PORT_COMPOSITE_TYPE_ASSOC_LIST)

			for (var/key as anything in value)
				if (!isnull(value[key]))
					is_correct_format = want_assoc
					break

			if (is_correct_format)
				for (var/entry as anything in value)
					if (want_assoc)
						entry = value[entry]
					if (!entry_valid(entry, list_type_options.value))
						is_correctly_typed = FALSE
						break

			if (is_correct_format && is_correctly_typed)
				value_to_set = value

	else if (entry_valid(value, current_option))
		value_to_set = value

	update_output()
	output_value.set_output(value_to_set)

/obj/item/circuit_component/typecast/proc/entry_valid(entry, comparison_type)
	switch (comparison_type)
		if (PORT_TYPE_ANY)
			return TRUE
		if (PORT_TYPE_ATOM)
			return isatom(entry)
		if (PORT_TYPE_NUMBER)
			return isnum(entry)
		if (PORT_TYPE_STRING)
			return istext(entry)
		if (PORT_TYPE_TABLE)
			if (islist(entry))
				if (!length(entry))
					return FALSE
				for (var/potential_list as anything in entry)
					if (!islist(potential_list)) // if any entry isnt a nested list, nope
						return FALSE
				return TRUE // only occurs if every entry is a list, and entry itself is a list
			return FALSE
		else
			return FALSE

/obj/item/circuit_component/typecast/proc/update_output()
	var/current_option = typecast_options.value
	var/current_list_option = list_type_options.value
	if (!current_option) // sanity
		output_value.set_datatype(PORT_TYPE_ANY)
		return

	current_type = current_option
	current_list_type = current_list_option

	if (current_type == PORT_COMPOSITE_TYPE_LIST)
		output_value.set_datatype(PORT_TYPE_LIST(current_list_type))
	else if (current_type == PORT_COMPOSITE_TYPE_ASSOC_LIST)
		output_value.set_datatype(PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, current_list_type))
	else
		output_value.set_datatype(current_type)
