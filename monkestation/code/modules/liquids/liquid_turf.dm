/turf
	var/obj/effect/abstract/liquid_turf/liquids
	var/liquid_height = 0
	var/turf_height = 0

/turf/proc/reasses_liquids()
	if(!liquids)
		return
	if(!liquids.liquid_group)
		liquids.liquid_group = new(1, liquids)

/turf/proc/liquid_update_turf()
	if(!liquids)
		return
	//Check atmos adjacency to cut off any disconnected groups
	if(liquids.liquid_group)
		var/assoc_atmos_turfs = list()
		for(var/tur in get_atmos_adjacent_turfs())
			assoc_atmos_turfs[tur] = TRUE
		//Check any cardinals that may have a matching group
		for(var/direction in GLOB.cardinals)
			var/turf/T = get_step(src, direction)
			if(!T.liquids)
				return

/turf/proc/add_liquid_from_reagents(datum/reagents/giver, no_react = FALSE, chem_temp, amount)
	var/list/compiled_list = list()
	var/multiplier = amount ? amount / giver.total_volume : 1
	for(var/r in giver.reagent_list)
		var/datum/reagent/R = r
		if(!(R.type in GLOB.liquid_blacklist))
			compiled_list[R.type] = R.volume * multiplier
	if(!compiled_list.len) //No reagents to add, don't bother going further
		return
	if(!liquids)
		liquids = new(src)
	liquids.liquid_group.add_reagents(liquids, compiled_list, chem_temp)

//More efficient than add_liquid for multiples
/turf/proc/add_liquid_list(reagent_list, no_react = FALSE, chem_temp)
	if(liquids && !liquids.liquid_group)
		qdel(liquids)
		return

	if(!liquids)
		liquids = new(src)
	liquids.liquid_group.add_reagents(liquids, reagent_list, chem_temp)
	//Expose turf
	liquids.liquid_group.expose_members_turf(liquids)

/turf/proc/add_liquid(reagent, amount, no_react = FALSE, chem_temp = 300)
	if(reagent in GLOB.liquid_blacklist)
		return
	if(!liquids)
		liquids = new(src)

	liquids.liquid_group.add_reagent(liquids, reagent, amount, chem_temp)
	//Expose turf
	liquids.liquid_group.expose_members_turf(liquids)
