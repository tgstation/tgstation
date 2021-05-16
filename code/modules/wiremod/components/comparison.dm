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

	/// Result of the comparison
	var/datum/port/output/output

GLOBAL_LIST_INIT(comparison_options, list(
	COMPARISON_EQUAL,
	COMPARISON_NOT_EQUAL,
	COMPARISON_GREATER_THAN,
	COMPARISON_LESS_THAN,
	COMPARISON_GREATER_THAN_OR_EQUAL,
	COMPARISON_LESS_THAN_OR_EQUAL
))

/obj/item/component/comparison/Initialize()
	options = GLOB.comparison_options
	. = ..()
	compareA = add_input_port("A", PORT_TYPE_ANY)
	compareB = add_input_port("B", PORT_TYPE_ANY)

	output = add_output_port("Result", PORT_TYPE_NUMBER)

/obj/item/component/comparison/Destroy()
	output = null
	return ..()

/obj/item/component/comparison/set_option(option)
	. = ..()
	input_received()

/obj/item/component/comparison/input_received()
	. = ..()
	if(.)
		return

	var/result = FALSE
	switch(current_option)
		if(COMPARISON_EQUAL)
			result = compareA.input_value == compareB.input_value
		if(COMPARISON_NOT_EQUAL)
			result = compareA.input_value != compareB.input_value
		if(COMPARISON_GREATER_THAN)
			result = compareA.input_value > compareB.input_value
		if(COMPARISON_GREATER_THAN_OR_EQUAL)
			result = compareA.input_value >= compareB.input_value
		if(COMPARISON_LESS_THAN)
			result = compareA.input_value < compareB.input_value
		if(COMPARISON_LESS_THAN_OR_EQUAL)
			result = compareA.input_value <= compareB.input_value

	output.set_output(result)
