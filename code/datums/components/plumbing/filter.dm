///The magical plumbing component used by the chemical filters. The different supply connects behave differently depending on the filters set on the chemical filter
/datum/component/plumbing/filter
	demand_connects = NORTH
	supply_connects = SOUTH | EAST | WEST //SOUTH is straight, EAST is left and WEST is right. We look from the perspective of the insert

/datum/component/plumbing/filter/Initialize(ducting_layer)
	if(!istype(parent, /obj/machinery/plumbing/filter))
		return COMPONENT_INCOMPATIBLE
	return ..()

/datum/component/plumbing/filter/supply_demand(dir)
	var/list/whitelist = null

	var/obj/machinery/plumbing/filter/F = parent
	switch(get_original_direction(dir))
		if(SOUTH) //straight
			if(length(F.left) || length(F.right))
				whitelist = list()
				for(var/datum/reagent/target as anything in reagents.reagent_list)
					if((target.type in F.left) || (target.type in F.right))
						continue
					whitelist += target.type
				if(whitelist.len == reagents.reagent_list.len)
					whitelist = null
		if(EAST) //left
			whitelist = F.left
		if(WEST) //right
			whitelist = F.right

	. = 0
	if(whitelist)
		for(var/datum/reagent/send as anything in whitelist)
			. += process_demand(reagent = send, dir = dir)
	else
		. = process_demand(dir = dir)
