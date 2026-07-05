/**
 * # Regex Contains Component
 *
 * Utilizes a regular expression to check if a string contains a set of words
 */
/obj/item/circuit_component/compare/contains/regex
	display_name = "Regex Contains"
	desc = "Utilizes a regular expression to check if a string contains a pattern of words."
	result_port_type = PORT_TYPE_STRING

	var/datum/port/input/regex_flags
	var/regex/current_regex

/obj/item/circuit_component/compare/contains/regex/populate_custom_ports()
	. = ..()
	regex_flags = add_input_port("Regex Flags", PORT_TYPE_STRING, default = "g")

/obj/item/circuit_component/compare/contains/regex/input_received(datum/port/input/port, list/return_values)
	if(COMPONENT_TRIGGERED_BY(regex_flags, port)  || COMPONENT_TRIGGERED_BY(needle, port))
		make_regex()
		return
	return ..()

/obj/item/circuit_component/compare/contains/regex/proc/make_regex()
	var/regex_text = needle.value
	if(!regex_text)
		current_regex = null
		return
	var/sanitized_text = sanitize(html_encode(regex_text))
	var/flags = replacetext(regex_flags.value, regex(@"[^igm]"), "")
	current_regex = regex(sanitized_text, flags)

/obj/item/circuit_component/compare/contains/regex/do_comparisons()
	var/to_search = haystack.value
	if(!to_search || isnull(current_regex))
		return
	current_regex.Find(to_search)
	return current_regex.match

/obj/item/circuit_component/compare/contains/regex/get_ui_notices()
	. = ..()
	. += create_ui_notice("used regex: https://www.byond.com/docs/ref/#/{notes}/regex", "info")

/**
 * # Regex Replace Component
 *
 * Utilizes a regular expression to replace a set of words in a string contains with another
 */
/obj/item/circuit_component/compare/contains/regex/replace
	display_name = "Regex Replace"
	desc = "Utilizes a regular expression to replace a pattern of words in a string."

	var/datum/port/input/replacement

/obj/item/circuit_component/compare/contains/regex/replace/populate_custom_ports()
	. = ..()
	needle = add_input_port("Replacement", PORT_TYPE_STRING)

/obj/item/circuit_component/compare/contains/regex/replace/do_comparisons()
	var/to_search = haystack.value
	if(!to_search || isnull(current_regex))
		return
	var/to_replace = replacement.value
	return current_regex.Replace(to_search, to_replace)
