/obj/item/circuit_component/chem/bci/bloodstream
	display_name = "Chemical Pump Integration"
	desc  = "A component that integrates directly into your veins to inject you with a reagents."
	power_usage_per_input = 1

	var/datum/port/input/input_reagents
	var/datum/port/input/input_heat
	var/last_message = 0


/obj/item/circuit_component/chem/bci/bloodstream/populate_ports()
	input_heat = add_input_port("Desired Heat", PORT_TYPE_NUMBER, default = 275)
	input_reagents = add_input_port("Chemical Input", PORT_TYPE_CHEMICAL_LIST, order = 1.1)


/obj/item/circuit_component/chem/bci/bloodstream/input_received(datum/port/input/port, list/return_values)
	if(!bci)
		return
	var/mob/living/owner = bci.owner

	owner.reagents.add_reagent_list(input_reagents.value, temperature = input_heat.value)

	if(last_message >= world.time + 5 SECONDS)
		return
	to_chat(owner, span_notice("You feel chemicals pumping into your veins"))
	last_message = world.time


/obj/item/circuit_component/chem/bci/bloodstream/after_work_call()
	clear_all_temp_ports()

/obj/item/circuit_component/chem/bci/bloodstream/clear_all_temp_ports()
	input_reagents.value = null
