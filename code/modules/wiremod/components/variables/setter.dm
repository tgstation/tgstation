/**
 * # Setter Component
 *
 * Stores the current input when triggered into a variable.
 */
/obj/item/circuit_component/variable/setter
	display_name = "Variable Setter"
	desc = "A component that sets a variable globally on the circuit."

	/// The input to store
	var/datum/port/input/input_port

	circuit_size = 0

/obj/item/circuit_component/variable/setter/get_variable_list(obj/item/integrated_circuit/integrated_circuit)
	return integrated_circuit.modifiable_circuit_variables

/obj/item/circuit_component/variable/setter/populate_ports()
	input_port = add_input_port("Input", PORT_TYPE_ANY)

/obj/item/circuit_component/variable/setter/pre_input_received(datum/port/input/port)
	. = ..()
	if(port == variable_name)
		input_port.set_datatype(current_variable.datatype)

/obj/item/circuit_component/variable/setter/input_received(datum/port/input/port)
	if(!current_variable)
		return
	current_variable.set_value(input_port.value)

