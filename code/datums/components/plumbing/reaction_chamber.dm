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

