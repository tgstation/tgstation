/**
 * # Random Component
 *
 * Generates a random number between specific values
 */
/obj/item/circuit_component/random
	display_name = "Random"
	desc = "A component that returns random values."
	category = "Math"

	/// The minimum value that the random number can be
	var/datum/port/input/minimum
	/// The maximum value that the random number can be
	var/datum/port/input/maximum

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The result from the output
	var/datum/port/output/output

/obj/item/circuit_component/random/populate_ports()
	minimum = add_input_port("Minimum", PORT_TYPE_NUMBER, trigger = null)
	maximum = add_input_port("Maximum", PORT_TYPE_NUMBER, trigger = null)

	output = add_output_port("Output", PORT_TYPE_NUMBER)

/obj/item/circuit_component/random/input_received(datum/port/input/port)

	var/min_val = minimum.value || 0
	var/max_val = maximum.value || 0

	if(max_val < min_val)
		output.set_output(0)
		return

	output.set_output(rand(min_val, max_val))

