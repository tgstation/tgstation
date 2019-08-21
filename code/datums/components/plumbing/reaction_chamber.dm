/datum/component/plumbing/reaction_chamber
	demand_connects = WEST
	supply_connects = EAST

/datum/component/plumbing/reaction_chamber/Initialize(start=TRUE, _turn_connects=TRUE)
	. = ..()
	if(. && istype(parent, /obj/machinery/plumbing/reaction_chamber))
		return TRUE

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
		for(var/A in reagents.reagent_list)
			var/datum/reagent/RD = A
			if(RT == RD.type && RC.required_reagents[RT] < RD.amount)
				process_request(min(required_reagents[RT] - RD.amount, MACHINE_REAGENT_TRANSFER) , RT, dir)
				return
	reagents.flags &= ~NOREACT
	RC.emptying = TRUE

/datum/component/plumbing/reaction_chamber/can_give(amount, reagent, datum/ductnet/net)
	. = ..()
	var/obj/machinery/plumbing/reaction_chamber/RC = parent
	if(!. || !RC.emptying)
		return FALSE




