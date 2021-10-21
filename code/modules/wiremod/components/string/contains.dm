/**
 * # String Contains Component
 *
 * Checks if a string contains a word/letter
 */
/obj/item/circuit_component/compare/contains
	display_name = "String Contains"
	desc = "Checks if a string contains a word/letter"

	input_port_amount = 0

	var/datum/port/input/needle
	var/datum/port/input/haystack

/obj/item/circuit_component/compare/contains/populate_custom_ports()
	needle = add_input_port("Needle", PORT_TYPE_STRING)
	haystack = add_input_port("Haystack", PORT_TYPE_STRING)

/obj/item/circuit_component/compare/contains/Destroy()
	needle = null
	haystack = null
	return ..()


/obj/item/circuit_component/compare/contains/do_comparisons(list/ports)
	if(length(ports) < input_port_amount)
		return

	var/to_find = needle.value
	var/to_search = haystack.value

	if(!to_find || !to_search)
		return

	return findtext(to_search, to_find)
