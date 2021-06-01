/**
 * # Gas Sensor Component
 *
 * Return amount of certain gas in the air(in moles)
 */
/obj/item/circuit_component/gas_sensor
	display_name = "Gas Sensor"

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/output

	has_trigger = TRUE

/obj/item/circuit_component/gas_sensor/Initialize()
	. = ..()

	input_port = add_input_port("Gas Name", PORT_TYPE_STRING)

	output = add_output_port("Gas Amount", PORT_TYPE_NUMBER)

/obj/item/circuit_component/gas_sensor/Destroy()
	input_port = null
	output = null
	return ..()

/obj/item/circuit_component/gas_sensor/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/datum/gas_mixture/air = return_air()
	var/gas_name = gas_name2path(input_port.input_value)
	if(gas_name = air.gases)
		output.set_output(air.gases[gas_name][MOLES])
		trigger_output.set_output(COMPONENT_SIGNAL)
