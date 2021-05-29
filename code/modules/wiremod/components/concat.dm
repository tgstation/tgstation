/**
 * # Concatenate Component
 *
 * General string concatenation component. Puts strings together.
 */
/obj/item/circuit_component/concat
	display_name = "Concatenate"

	/// The amount of input ports to have
	var/input_port_amount = 4

	/// The result from the output
	var/datum/port/output/output
	has_trigger = TRUE

/obj/item/circuit_component/concat/Initialize()
	. = ..()
	for(var/port_id in 1 to input_port_amount)
		var/letter = ascii2text(text2ascii("A") + (port_id-1))
		add_input_port(letter, PORT_TYPE_STRING)

	output = add_output_port("Output", PORT_TYPE_STRING)

/obj/item/circuit_component/concat/Destroy()
	output = null
	return ..()

/obj/item/circuit_component/concat/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/result = ""
	var/list/ports = input_ports.Copy()
	ports -= trigger_input

	for(var/datum/port/input/input_port as anything in ports)
		var/value = input_port.input_value
		if(isnull(value))
			continue

		result += "[value]"

	output.set_output(result)
	trigger_output.set_output(COMPONENT_SIGNAL)
