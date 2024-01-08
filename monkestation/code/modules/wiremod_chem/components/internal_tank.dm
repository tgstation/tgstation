/obj/item/circuit_component/chem/internal_tank
	display_name = "Internal Chemical Tank"
	desc = "Holds chemicals inside your circuit."
	category = "Chemistry"
	power_usage_per_input = 1

	ui_buttons = list(
		"plus" = "add",
		"minus" = "remove"
	)

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/datum/port/output/chemical_output
	/// our input nodes
	var/list/chemical_inputs
	var/datum/port/input/heat_input

	var/datum/reagents/reagent_holder
	var/datum/reagents/transferrance
	var/datum/port/input/reagent_amount
	var/datum/port/input/handle_input

/obj/item/circuit_component/chem/internal_tank/Initialize(mapload)
	. = ..()
	reagent_holder = new /datum/reagents(10000)
	reagent_holder.my_atom = src
	transferrance = new /datum/reagents(10000)
	transferrance.my_atom = src

/obj/item/circuit_component/chem/internal_tank/Destroy()
	. = ..()
	QDEL_NULL(reagent_holder)
	QDEL_NULL(transferrance)

/obj/item/circuit_component/chem/internal_tank/populate_ports()
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
	reagent_amount = add_input_port("Reagent Output Amount", PORT_TYPE_NUMBER)
	chemical_output = add_output_port("Reagent Output", PORT_TYPE_CHEMICAL_LIST)
	handle_input = add_input_port("Handle Input", PORT_TYPE_SIGNAL, trigger = PROC_REF(handle_input))

/obj/item/circuit_component/chem/internal_tank/input_received(datum/port/input/port, list/return_values)
	var/sane_number = clamp(reagent_amount.value, 0, 1000)

	reagent_holder.trans_to(transferrance, sane_number)

	var/list/reagent_pre_wipe = list()
	for(var/datum/reagent/reagent as anything in transferrance.reagent_list)
		reagent_pre_wipe += reagent.type
		reagent_pre_wipe[reagent.type] = reagent.volume

	chemical_output.set_output(reagent_pre_wipe)
	transferrance.clear_reagents()

/obj/item/circuit_component/chem/internal_tank/proc/handle_input(datum/port/input/port, list/return_values)
	var/list/ports = chemical_inputs.Copy()
	var/list/chemical_list = list()
	var/sane_heat = clamp(heat_input.value, 4, 1000)

	for(var/datum/port/input/input_port as anything in ports)
		chemical_list += input_port.value

	reagent_holder.add_reagent_list(chemical_list, temperature = sane_heat)

	after_work_call()

/obj/item/circuit_component/chem/internal_tank/after_work_call()
	clear_all_temp_ports()

/obj/item/circuit_component/chem/internal_tank/clear_all_temp_ports()
	chemical_output.value = null
	for(var/datum/port/input/input as anything in chemical_inputs)
		input.value = null
