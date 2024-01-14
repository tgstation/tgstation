/obj/item/circuit_component/chem/mixer
	display_name = "Chemical Mixer"
	desc = "Mixes chemicals."
	category = "Chemistry"
	power_usage_per_input = 40

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/list/chemical_inputs
	var/datum/port/input/heat_input
	var/datum/port/output/output
	var/datum/reagents/reagent_holder

	ui_buttons = list(
		"plus" = "add",
		"minus" = "remove"
	)

/obj/item/circuit_component/chem/mixer/Initialize(mapload)
	. = ..()
	reagent_holder = new /datum/reagents(10000)
	reagent_holder.my_atom = src

/obj/item/circuit_component/chem/mixer/Destroy()
	. = ..()
	qdel(reagent_holder)

/obj/item/circuit_component/chem/mixer/populate_ports()
	chemical_inputs = list()
	AddComponent(/datum/component/circuit_component_add_port, \
		port_list = chemical_inputs, \
		add_action = "add", \
		remove_action = "remove", \
		port_type = PORT_TYPE_CHEMICAL_LIST, \
		prefix = "Chemical Input", \
		minimum_amount = 2 \
	)
	heat_input = add_input_port("Desired Heat", PORT_TYPE_NUMBER, default = 275)
	output = add_output_port("Output", PORT_TYPE_CHEMICAL_LIST, order = 1.1, port_type = /datum/port/output/singular)

/obj/item/circuit_component/chem/mixer/input_received(datum/port/input/port, list/return_values)

	var/list/ports = chemical_inputs.Copy()
	var/list/chemical_list = list()
	var/sane_heat = clamp(heat_input.value, 4, 1000)

	for(var/datum/port/input/input_port as anything in ports)
		chemical_list += input_port.value

	reagent_holder.add_reagent_list(chemical_list, temperature = sane_heat)
	reagent_holder.handle_reactions()
	var/list/reagent_pre_wipe = list()
	for(var/datum/reagent/reagent as anything in reagent_holder.reagent_list)
		reagent_pre_wipe += reagent.type
		reagent_pre_wipe[reagent.type] = reagent.volume

	output.set_output(reagent_pre_wipe)
	reagent_holder.clear_reagents()

/obj/item/circuit_component/chem/mixer/after_work_call()
	clear_all_temp_ports()

/obj/item/circuit_component/chem/mixer/clear_all_temp_ports()
	for(var/datum/port/input/input as anything in chemical_inputs)
		input.value = null
	output.value = null
