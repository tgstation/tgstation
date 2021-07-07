/**
 * # Flag Component
 *
 * When triggered, switches between outputting 0 or 1.
 */
/obj/item/circuit_component/flag
	display_name = "Flag"
	display_desc = "When triggered, this component will toggle between outputting either 0 or 1."
	circuit_flags = CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The trigger to store the current value of the input
	var/datum/port/input/trigger

	/// The current set value
	var/datum/port/output/output

	var/stored_val

/obj/item/circuit_component/flag/Initialize()
	. = ..()
	trigger = add_input_port("Toggle", PORT_TYPE_SIGNAL)

	output = add_output_port("Output", PORT_TYPE_NUMBER)

/obj/item/circuit_component/flag/Destroy()
	trigger = null
	output = null
	return ..()

/obj/item/circuit_component/flag/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	if(isnull(stored_val) || stored_val == 0)
		stored_val = 1
	else
		stored_val = 0

	output.set_output(stored_val)
