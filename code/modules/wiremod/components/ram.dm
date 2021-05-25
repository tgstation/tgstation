/**
 * # RAM Component
 *
 * Stores the current input when triggered.
 * Players will need to think logically when using the RAM component
 * as there can be race conditions due to the delays of transferring signals
 */
/obj/item/circuit_component/ram
	display_name = "RAM"

	/// The input to store
	var/datum/port/input/input_port
	/// The trigger to store the current value of the input
	var/datum/port/input/trigger
	/// Clears the current input
	var/datum/port/input/clear

	/// The current set value
	var/datum/port/output/output

/obj/item/circuit_component/ram/Initialize()
	. = ..()
	input_port = add_input_port("Input", PORT_TYPE_ANY)
	trigger = add_input_port("Store", PORT_TYPE_SIGNAL)
	clear = add_input_port("Clear", PORT_TYPE_SIGNAL)

	output = add_output_port("Stored Value", PORT_TYPE_ANY)

/obj/item/circuit_component/ram/Destroy()
	input_port = null
	trigger = null
	clear = null
	output = null
	return ..()

/obj/item/circuit_component/ram/input_received(datum/port/input/port)
	. = ..()
	match_port_datatype(input_port, output)
	if(.)
		return

	if(COMPONENT_TRIGGERED_BY(clear, port))
		output.set_output(null)
		return

	if(!COMPONENT_TRIGGERED_BY(trigger, port))
		return

	var/input_val = input_port.input_value

	output.set_output(input_val)
