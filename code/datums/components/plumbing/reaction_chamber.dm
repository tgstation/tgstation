/datum/component/plumbing/reaction_chamber
	demand_connects = NORTH
	supply_connects = SOUTH

/datum/component/plumbing/reaction_chamber/Initialize(start=TRUE, _ducting_layer, _turn_connects=TRUE, datum/reagents/custom_receiver)
	. = ..()
	if(!istype(parent, /obj/machinery/plumbing/reaction_chamber))
		return COMPONENT_INCOMPATIBLE

/datum/component/plumbing/reaction_chamber/can_give(amount, reagent, datum/ductnet/net)
	. = ..()
	var/obj/machinery/plumbing/reaction_chamber/reaction_chamber = parent
	if(!. || !reaction_chamber.emptying || reagents.is_reacting)
		return FALSE

/datum/component/plumbing/reaction_chamber/send_request(dir)
	var/obj/machinery/plumbing/reaction_chamber/chamber = parent
	if(chamber.emptying)
		return
	var/required_amount = 0
	var/total_present_amount = 0
	var/total_required_amount = 0

	//take in reagents
	var/datum/reagent/present_reagent
	var/present_amount
	var/diff
	for(var/required_reagent in chamber.required_reagents)
		//compute total required amount from all reagents
		required_amount = chamber.required_reagents[required_reagent]
		total_required_amount += required_amount

		//find how much amount is already present if at all and get the reagent reference
		present_reagent = null
		for(var/datum/reagent/containg_reagent as anything in reagents.reagent_list)
			if(required_reagent == containg_reagent.type)
				present_reagent = containg_reagent
				break
		present_amount = present_reagent ? present_reagent.volume : 0

		//compute how much more is needed and round it. early return only if the request succeded
		diff = min(required_amount - present_amount, MACHINE_REAGENT_TRANSFER)
		if(diff >= CHEMICAL_VOLUME_ROUNDING && process_request(diff, required_reagent, dir))
			return
		total_present_amount += present_reagent ? present_reagent.volume : 0

	//do we have close enough
	if(total_required_amount - total_present_amount >= CHEMICAL_VOLUME_ROUNDING) //nope
		return

	reagents.flags &= ~NO_REACT
	reagents.handle_reactions()

	chamber.emptying = TRUE //If we move this up, it'll instantly get turned off since any reaction always sets the reagent_total to zero. Other option is make the reaction update
	//everything for every chemical removed, wich isn't a good option either.
	chamber.on_reagent_change(reagents) //We need to check it now, because some reactions leave nothing left.

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


