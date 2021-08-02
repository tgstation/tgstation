/**
 * # To Type Component
 *
 * Converts a string into a typepath. Useful for adding components.
 */
/obj/item/circuit_component/to_type
	display_name = "String To Type"
	desc = "A component that returns the value of a list at a given index."
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	/// The input path to convert into a typepath
	var/datum/port/input/input_path

	/// The type output
	var/datum/port/output/type_output

/obj/item/circuit_component/to_type/Initialize()
	. = ..()
	input_path = add_input_port("Type", PORT_TYPE_STRING)
	type_output = add_output_port("Typepath", PORT_TYPE_ANY)

/obj/item/circuit_component/to_type/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	type_output.set_output(text2path(input_path.input_value))

