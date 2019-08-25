/datum/component/plumbing/reaction_chamber
	demand_connects = WEST
	supply_connects = EAST

/datum/component/plumbing/reaction_chamber/Initialize(start=TRUE, _turn_connects=TRUE)
	. = ..()
	if(!istype(parent, /obj/machinery/plumbing/reaction_chamber))
		return COMPONENT_INCOMPATIBLE

/datum/component/plumbing/reaction_chamber/can_give(amount, reagent)
	. = ..()
	var/obj/machinery/plumbing/reaction_chamber/RC = parent
	if(!. || !RC.emptying)
		return FALSE

/datum/component/plumbing/reaction_chamber/send_request(dir)
	var/obj/machinery/plumbing/reaction_chamber/RC = parent
	if(RC.emptying)
		return
	for(var/RT in RC.required_reagents)
		to_chat(world, "1-[RT]")
		var/succes = FALSE
		for(var/A in reagents.reagent_list)
			to_chat(world, "2-[RT]")
			var/datum/reagent/RD = A
			if(RT == RD.type)
				to_chat(world, "3-[RT]-[succes]")
				succes = TRUE
				if(RC.required_reagents[RT] < RD.volume)
					to_chat(world, "4-[RT]-[succes]")
					process_request(min(RC.required_reagents[RT] - RD.volume, MACHINE_REAGENT_TRANSFER) , RT, dir)
					return
		if(!succes)
			to_chat(world, "5-[RT]-[succes]")
			process_request(min(RC.required_reagents[RT], MACHINE_REAGENT_TRANSFER), RT, dir)
			return

	reagents.flags &= ~NO_REACT
	RC.emptying = TRUE

/datum/component/plumbing/reaction_chamber/can_give(amount, reagent, datum/ductnet/net)
	. = ..()
	var/obj/machinery/plumbing/reaction_chamber/RC = parent
	if(!. || !RC.emptying)
		return FALSE




