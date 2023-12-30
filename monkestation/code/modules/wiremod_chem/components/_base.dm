/obj/item/circuit_component/chem
	category = "Chemistry"
	power_usage_per_input = 10

/obj/item/circuit_component/chem/proc/clear_all_temp_ports()
	for(var/datum/port/output/output as anything in output_ports)
		output.value = null
	for(var/datum/port/input/input as anything in input_ports)
		input.value = null

