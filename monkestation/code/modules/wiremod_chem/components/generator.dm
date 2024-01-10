/obj/item/circuit_component/chem/synthesizer
	display_name = "Chemical Synthesizer"
	desc = "General chemical synthesizer component."
	category = "Chemistry"
	power_usage_per_input = 1

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
		/datum/reagent/silver,
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


/obj/item/circuit_component/chem/synthesizer/check_power_modifictions()
	var/units = per_chemical_amount?.value
	if(!parent.shell)
		return power_usage_per_input * 25 * units

	var/obj/structure/chemical_manufacturer/host = parent.shell
	if(!istype(host, /obj/structure/chemical_manufacturer))
		return power_usage_per_input * 25 * units// even worse if we manage to get this in a non manufactured cell

	if(!host.has_precursor(units))
		var/precursor = host.connected_tank?.stored_precursor
		units = units - precursor
		host.process_precursor(units)
		return power_usage_per_input * 5 * units

	host.process_precursor(units)
	return power_usage_per_input

/obj/item/circuit_component/chem/synthesizer/populate_ports()
	output = add_output_port("Output", PORT_TYPE_CHEMICAL_LIST, order = 1.1)

	per_chemical_amount = add_input_port("Units", PORT_TYPE_NUMBER, default = 1)

/obj/item/circuit_component/chem/synthesizer/input_received(datum/port/input/port, list/return_values)
	if(!chemical_to_generate?.value)
		return
	var/list/built_output = list()
	built_output += reagent_list[chemical_to_generate.value]
	built_output[reagent_list[chemical_to_generate.value]] = min(max(per_chemical_amount.value, 0), 100)

	output.set_output(built_output)
