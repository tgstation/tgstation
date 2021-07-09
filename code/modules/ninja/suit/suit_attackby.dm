/obj/item/clothing/suit/space/space_ninja/attackby(obj/item/I, mob/ninja, params)
	if(ninja!=affecting)//Safety, in case you try doing this without wearing the suit/being the person with the suit.
		return ..()

	if(istype(I, /obj/item/reagent_containers/glass) && I.reagents.has_reagent(/datum/reagent/uranium/radium, a_transfer) && a_boost != TRUE)//If it's a glass beaker, and what we're transferring is radium.
		I.reagents.remove_reagent(/datum/reagent/uranium/radium, a_transfer)
		a_boost = TRUE;
		to_chat(ninja, span_notice("The suit's adrenaline boost is now reloaded."))
		return


	else if(istype(I, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/CELL = I
		if(CELL.maxcharge > cell.maxcharge)
			to_chat(ninja, span_notice("Higher maximum capacity detected.\nUpgrading..."))
			if (do_after(ninja,s_delay, target = src))
				ninja.transferItemToLoc(CELL, src)
				CELL.charge = min(CELL.charge+cell.charge, CELL.maxcharge)
				var/obj/item/stock_parts/cell/old_cell = cell
				old_cell.charge = 0
				ninja.put_in_hands(old_cell)
				old_cell.add_fingerprint(ninja)
				old_cell.corrupt()
				old_cell.update_appearance()
				cell = CELL
				to_chat(ninja, span_notice("Upgrade complete. Maximum capacity: <b>[round(cell.maxcharge/100)]</b>%"))
			else
				to_chat(ninja, span_danger("Procedure interrupted. Protocol terminated."))
		return

	else if(istype(I, /obj/item/disk/tech_disk))//If it's a data disk, we want to copy the research on to the suit.
		var/obj/item/disk/tech_disk/TD = I
		var/has_research = FALSE
		for(var/node in TD.stored_research.researched_nodes)
			if(!stored_research.researched_nodes[node])
				has_research = TRUE
				break
		if(has_research)//If it has something on it.
			to_chat(ninja, span_notice("Research information detected, processing..."))
			if(do_after(ninja,s_delay, target = src))
				TD.stored_research.copy_research_to(stored_research)
				qdel(TD.stored_research)
				TD.stored_research = new
				to_chat(ninja, span_notice("Data analyzed and updated. Disk erased."))
			else
				to_chat(ninja, "[span_userdanger("ERROR")]: Procedure interrupted. Process terminated.")
		else
			to_chat(ninja, span_notice("No new research information detected."))
		return
	return ..()
