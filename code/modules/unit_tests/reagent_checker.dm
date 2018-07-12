#define TEST_BEAKER_SIZE 6969
#define SLEEP_AFTER_MIX 1

/datum/unit_test/reagent_checker

/datum/unit_test/reagent_checker/Run()
	var/locs = block(run_loc_bottom_left, run_loc_top_right)
	build_chemical_reactions_list()
	build_chemical_reagent_list()
	var/list/reactions
	for(var/I in GLOB.chemical_reactions_list)
		LAZYADD(reactions, GLOB.chemical_reactions_list[I])
		for(var/V in reactions)
			var/datum/chemical_reaction/R = V
			for(var/id in (R.required_reagents + R.required_catalysts))
				if(!GLOB.chemical_reagents_list[id])
					Fail("Unknown chemical id \"[id]\" in recipe [R.type]")
	if(!fail_reasons) // only run if we haven't had any broken reactions reported
		for(var/i in 1 to (reactions.len-1))
			for(var/i2 in (i+1) to reactions.len)
				var/datum/chemical_reaction/r1 = reactions[i]
				var/datum/chemical_reaction/r2 = reactions[i2]
				if(recipes_do_conflict(r1, r2))
					Fail("Chemical recipe conflict between [r1.type] and [r2.type]")
		if(!fail_reasons) // again
			var/obj/item/reagent_containers/glass/beaker/bluespace/test_beaker = new /obj/item/reagent_containers/glass/beaker/bluespace(pick(locs))
			test_beaker.reagents.maximum_volume = TEST_BEAKER_SIZE
			for(var/RE in reactions)
				if(!test_beaker) // for the explosive stuff
					test_beaker = new /obj/item/reagent_containers/glass/beaker/bluespace(pick(locs))
					test_beaker.reagents.maximum_volume = TEST_BEAKER_SIZE
				var/datum/chemical_reaction/finebros = RE
				log_world("Testing reaction [finebros.name]")
				finebros.required_container = null
				finebros.required_other = 0
				test_beaker.reagents.set_reacting(FALSE)
				for(var/key in finebros.required_reagents)
					test_beaker.reagents.add_reagent(key, finebros.required_reagents[key])
				for(var/key in finebros.required_catalysts)
					test_beaker.reagents.add_reagent(key, finebros.required_catalysts[key])
				if(finebros.required_temp)
					test_beaker.reagents.chem_temp = finebros.required_temp
				test_beaker.reagents.set_reacting(TRUE)
				test_beaker.reagents.handle_reactions()
				if(SLEEP_AFTER_MIX)
					sleep(20)
				for(var/key in finebros.results)
					if(test_beaker.reagents.has_reagent(key, finebros.results[key]))
						continue
					else
						Fail("Chemical Recipe [finebros.name] did not produce or didn't produce enough of [key]!")
				test_beaker.reagents.clear_reagents()
				
				
/datum/unit_test/reagent_checker/proc/recipes_do_conflict(datum/chemical_reaction/r1, datum/chemical_reaction/r2)
	//do the non-list tests first, because they are cheaper
	if(r1.required_container != r2.required_container)
		return FALSE
	if(r1.is_cold_recipe == r2.is_cold_recipe)
		if(r1.required_temp != r2.required_temp)
			//one reaction requires a more extreme temperature than the other, so there is no conflict
			return FALSE
	else
		var/datum/chemical_reaction/cold_one = r1.is_cold_recipe ? r1 : r2
		var/datum/chemical_reaction/warm_one = r1.is_cold_recipe ? r2 : r1
		if(cold_one.required_temp < warm_one.required_temp)
			//the range of temperatures does not overlap, so there is no conflict
			return FALSE

	//find the reactions with the shorter and longer required_reagents list
	var/datum/chemical_reaction/long_req
	var/datum/chemical_reaction/short_req
	if(r1.required_reagents.len > r2.required_reagents.len)
		long_req = r1
		short_req = r2
	else if(r1.required_reagents.len < r2.required_reagents.len)
		long_req = r2
		short_req = r1
	else
		//if they are the same length, sort instead by the length of the catalyst list
		//this is important if the required_reagents lists are the same
		if(r1.required_catalysts.len > r2.required_catalysts.len)
			long_req = r1
			short_req = r2
		else
			long_req = r2
			short_req = r1


	//check if the shorter reaction list is a subset of the longer one
	var/list/overlap = r1.required_reagents & r2.required_reagents
	if(overlap.len != short_req.required_reagents.len)
		//there is at least one reagent in the short list that is not in the long list, so there is no conflict
		return FALSE

	//check to see if the shorter reaction's catalyst list is also a subset of the longer reaction's catalyst list
	//if the longer reaction's catalyst list is a subset of the shorter ones, that is fine
	//if the reaction lists are the same, the short reaction will have the shorter required_catalysts list, so it will register as a conflict
	var/list/short_minus_long_catalysts = short_req.required_catalysts - long_req.required_catalysts
	if(short_minus_long_catalysts.len)
		//there is at least one unique catalyst for the short reaction, so there is no conflict
		return FALSE

	//if we got this far, the longer reaction will be impossible to create if the shorter one is earlier in GLOB.chemical_reactions_list, and will require the reagents to be added in a particular order otherwise
	return TRUE
