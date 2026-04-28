///Helper to ensure a constant is applied regardless of reagent metabolization rate to get 100% effect
///Use for parent reagent types when subtypes alter metabolization rates
#define METABOLIZE_FREE_CONSTANT(value)((value * REAGENTS_METABOLISM) / metabolization_rate)

/proc/chem_recipes_do_conflict(datum/chemical_reaction/r1, datum/chemical_reaction/r2)
	//We have to check to see if either is competitive so can ignore it (competitive reagents are supposed to conflict)
	if((r1.reaction_flags & REACTION_COMPETITIVE) || (r2.reaction_flags & REACTION_COMPETITIVE))
		return FALSE

	//do the non-list tests first, because they are cheaper
	if(r1.is_cold_recipe != r2.is_cold_recipe)
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

	//if short one has a container requirement and it's not the same as the long one's, there's no conflict
	if(short_req.required_container && short_req.required_container != long_req.required_container)
		return FALSE

	//if short one has a more extreme temperature requirement, there's no conflict
	if(short_req.is_cold_recipe == long_req.is_cold_recipe)
		if(short_req.is_cold_recipe && short_req.required_temp < long_req.required_temp)
			return FALSE
		if(!short_req.is_cold_recipe && short_req.required_temp > long_req.required_temp)
			return FALSE

	//check if the shorter reaction list is a subset of the longer one
	var/list/reagent_overlap = long_req.required_reagents & short_req.required_reagents
	if(reagent_overlap.len != short_req.required_reagents.len)
		//there is at least one reagent in the short list that is not in the long list, so there is no conflict
		return FALSE

	//check to see if the shorter reaction's catalyst list is also a subset of the longer reaction's catalyst list
	//if the longer reaction's catalyst list is a subset of the shorter ones, that is fine
	//if the reaction lists are the same, the short reaction will have the shorter required_catalysts list, so it will register as a conflict
	var/list/catalyst_overlap = long_req.required_catalysts & short_req.required_catalysts
	if(catalyst_overlap.len != short_req.required_catalysts.len)
		//there is at least one unique catalyst for the short reaction, so there is no conflict
		return FALSE

	for(var/datum/reagent/ingredient as anything in reagent_overlap)
		//if longer reaction requires less amount of a reagent, there's no conflict
		if(reagent_overlap[ingredient] < short_req.required_reagents[ingredient])
			return FALSE
	for(var/datum/reagent/catalyst as anything in catalyst_overlap)
		//if longer reaction requires less amount of a catalyst, there's no conflict
		if(catalyst_overlap[catalyst] < short_req.required_catalysts[catalyst])
			return FALSE

	//if we got this far, the longer reaction will be impossible to create if the shorter one is earlier in GLOB.chemical_reactions_list_reactant_index, and will require the reagents to be added in a particular order otherwise
	return TRUE

//Creates foam from the reagent. Metaltype is for metal foam, notification is what to show people in textbox
/datum/reagents/proc/create_foam(foamtype, foam_volume, result_type = null, notification = null, log = FALSE)
	var/location = get_turf(my_atom)

	var/datum/effect_system/fluid_spread/foam/foam = new foamtype(location, null, foam_volume, my_atom, carry = src, result_type = result_type)
	foam.start(log = log)

	clear_reagents()
	if(!notification)
		return
	for(var/mob/M in viewers(5, location))
		to_chat(M, notification)

///Converts the pH into a tgui readable color - i.e. white and black text is readable over it. This is NOT the colourwheel for pHes however.
/proc/convert_ph_to_readable_color(pH)
	switch(pH)
		if(-INFINITY to 1)
			return "red"
		if(1 to 2)
			return "orange"
		if(2 to 3)
			return "average"
		if(3 to 4)
			return "yellow"
		if(4 to 5)
			return "olive"
		if(5 to 6)
			return "good"
		if(6 to 8)
			return "green"
		if(8 to 9.5)
			return "teal"
		if(9.5 to 11)
			return "blue"
		if(11 to 12.5)
			return "violet"
		if(12.5 to INFINITY)
			return "purple"

///Converts pH to universal indicator colours. This is the colorwheel for pHes
#define CONVERT_PH_TO_COLOR(pH, color) \
	switch(pH) {\
		if(14 to INFINITY)\
			{ color = "#462c83" }\
		if(13 to 14)\
			{ color = "#63459b" }\
		if(12 to 13)\
			{ color = "#5a51a2" }\
		if(11 to 12)\
			{ color = "#3853a4" }\
		if(10 to 11)\
			{ color = "#3f93cf" }\
		if(9 to 10)\
			{ color = "#0bb9b7" }\
		if(8 to 9)\
			{ color = "#23b36e" }\
		if(7 to 8)\
			{ color = "#3aa651" }\
		if(6 to 7)\
			{ color = "#4cb849" }\
		if(5 to 6)\
			{ color = "#b5d335" }\
		if(4 to 5)\
			{ color = "#f7ec1e" }\
		if(3 to 4)\
			{ color = "#fbc314" }\
		if(2 to 3)\
			{ color = "#f26724" }\
		if(1 to 2)\
			{ color = "#ef1d26" }\
		if(-INFINITY to 1)\
			{ color = "#c6040c" }\
		}

///Returns a list of chemical_reaction datums that have the input STRING as a product
/proc/get_reagent_type_from_product_string(string)
	var/input_reagent = replacetext(LOWER_TEXT(string), " ", "") //95% of the time, the reagent id is a lowercase/no spaces version of the name
	if (isnull(input_reagent))
		return

	var/list/shortcuts = list("meth" = /datum/reagent/drug/methamphetamine)
	if(shortcuts[input_reagent])
		input_reagent = shortcuts[input_reagent]
	else
		input_reagent = get_chem_id(input_reagent)
	return input_reagent

///Returns a random reagent object, with the option to blacklist reagents.
/proc/get_random_reagent_id(randomization_flags = REAGENT_SPAWN_RANDOM_PRODUCERS, list/blacklist, list/whitelist)
	var/list/reagent_list_to_process = list()

	whitelist ||= subtypesof(/datum/reagent)

	for(var/datum/reagent/reagent_path as anything in whitelist)
		if(is_path_in_list(reagent_path, blacklist))
			continue
		if(reagent_path::randomized_spawns & randomization_flags)
			reagent_list_to_process += reagent_path
	return pick(reagent_list_to_process)

///Returns reagent datum from reagent name string
/proc/get_chem_id(chem_name)
	for(var/X in GLOB.chemical_reagents_list)
		var/datum/reagent/R = GLOB.chemical_reagents_list[X]
		if(ckey(chem_name) == ckey(LOWER_TEXT(R.name)))
			return X

/proc/reagent_paths_list_to_text(list/reagents, addendum)
	var/list/temp = list()
	for(var/datum/reagent/R as anything in reagents)
		temp |= initial(R.name)
	if(addendum)
		temp += addendum
	return jointext(temp, ", ")
