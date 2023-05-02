/**
 * # Format List Component
 *
 * Formats lists by replacing %n in format string with nth parameter.
 * Alternative to the Concatenate component.
 */
/obj/item/circuit_component/format
	display_name = "Format List"
	desc = "A component that formats lists, replacing %n in the format string with corresponding nth list item."
	category = "List"

	var/static/regex/format_component/list_param_regex = new(@"%([0-9]+)", "g")

	/// The regex used to find a parameter.
	var/regex/format_component/param_regex

	var/datum/port/input/format_port
	var/datum/port/input/param_list_port

	// Range for entity tostring to work, same mechanic as the To String component
	var/max_range = 7

	/// The result from the output
	var/datum/port/output/output
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/format/Initialize(mapload)
	. = ..()
	param_regex = list_param_regex

/obj/item/circuit_component/format/proc/make_params_port()
	param_list_port = add_input_port("Params", PORT_TYPE_LIST(PORT_TYPE_ANY))

/obj/item/circuit_component/format/populate_ports()
	format_port = add_input_port("Format", PORT_TYPE_STRING)
	make_params_port()

	output = add_output_port("Output", PORT_TYPE_STRING)

/**
 * Get an item from the list.
 * Return null to indicate invalid index.
 * Arguments:
 * * param_list - The resolved list.
 * * index_string - The raw list index, as a string.
 */
/obj/item/circuit_component/format/proc/get_list_item(list/param_list, index_string)
	var/index = text2num(index_string)
	if(index < 1 || index > length(param_list))
		return null

	return param_list[index]

/obj/item/circuit_component/format/input_received(datum/port/input/port, list/return_values)
	. = ..()

	// Inject the parameters.
	param_regex.context = src
	output.set_output(param_regex.Replace(format_port.value, /regex/format_component/proc/process_format_component_param))
	param_regex.context = null

/**
 * # Format Associative List Component
 *
 * Formats lists by replacing %n in format string with nth parameter.
 * Alternative to the Concatenate component.
 */
/obj/item/circuit_component/format/assoc
	display_name = "Format Associative List"
	desc = "A component that formats associative lists, replacing %key in the format string with corresponding list\[key] item."

	var/static/regex/format_component/assoc_param_regex = new(@"%([a-zA-Z0-9_]+)", "g")

/obj/item/circuit_component/format/assoc/Initialize(mapload)
	. = ..()
	param_regex = assoc_param_regex

/obj/item/circuit_component/format/assoc/get_list_item(list/param_list, index_string)
	return param_list[index_string]

/obj/item/circuit_component/format/assoc/make_params_port()
	param_list_port = add_input_port("Params", PORT_TYPE_ASSOC_LIST(PORT_TYPE_STRING, PORT_TYPE_ANY))

/**
 * # Subtype of regex that holds context to /obj/item/circuit_component/format
 */
/regex/format_component
	var/obj/item/circuit_component/format/context

/**
 * Replace %n with the actual param, as a string.
 * Arguments:
 * * match - The full %1 regex match. Unused.
 * * index_string - Just the "1" of the %1 format, actually used.
 */
/regex/format_component/proc/process_format_component_param(match, index_string)
	REGEX_REPLACE_HANDLER
	// The static regex_context var is what you'd expect src to be, but src is actually the regex instance.
	var/list/param_list = context.param_list_port.value
	if(!islist(param_list))
		return @"[NO LIST]"

	var/value = context.get_list_item(param_list, index_string)
	if(value == null)
		return @"[BAD INDEX]"

	// If this is a datum or atom, it's likely wrapped in a weakref.
	if(isweakref(value))
		var/datum/weakref/weak_value = value
		value = weak_value.resolve()

	// Working with entities is constrained by range, just as with To String.
	if(isatom(value))
		var/turf/location = context.get_location()
		var/turf/target_location = get_turf(value)
		if(target_location.z != location.z || get_dist(location, target_location) > context.max_range)
			return @"[OUT OF RANGE]"

	return "[value]"
