/obj/item/circuit_component/chem/synthesizer
	display_name = "Chemical Synthesizer"
	desc = "General chemical synthesizer component."
	category = "Chemistry"

	///this is our chosen chemical
	var/datum/port/input/option/chemical_to_generate

	///this is our amount
	var/datum/port/input/per_chemical_amount

	///this is where the chemicals get shot out from
	var/datum/port/output/output
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	//this is hellish, we go name = path so its easier for the ui
	var/list/dispensable_reagents = list(
		/datum/reagent/aluminium,
		/datum/reagent/bromine,
		/datum/reagent/carbon,
		/datum/reagent/chlorine,
		/datum/reagent/copper,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/fluorine,
		/datum/reagent/hydrogen,
		/datum/reagent/iodine,
		/datum/reagent/iron,
		/datum/reagent/lithium,
		/datum/reagent/mercury,
		/datum/reagent/nitrogen,
		/datum/reagent/oxygen,
		/datum/reagent/phosphorus,
		/datum/reagent/potassium,
		/datum/reagent/uranium/radium,
		/datum/reagent/silicon,
		/datum/reagent/sodium,
		/datum/reagent/stable_plasma,
		/datum/reagent/consumable/sugar,
		/datum/reagent/sulfur,
		/datum/reagent/toxin/acid,
		/datum/reagent/water,
		/datum/reagent/fuel,
	)
	///this is our built array of name = path
	var/list/reagent_list = list()

/obj/item/circuit_component/chem/synthesizer/populate_options()
	for(var/datum/reagent/reagent as anything in dispensable_reagents)
		reagent_list += initial(reagent.name)
		reagent_list[initial(reagent.name)] = reagent

	chemical_to_generate = add_option_port("Chemical", reagent_list)

/obj/item/circuit_component/chem/synthesizer/populate_ports()
	output = add_output_port("Output", PORT_TYPE_ASSOC_LIST(PORT_TYPE_DATUM, PORT_TYPE_NUMBER), order = 1.1)

	per_chemical_amount = add_input_port("Units", PORT_TYPE_NUMBER, default = 1)

/obj/item/circuit_component/chem/synthesizer/input_received(datum/port/input/port, list/return_values)
	if(!chemical_to_generate?.value)
		return
	var/list/built_output = list()
	built_output += reagent_list[chemical_to_generate.value]
	built_output[reagent_list[chemical_to_generate.value]] = min(max(per_chemical_amount.value, 0), 100)

	output.set_output(built_output)
