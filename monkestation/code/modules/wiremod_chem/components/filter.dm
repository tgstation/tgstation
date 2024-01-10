/obj/item/circuit_component/chem/filter
	display_name = "Chemical Filter"
	desc = "General chemical filter."
	category = "Chemistry"
	power_usage_per_input = 25

	///this is our chosen chemical
	var/datum/port/input/chemical_input

	var/datum/port/input/filter_list

	///this is where the chemicals get shot out from
	var/datum/port/output/filtered_output
	///this is where the chemicals get shot out from
	var/datum/port/output/junk_output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL



/obj/item/circuit_component/chem/filter/populate_ports()
	. = ..()
	chemical_input = add_input_port("Chemicals", PORT_TYPE_CHEMICAL_LIST)
	filtered_output = add_output_port("Filtered Chemicals", PORT_TYPE_CHEMICAL_LIST, port_type = /datum/port/output/singular)
	junk_output = add_output_port("Unfiltered Chemicals", PORT_TYPE_CHEMICAL_LIST, port_type = /datum/port/output/singular)
	filter_list = add_input_port("Filter List", PORT_TYPE_LIST(PORT_TYPE_STRING))

/obj/item/circuit_component/chem/filter/input_received(datum/port/input/port, list/return_values)
	var/list/chemicals_from_names = list()
	var/list/chemical_names = list()
	chemical_names += filter_list.value

	for(var/name as anything in chemical_names)
		chemicals_from_names += GLOB.name2reagent[ckey(lowertext(name))]

	var/list/inputted_chemicals = chemical_input.value

	var/list/output_reagents = list()
	var/list/rest_reagents = list()
	for(var/datum/reagent/reagent as anything in chemicals_from_names)
		if(reagent in inputted_chemicals)
			output_reagents += reagent
			output_reagents[reagent] = inputted_chemicals[reagent]
		else
			rest_reagents += reagent
			rest_reagents[reagent] = inputted_chemicals[reagent]

	junk_output.set_output(rest_reagents)
	filtered_output.set_output(output_reagents)

/obj/item/circuit_component/chem/filter/after_work_call()
	clear_all_temp_ports()

/obj/item/circuit_component/chem/filter/clear_all_temp_ports()
	chemical_input.value = null
	filtered_output.value = null
	junk_output.value = null
