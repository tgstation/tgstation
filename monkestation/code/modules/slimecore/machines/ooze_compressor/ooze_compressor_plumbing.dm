/datum/component/plumbing/ooze_compressor
	demand_connects = NORTH

/datum/component/plumbing/ooze_compressor/Initialize(start=TRUE, _ducting_layer, _turn_connects=TRUE, datum/reagents/custom_receiver)
	. = ..()
	if(!istype(parent, /obj/machinery/plumbing/ooze_compressor))
		return COMPONENT_INCOMPATIBLE

/datum/component/plumbing/ooze_compressor/send_request(dir)
	var/obj/machinery/plumbing/ooze_compressor/chamber = parent
	if(chamber.compressing || !chamber.current_recipe)
		return
	var/present_amount
	var/diff
	for(var/required_reagent in chamber.reagents_for_recipe)
		//find how much amount is already present if at all
		present_amount = 0
		for(var/datum/reagent/containg_reagent as anything in reagents.reagent_list)
			if(required_reagent == containg_reagent.type)
				present_amount = containg_reagent.volume
				break

		//compute how much more is needed and round it
		diff = chamber.reagents_for_recipe[required_reagent] - present_amount
		if(diff >= CHEMICAL_QUANTISATION_LEVEL * 10) //should be safe even after rounding
			process_request(min(diff, MACHINE_REAGENT_TRANSFER), required_reagent, dir)
			return

	chamber.compress_recipe() //If we move this up, it'll instantly get turned off since any reaction always sets the reagent_total to zero. Other option is make the reaction update
	//everything for every chemical removed, wich isn't a good option either.
	chamber.on_reagent_change(reagents) //We need to check it now, because some reactions leave nothing left.
