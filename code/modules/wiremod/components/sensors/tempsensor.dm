/**
 * # Temperature Sensor
 *
 * Returns the temperature of the tile
 */
/obj/item/circuit_component/tempsensor
	display_name = "Temperature Sensor"
	desc = "Outputs the current temperature of the tile"
	category = "Sensor"

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// The result from the output
	var/datum/port/output/result

/obj/item/circuit_component/tempsensor/populate_ports()
	result = add_output_port("Result", PORT_TYPE_NUMBER)

/obj/item/circuit_component/tempsensor/input_received(datum/port/input/port)
	//Get current turf
	var/turf/location = get_location()
	if(!location)
		result.set_output(null)
		return
	//Get environment info
	var/datum/gas_mixture/environment = location.return_air()
	var/total_moles = environment.total_moles()
	if(total_moles)
		//If there's atmos, return temperature
		result.set_output(round(environment.temperature,1))
	else
		result.set_output(0)

