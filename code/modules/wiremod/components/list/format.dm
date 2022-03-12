/**
 * # String Format Component
 *
 * Formats strings by replacing %n with nth parameter.
 * Alternative to the Concatenate component.
 */
/obj/item/circuit_component/format
	display_name = "Format"
	desc = "A component that formats strings, replacing %n in the format string with corresponding nth list item."
	category = "List"

	var/static/regex/param_regex = new(@"%([0-9]+)", "g")
	// Used to provide what src should be in the regex replace proc. Necessary due to terrible byond API.
	var/static/obj/item/circuit_component/format/regex_context

	var/datum/port/input/format_port
	var/datum/port/input/param_list_port

	// Range for entity tostring to work, same mechanic as the To String component
	var/max_range = 7

	/// The result from the output
	var/datum/port/output/output
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

/obj/item/circuit_component/format/populate_ports()
	format_port = add_input_port("Format", PORT_TYPE_STRING)
	param_list_port = add_input_port("Params", PORT_TYPE_LIST(PORT_TYPE_ANY))

	output = add_output_port("Output", PORT_TYPE_STRING)

/**
 * Replace %n with the actual param, as a string.
 * Arguments:
 * * match - The full %1 regex match. Unused.
 * * index_string - Just the "1" of the %1 format, actually used.
 */
/obj/item/circuit_component/format/proc/process_param(match, index_string)
	var/param_list = regex_context.param_list_port.value
	var/index = text2num(index_string)

	if(!islist(param_list))
		return @"[NO LIST]"
	if(index < 1 || index > length(param_list))
		return @"[BAD INDEX]"

	var/value = param_list[index]

	// If this is a datum or atom, it's likely wrapped in a weakref.
	if(isweakref(value))
		var/datum/weakref/weak_value = value
		value = weak_value.resolve()

	// Working with entities is constrained by range, just as with To String.
	if(isatom(value))
		var/turf/location = regex_context.get_location()
		var/turf/target_location = get_turf(value)
		if(target_location.z != location.z || get_dist(location, target_location) > regex_context.max_range)
			return @"[OUT OF RANGE]"

	return "[value]"

/obj/item/circuit_component/format/input_received(datum/port/input/port, list/return_values)
	. = ..()

	// Inject the parameters.
	regex_context = src
	output.set_output(param_regex.Replace(format_port.value, .proc/process_param))
