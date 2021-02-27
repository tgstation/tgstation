/proc/chem_recipes_do_conflict(datum/chemical_reaction/r1, datum/chemical_reaction/r2)
	//We have to check to see if either is competitive so can ignore it (competitive reagents are supposed to conflict)
	if((r1.reaction_flags & REACTION_COMPETITIVE) || (r2.reaction_flags & REACTION_COMPETITIVE))
		return FALSE

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

/proc/get_chemical_reaction(id)
	if(!GLOB.chemical_reactions_list)
		return
	for(var/reagent in GLOB.chemical_reactions_list)
		for(var/R in GLOB.chemical_reactions_list[reagent])
			var/datum/reac = R
			if(reac.type == id)
				return R

/proc/remove_chemical_reaction(datum/chemical_reaction/R)
	if(!GLOB.chemical_reactions_list || !R)
		return
	for(var/rid in R.required_reagents)
		GLOB.chemical_reactions_list[rid] -= R

//see build_chemical_reactions_list in holder.dm for explanations
/proc/add_chemical_reaction(datum/chemical_reaction/R)
	if(!GLOB.chemical_reactions_list || !R.required_reagents || !R.required_reagents.len)
		return
	var/primary_reagent = R.required_reagents[1]
	if(!GLOB.chemical_reactions_list[primary_reagent])
		GLOB.chemical_reactions_list[primary_reagent] = list()
	GLOB.chemical_reactions_list[primary_reagent] += R

//Creates foam from the reagent. Metaltype is for metal foam, notification is what to show people in textbox
/datum/reagents/proc/create_foam(foamtype,foam_volume,metaltype = 0,notification = null)
	var/location = get_turf(my_atom)
	var/datum/effect_system/foam_spread/foam = new foamtype()
	foam.set_up(foam_volume, location, src, metaltype)
	foam.start()
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
	var/input_reagent = replacetext(lowertext(string), " ", "") //95% of the time, the reagent id is a lowercase/no spaces version of the name
	if (isnull(input_reagent))
		return

	var/list/shortcuts = list("meth" = /datum/reagent/drug/methamphetamine)
	if(shortcuts[input_reagent])
		input_reagent = shortcuts[input_reagent]
	else
		input_reagent = find_reagent(input_reagent)
	return input_reagent

///Returns reagent datum from typepath
/proc/find_reagent(input)
	. = FALSE
	if(GLOB.chemical_reagents_list[input]) //prefer IDs!
		return input
	else
		return get_chem_id(input)

/proc/find_reagent_object_from_type(input)
	if(GLOB.chemical_reagents_list[input]) //prefer IDs!
		return GLOB.chemical_reagents_list[input]
	else
		return null

///Returns a random reagent object minus blacklisted reagents
/proc/get_random_reagent_id()
	var/static/list/random_reagents = list()
	if(!random_reagents.len)
		for(var/thing in subtypesof(/datum/reagent))
			var/datum/reagent/R = thing
			if(initial(R.chemical_flags) & REAGENT_CAN_BE_SYNTHESIZED)
				random_reagents += R
	var/picked_reagent = pick(random_reagents)
	return picked_reagent

///Returns reagent datum from reagent name string
/proc/get_chem_id(chem_name)
	for(var/X in GLOB.chemical_reagents_list)
		var/datum/reagent/R = GLOB.chemical_reagents_list[X]
		if(ckey(chem_name) == ckey(lowertext(R.name)))
			return X

///Takes a type in and returns a list of associated recipes
/proc/get_recipe_from_reagent_product(input_type)
	if(!input_type)
		return
	var/list/matching_reactions = GLOB.chemical_reactions_list_product_index[input_type]
	return matching_reactions
