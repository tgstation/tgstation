/obj/item/circuit_component/chem/weighted_splitter
	display_name = "Weighted Chemical Splitter"
	desc = "General chemical splitter, allows more fine grain control."
	category = "Chemistry"
	power_usage_per_input = 20

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// our input a
	var/datum/port/input/chemical_input

	/// the output node that gets the weight
	var/datum/port/output/chemical_output
	/// the second output node
	var/datum/port/output/non_weighted_output


	///if we are a flat amount or precent amount
	var/datum/port/input/option/weight_type
	///the amount we weight out
	var/datum/port/input/number


/obj/item/circuit_component/chem/weighted_splitter/populate_options()
	weight_type = add_option_port("Weight Type", list("Precent", "Flat"))

/obj/item/circuit_component/chem/weighted_splitter/populate_ports()
	chemical_input = add_input_port("Chemicals", PORT_TYPE_CHEMICAL_LIST)
	number = add_input_port("Number", PORT_TYPE_NUMBER)

	chemical_output = add_output_port("Weighted Output", PORT_TYPE_CHEMICAL_LIST, port_type = /datum/port/output/singular)
	non_weighted_output = add_output_port("Secondary Output", PORT_TYPE_CHEMICAL_LIST, port_type = /datum/port/output/singular)

/obj/item/circuit_component/chem/weighted_splitter/input_received(datum/port/input/port, list/return_values)
	var/list/chemicals = chemical_input.value
	var/filter_amount = number.value
	if(filter_amount <= 0)
		return
	if(!length(chemicals))
		return

	var/filter_type = weight_type.value

	var/total_value = 0
	for(var/item in chemicals)
		total_value += chemicals[item]

	var/list/weighted_output = list()
	var/list/rest = list()

	switch(filter_type)
		if("Precent")
			filter_amount = clamp(filter_amount, 0, 100)
			for(var/item in chemicals)
				weighted_output += item
				weighted_output[item] = chemicals[item] / filter_amount
				chemicals[item] -= chemicals[item] / filter_amount
			rest = chemicals.Copy()

		if("Flat")
			filter_amount = max(filter_amount, 0)
			var/per_chemical_amount = filter_amount / length(chemicals)
			for(var/item in chemicals)
				weighted_output += item
				weighted_output[item] = min(per_chemical_amount, chemicals[item])
				chemicals[item] -= min(per_chemical_amount, chemicals[item])
			rest = chemicals.Copy()

	non_weighted_output.set_output(rest)
	chemical_output.set_output(weighted_output)

/obj/item/circuit_component/chem/weighted_splitter/after_work_call()
	clear_all_temp_ports()

/obj/item/circuit_component/chem/weighted_splitter/clear_all_temp_ports()
	chemical_output.value = null
	non_weighted_output.value = null
	chemical_input.value = null
