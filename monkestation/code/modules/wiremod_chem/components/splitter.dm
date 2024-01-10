/obj/item/circuit_component/chem/splitter
	display_name = "Chemical Splitter"
	desc = "General chemical splitter."
	category = "Chemistry"

	ui_buttons = list(
		"plus" = "add",
		"minus" = "remove"
	)

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/list/splitter_outputs
	/// our input node
	var/datum/port/input/chemical_input


/obj/item/circuit_component/chem/splitter/populate_ports()
	splitter_outputs = list()
	AddComponent(/datum/component/circuit_component_add_port, \
		port_list = splitter_outputs, \
		add_action = "add", \
		remove_action = "remove", \
		port_type = PORT_TYPE_CHEMICAL_LIST, \
		prefix = "Split Output", \
		minimum_amount = 2, \
		is_output = TRUE, \
		is_singular = TRUE, \
	)
	chemical_input = add_input_port("Chemical Input", PORT_TYPE_CHEMICAL_LIST, order = 1.1)


/obj/item/circuit_component/chem/splitter/input_received(datum/port/input/port, list/return_values)
	var/split_count = length(splitter_outputs)
	var/list/outputs = splitter_outputs.Copy()

	var/list/inputs = chemical_input.value
	var/list/single_output_list = list()

	for(var/name in inputs)
		single_output_list |= name
		single_output_list[name] += (inputs[name] / split_count)

	for(var/datum/port/output/output as anything in outputs)
		output.set_output(single_output_list)


/obj/item/circuit_component/chem/splitter/after_work_call()
	clear_all_temp_ports()

/obj/item/circuit_component/chem/splitter/clear_all_temp_ports()
	for(var/datum/port/output/output as anything in splitter_outputs)
		output.value = null
	chemical_input.value = null
