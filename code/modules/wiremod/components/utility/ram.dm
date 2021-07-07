/**
 * # RAM Component
 *
 * Stores the current input when triggered.
 * Players will need to think logically when using the RAM component
 * as there can be race conditions due to the delays of transferring signals
 */
/obj/item/circuit_component/ram
	display_name = "RAM"
	display_desc = "A component that retains a variable."
	circuit_flags = CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The input to store
	var/datum/port/input/input_port
	/// The trigger to store the current value of the input
	var/datum/port/input/trigger
	/// Clears the current input
	var/datum/port/input/clear

	/// The current set value
	var/datum/port/output/output

	var/current_type

/obj/item/circuit_component/ram/populate_options()
	var/static/component_options = list(
		PORT_TYPE_ANY,
		PORT_TYPE_STRING,
		PORT_TYPE_NUMBER,
		PORT_TYPE_LIST,
		PORT_TYPE_ATOM,
		PORT_TYPE_SIGNAL,
	)
	options = component_options

/obj/item/circuit_component/ram/Initialize()
	. = ..()
	current_type = current_option
	input_port = add_input_port("Input", current_type)
	trigger = add_input_port("Store", PORT_TYPE_SIGNAL)
	clear = add_input_port("Clear", PORT_TYPE_SIGNAL)

	output = add_output_port("Stored Value", current_type)

/obj/item/circuit_component/ram/Destroy()
	input_port = null
	trigger = null
	clear = null
	output = null
	return ..()

/obj/item/circuit_component/ram/input_received(datum/port/input/port)
	. = ..()
	if(current_type != current_option)
		current_type = current_option
		input_port.set_datatype(current_type)
		output.set_datatype(current_type)

	if(.)
		return

	if(COMPONENT_TRIGGERED_BY(clear, port))
		output.set_output(null)
		return

	if(!COMPONENT_TRIGGERED_BY(trigger, port))
		return TRUE

	var/input_val = input_port.input_value

	output.set_output(input_val)
