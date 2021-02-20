/datum/component/plumbing/reaction_chamber
	demand_connects = NORTH
	supply_connects = SOUTH

/datum/component/plumbing/reaction_chamber/Initialize(start=TRUE, _turn_connects=TRUE)
	. = ..()
	if(!istype(parent, /obj/machinery/plumbing/reaction_chamber))
		return COMPONENT_INCOMPATIBLE

/datum/component/plumbing/reaction_chamber/can_give(amount, reagent, datum/ductnet/net)
	. = ..()
	var/obj/machinery/plumbing/reaction_chamber/RC = parent
	if(!. || !RC.emptying)
		return FALSE

/datum/component/plumbing/reaction_chamber/send_request(dir)
	var/obj/machinery/plumbing/reaction_chamber/RC = parent
	if(RC.emptying || !LAZYLEN(RC.required_reagents))
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

	reagents.flags &= ~NO_REACT
	reagents.handle_reactions()

	RC.emptying = TRUE //If we move this up, it'll instantly get turned off since any reaction always sets the reagent_total to zero. Other option is make the reaction update
	//everything for every chemical removed, wich isn't a good option either.
	RC.on_reagent_change(reagents) //We need to check it now, because some reactions leave nothing left.


/datum/component/plumbing/reaction_chamber/transfer_to(datum/component/plumbing/target, amount, reagent, datum/ductnet/net)
	if(reagents.is_reacting == TRUE) //Let the thing react in peace
		return
	return ..()

///Special connect that we currently use for reaction chambers. Being used so we can keep certain inputs seperate, like into a special internal acid container
/datum/component/plumbing/acidic_input
	demand_connects = WEST
	demand_color = "yellow"

/datum/component/plumbing/acidic_input/send_request(dir)
	process_request(amount = MACHINE_REAGENT_TRANSFER, reagent = /datum/reagent/reaction_agent/basic_buffer, dir = dir)

///Special connect that we currently use for reaction chambers. Being used so we can keep certain inputs seperate, like into a special internal base container
/datum/component/plumbing/alkaline_input
	demand_connects = EAST
	demand_color = "green"

/datum/component/plumbing/alkaline_input/send_request(dir)
	process_request(amount = MACHINE_REAGENT_TRANSFER, reagent = /datum/reagent/reaction_agent/alkaline_buffer, dir = dir)


