/**
 * # To Icon Component
 *
 * Converts a string into an icon. Useful for setting vars.
 */
/obj/item/circuit_component/to_icon
	display_name = "String To Icon"
	desc = "Converts a string into a typepath. Useful for setting vars."
	category = "Admin"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL|CIRCUIT_FLAG_ADMIN

	/// The input filepath to convert into an icon
	var/datum/port/input/input_path

	/// The icon output
	var/datum/port/output/icon_output

/obj/item/circuit_component/to_icon/populate_ports()
	input_path = add_input_port("Icon File", PORT_TYPE_STRING)
	icon_output = add_output_port("Icon", PORT_TYPE_ANY)

/obj/item/circuit_component/to_icon/input_received(datum/port/input/port)
	icon_output.set_output(icon(input_path.value))

