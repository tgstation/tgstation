/**
 * # Pressure Sensor Component
 *
 * When triggered, returns enviromental pressure in kPa
 */
/obj/item/circuit_component/pressure
	display_name = "Pressure Sensor"

	has_trigger = TRUE

	/// Enviromental pressure in kPa
	var/datum/port/output/output

/obj/item/circuit_component/pressure/Initialize()
	. = ..()
	output = add_output_port("Current Pressure", PORT_TYPE_NUMBER)

/obj/item/circuit_component/pressure/Destroy()
	output = null
	return ..()

/obj/item/circuit_component/pressure/input_received(datum/port/input/port)
	. = ..()
	if(.)
		return

	var/datum/gas_mixture/air = return_air()
	var/pressure = air.return_pressure()
	output.set_output(round(pressure, 0.1))
	trigger_output.set_output(COMPONENT_SIGNAL)
