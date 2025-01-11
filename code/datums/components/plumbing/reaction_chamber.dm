/datum/component/plumbing/reaction_chamber
	demand_connects = NORTH
	supply_connects = SOUTH

/datum/component/plumbing/reaction_chamber/Initialize(start=TRUE, _ducting_layer, _turn_connects=TRUE, datum/reagents/custom_receiver)
	. = ..()
	if(!istype(parent, /obj/machinery/plumbing/reaction_chamber))
		return COMPONENT_INCOMPATIBLE

/datum/component/plumbing/reaction_chamber/can_give(amount, reagent, datum/ductnet/net)
	. = FALSE

	var/obj/machinery/plumbing/reaction_chamber/reaction_chamber = parent

	//cannot give when we outselves are requesting or reacting the reagents
	if(amount <= 0 || !reagents.total_volume || !reaction_chamber.emptying || reagents.is_reacting)
		return

	//check to see if we can give catalysts only if they are in excess
	var/list/datum/reagent/catalysts = reaction_chamber.catalysts
	for(var/datum/reagent/chemical as anything in reagents.reagent_list)
		if(reagent && chemical.type != reagent)
			continue

		//we have the exact amounts so no excess to spare
		if(chemical.volume <= (catalysts[chemical.type] || 0))
			if(reagent)
				break
			else
				continue

		//atleast 1 reagent to give so take whatever
		return TRUE

/datum/component/plumbing/reaction_chamber/send_request(dir)
	var/obj/machinery/plumbing/reaction_chamber/chamber = parent

	if(chamber.emptying)
		return

	//take in reagents
	var/present_amount
	var/diff
	var/list/datum/reagent/required_reagents = chamber.catalysts | chamber.required_reagents
	for(var/datum/reagent/required_reagent as anything in required_reagents)
		//find how much amount is already present if at all and get the reagent reference
		present_amount = 0
		for(var/datum/reagent/present_reagent as anything in reagents.reagent_list)
			if(required_reagent == present_reagent.type)
				present_amount = present_reagent.volume
				break

		//compute how much more is needed
		diff = min(required_reagents[required_reagent] - present_amount, MACHINE_REAGENT_TRANSFER)
		if(diff >= CHEMICAL_QUANTISATION_LEVEL) // the closest we can ask for so values like 0.9999 become 1
			process_request(diff, required_reagent, dir)
			if(!chamber.catalysts[required_reagent]) //only block if not a catalyst as they can come in whenever they are available
				return

	reagents.flags &= ~NO_REACT
	reagents.handle_reactions()

	chamber.emptying = TRUE //If we move this up, it'll instantly get turned off since any reaction always sets the reagent_total to zero. Other option is make the reaction update
	//everything for every chemical removed, wich isn't a good option either.
	chamber.on_reagent_change(reagents) //We need to check it now, because some reactions leave nothing left.
	if(chamber.emptying) //if we are still emptying then keep checking for reagents until we are emptied out
		chamber.RegisterSignal(reagents, COMSIG_REAGENTS_HOLDER_UPDATED, TYPE_PROC_REF(/obj/machinery/plumbing/reaction_chamber, on_reagent_change))

///Special connect that we currently use for reaction chambers. Being used so we can keep certain inputs separate, like into a special internal acid container
/datum/component/plumbing/acidic_input
	demand_connects = WEST
	demand_color = COLOR_YELLOW
	ducting_layer = SECOND_DUCT_LAYER

/datum/component/plumbing/acidic_input/send_request(dir)
	process_request(reagent = /datum/reagent/reaction_agent/acidic_buffer, dir = dir)

///Special connect that we currently use for reaction chambers. Being used so we can keep certain inputs separate, like into a special internal base container
/datum/component/plumbing/alkaline_input
	demand_connects = EAST
	demand_color = COLOR_VIBRANT_LIME
	ducting_layer = FOURTH_DUCT_LAYER

/datum/component/plumbing/alkaline_input/send_request(dir)
	process_request(reagent = /datum/reagent/reaction_agent/basic_buffer, dir = dir)


