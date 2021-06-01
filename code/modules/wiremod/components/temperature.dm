/**
 * # Temperature Sensor Component
 *
 * Return enviromental temperature in kelvins
 */
/obj/item/circuit_component/temperature
	display_name = "Temperature Sensor"

	/// The result from the output
	var/datum/port/output/output

	has_trigger = TRUE

/obj/item/circuit_component/temperature/Initialize()
	. = ..()

	output = add_output_port("Gas Amount", PORT_TYPE_NUMBER)

/obj/item/circuit_component/temperature/Destroy()
	output = null
	return ..()

/obj/item/circuit_component/temperature/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/datum/gas_mixture/air = return_air()

	output.set_output(air.temperature)
	trigger_output.set_output(COMPONENT_SIGNAL)
