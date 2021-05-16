/**
 * # Comparison Component
 *
 * Compares two objects
 */
/obj/item/component/comparison
	display_name = "Comparison"

	/// First object to compare
	var/datum/port/input/compareA
	/// Second object to compare
	var/datum/port/input/compareB

	/// Result of the comparison.
	var/datum/port/output/true
	var/datum/port/output/false

GLOBAL_LIST_INIT(comp_comparison_options, list(
	COMP_COMPARISON_EQUAL,
	COMP_COMPARISON_NOT_EQUAL,
	COMP_COMPARISON_GREATER_THAN,
	COMP_COMPARISON_LESS_THAN,
	COMP_COMPARISON_GREATER_THAN_OR_EQUAL,
	COMP_COMPARISON_LESS_THAN_OR_EQUAL
))

/obj/item/component/comparison/Initialize()
	options = GLOB.comp_comparison_options
	. = ..()
	compareA = add_input_port("A", PORT_TYPE_ANY)
	compareB = add_input_port("B", PORT_TYPE_ANY)

	true = add_output_port("True", PORT_TYPE_NUMBER)
	false = add_output_port("False", PORT_TYPE_NUMBER)

/obj/item/component/comparison/Destroy()
	true = null
	false = null
	return ..()

/obj/item/component/comparison/input_received()
	. = ..()
	if(.)
		return

	var/result = FALSE
	switch(current_option)
		if(COMP_COMPARISON_EQUAL)
			result = compareA.input_value == compareB.input_value
		if(COMP_COMPARISON_NOT_EQUAL)
			result = compareA.input_value != compareB.input_value
		if(COMP_COMPARISON_GREATER_THAN)
			result = compareA.input_value > compareB.input_value
		if(COMP_COMPARISON_GREATER_THAN_OR_EQUAL)
			result = compareA.input_value >= compareB.input_value
		if(COMP_COMPARISON_LESS_THAN)
			result = compareA.input_value < compareB.input_value
		if(COMP_COMPARISON_LESS_THAN_OR_EQUAL)
			result = compareA.input_value <= compareB.input_value

	// Sends an output to the appropriate port
	if(result)
		true.set_output(result)
	else
		false.set_output(result)
