// specific demand is a neutered version of the reaction chamber that simply takes specific reagents.
/datum/component/plumbing/specific_demand
	demand_connects = SOUTH

/datum/component/plumbing/specific_demand/Initialize(start=TRUE, _turn_connects=TRUE)
	. = ..()
	if(!istype(parent, /obj/machinery/plumbing))
		return COMPONENT_INCOMPATIBLE

/datum/component/plumbing/specific_demand/send_request(dir)
	var/obj/machinery/plumbing/RC = parent
	if(!LAZYLEN(RC.required_reagents))
		return
	for(var/RT in RC.required_reagents)
		var/has_reagent = FALSE
		for(var/A in reagents.reagent_list)
			var/datum/reagent/RD = A
			if(RT == RD.type)
				has_reagent = TRUE
				if(RD.volume < RC.required_reagents[RT])
					process_request(min(RC.required_reagents[RT] - RD.volume, MACHINE_REAGENT_TRANSFER) , RT, dir)
					return
		if(!has_reagent)
			process_request(min(RC.required_reagents[RT], MACHINE_REAGENT_TRANSFER), RT, dir)
			return

	// we want to includ reaction handling here so people can't do a 7/7 mix of potassium/water and just stingbomb people.
	reagents.flags &= ~NO_REACT
	reagents.handle_reactions()
	RC.on_reagent_change() //We need to check it now, because some reactions leave nothing left.

