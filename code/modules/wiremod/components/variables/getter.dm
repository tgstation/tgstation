/**
 * # Getter Component
 *
 * Gets the current value from a variable.
 */
/obj/item/circuit_component/variable/getter
	display_name = "Variable Getter"
	desc = "A component that gets a variable globally on the circuit."

	/// The value of the variable
	var/datum/port/output/value

	circuit_size = 0

/obj/item/circuit_component/variable/getter/populate_ports()
	value = add_output_port("Value", PORT_TYPE_ANY)

/obj/item/circuit_component/variable/getter/pre_input_received(datum/port/input/port)
	. = ..()
	if(current_variable)
		value.set_datatype(current_variable.datatype)
		value.set_value(current_variable.value)
