/**
 * # String Replace Component
 *
 * Replace any instance of a word/letter in a string with another
 */
/obj/item/circuit_component/compare/contains/replace
	display_name = "String Replace"
	desc = "Replace any instance of a word/letter in a string with another"

	var/datum/port/input/replacement

	result_port_type = PORT_TYPE_STRING

/obj/item/circuit_component/compare/contains/replace/populate_custom_ports()
	. = ..()
	replacement = add_input_port("Replacement", PORT_TYPE_STRING)

/obj/item/circuit_component/compare/contains/replace/do_comparisons()
	var/to_find = needle.value
	var/to_search = haystack.value

	if(!to_find || !to_search)
		return

	var/to_replace = replacement.value

	return replacetext(to_search, to_find, to_replace)
