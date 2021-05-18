/**
 * # RAM Component
 *
 * Stores the current input when triggered.
 * Players will need to think logically when using the RAM component
 * as there can be race conditions due to the delays of transferring signals
 */
/obj/item/component/ram
	display_name = "RAM"

	/// The input to store
	var/datum/port/input/input_port
	/// The trigger to store the current value of the input
	var/datum/port/input/trigger

	/// The current set value
	var/datum/port/output/output

/obj/item/component/ram/Initialize()
	. = ..()
	input_port = add_input_port("Input", PORT_TYPE_NUMBER, FALSE)
	trigger = add_input_port("Store", PORT_TYPE_ANY)

	output = add_output_port("Stored Value", PORT_TYPE_ANY)

/obj/item/component/ram/Destroy()
	input_port = null
	trigger = null
	output = null
	return ..()

/obj/item/component/ram/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(!COMPONENT_TRIGGERED_BY(trigger))
		return

	var/input_val = input_port.input_value

	output.set_output(input_val)
