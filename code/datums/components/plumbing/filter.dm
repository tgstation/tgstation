/datum/component/plumbing/filter
	demand_connects = NORTH
	supply_connects = SOUTH | EAST | WEST //SOUTH is straight, EAST is right and WEST is left.

/datum/component/plumbing/filter/Initialize()
	. = ..()
	if(!istype(parent, /obj/machinery/plumbing/filter))
		return COMPONENT_INCOMPATIBLE

/datum/component/plumbing/filter/can_give(amount, reagent, dir)
	. = ..()
	if(.)
		var/direction = get_original_direction(dir) //we need it relative to the direction, so filters don't change when we turn the filter
		to_chat(world, "1 [direction]")
		if(reagent)
			if(!can_give_in_direction(direction, reagent))
				return FALSE

/datum/component/plumbing/filter/transfer_to(datum/component/plumbing/target, amount, reagent, dir)
	if(!reagents || !target || !target.reagents)
		return FALSE
	var/direction = get_original_direction(dir)
	if(reagent)
		reagents.trans_id_to(target.reagents, reagent, amount)
	else
		for(var/A in reagents.reagent_list)
			if(!can_give_in_direction(direction, A))
				continue
			var/new_amount
			if(reagents.reagent_list[A] < amount)
				new_amount = amount - reagents.reagent_list[A]
			reagents.trans_id_to(target.reagents, A, amount)
			amount = new_amount
			if(amount <= 0)
				break

/datum/component/plumbing/filter/proc/can_give_in_direction(dir, reagent)
	var/obj/machinery/plumbing/filter/F = parent
	switch(dir)
		if(SOUTH) //straight
			if(!F.left.Find(reagent) && !F.right.Find(reagent))
				return TRUE
		if(EAST) //right
			if(F.right.Find(reagent))
				return TRUE
		if(WEST) //left
			if(F.left.Find(reagent))
				return TRUE