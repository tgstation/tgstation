/datum/reagents/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Reagents", "Reaction search")
		ui.status = UI_INTERACTIVE //How do I prevent a UI from autoclosing if not in LoS
		ui_tags_selected = NONE //Resync with gui on open (gui expects no flags)
		ui_reagent_id = null
		ui_reaction_id = null
		ui.open()


/datum/reagents/ui_status(mob/user, datum/ui_state/state)
	return UI_INTERACTIVE //please advise

/datum/reagents/ui_state(mob/user)
	return GLOB.physical_state

///Generates a (rough) rate vs temperature graph profile
/datum/reagents/proc/generate_thermodynamic_profile(datum/chemical_reaction/reaction)
	var/list/coords = list()
	var/x_temp
	var/increment
	if(reaction.is_cold_recipe)
		coords += list(list(0, 0))
		coords += list(list(reaction.required_temp, 0))
		x_temp = reaction.required_temp
		increment = (reaction.optimal_temp - reaction.required_temp)/10
		while(x_temp < reaction.optimal_temp)
			var/y = (((x_temp - reaction.required_temp)**reaction.temp_exponent_factor)/((reaction.optimal_temp - reaction.required_temp)**reaction.temp_exponent_factor))
			coords += list(list(x_temp, y))
			x_temp += increment
	else
		coords += list(list(reaction.required_temp, 0))
		x_temp = reaction.required_temp
		increment = (reaction.required_temp - reaction.optimal_temp)/10
		while(x_temp > reaction.optimal_temp)
			var/y = (((x_temp - reaction.required_temp)**reaction.temp_exponent_factor)/((reaction.optimal_temp - reaction.required_temp)**reaction.temp_exponent_factor))
			coords += list(list(x_temp, y))
			x_temp -= increment

	coords += list(list(reaction.optimal_temp, 1))
	if(reaction.overheat_temp == NO_OVERHEAT)
		if(reaction.is_cold_recipe)
			coords += list(list(reaction.optimal_temp+10, 1))
		else
			coords += list(list(reaction.optimal_temp-10, 1))
		return coords
	coords += list(list(reaction.overheat_temp, 1))
	coords += list(list(reaction.overheat_temp, 0))
	return coords

/datum/reagents/proc/generate_explosive_profile(datum/chemical_reaction/reaction)
	if(reaction.overheat_temp == NO_OVERHEAT)
		return null
	var/list/coords = list()
	coords += list(list(reaction.overheat_temp, 0))
	coords += list(list(reaction.overheat_temp, 1))
	if(reaction.is_cold_recipe)
		coords += list(list(reaction.overheat_temp-50, 1))
		coords += list(list(reaction.overheat_temp-50, 0))
	else
		coords += list(list(reaction.overheat_temp+50, 1))
		coords += list(list(reaction.overheat_temp+50, 0))
	return coords


///Returns a string descriptor of a reactions themic_constant
/datum/reagents/proc/determine_reaction_thermics(datum/chemical_reaction/reaction)
	var/thermic = reaction.thermic_constant
	if(reaction.reaction_flags & REACTION_HEAT_ARBITARY)
		thermic *= 100 //Because arbitary is a lower scale
	switch(thermic)
		if(-INFINITY to -1500)
			return "Overwhelmingly endothermic"
		if(-1500 to -1000)
			return "Extremely endothermic"
		if(-1000 to -500)
			return "Strongly endothermic"
		if(-500 to -200)
			return "Moderately endothermic"
		if(-200 to -50)
			return "Endothermic"
		if(-50 to 0)
			return "Weakly endothermic"
		if(0)
			return ""
		if(0 to 50)
			return "Weakly Exothermic"
		if(50 to 200)
			return "Exothermic"
		if(200 to 500)
			return "Moderately exothermic"
		if(500 to 1000)
			return "Strongly exothermic"
		if(1000 to 1500)
			return "Extremely exothermic"
		if(1500 to INFINITY)
			return "Overwhelmingly exothermic"

/datum/reagents/proc/parse_addictions(datum/reagent/reagent)
	var/addict_text = list()
	for(var/entry in reagent.addiction_types)
		var/datum/addiction/ref = SSaddiction.all_addictions[entry]
		switch(reagent.addiction_types[entry])
			if(-INFINITY to 0)
				continue
			if(0 to 5)
				addict_text += "Weak [ref.name]"
			if(5 to 10)
				addict_text += "[ref.name]"
			if(10 to 20)
				addict_text += "Strong [ref.name]"
			if(20 to INFINITY)
				addict_text += "Potent [ref.name]"
	return addict_text

/datum/reagents/ui_data(mob/user)
	var/data = list()
	data["selectedBitflags"] = ui_tags_selected
	data["currentReagents"] = previous_reagent_list //This keeps the string of reagents that's updated when handle_reactions() is called
	data["beakerSync"] = ui_beaker_sync
	data["linkedBeaker"] = my_atom.name //To solidify the fact that the UI is linked to a beaker - not a machine.

	//First we check to see if reactions are synced with the beaker
	if(ui_beaker_sync)
		if(reaction_list)//But we don't want to null the previously displayed if there are none
			//makes sure we're within bounds
			if(ui_reaction_index > reaction_list.len)
				ui_reaction_index = reaction_list.len
			ui_reaction_id = reaction_list[ui_reaction_index].reaction.type

	//reagent lookup data
	if(ui_reagent_id)
		var/datum/reagent/reagent = find_reagent_object_from_type(ui_reagent_id)
		if(!reagent)
			to_chat(user, "Could not find reagent!")
			ui_reagent_id = null
		else
			data["reagent_mode_reagent"] = list("name" = reagent.name, "id" = reagent.type, "desc" = reagent.description, "reagentCol" = reagent.color, "pH" = reagent.ph, "pHCol" = convert_ph_to_readable_color(reagent.ph), "metaRate" = reagent.metabolization_rate, "OD" = reagent.overdose_threshold)
			data["reagent_mode_reagent"]["addictions"] = list()
			data["reagent_mode_reagent"]["addictions"] = parse_addictions(reagent)

			var/datum/reagent/inverse_reagent = GLOB.chemical_reagents_list[reagent.inverse_chem]
			if(inverse_reagent)
				data["reagent_mode_reagent"] += list("inverseReagent" = inverse_reagent.name, "inverseId" = inverse_reagent.type)

			if(reagent.chemical_flags & REAGENT_DEAD_PROCESS)
				data["reagent_mode_reagent"] += list("deadProcess" = TRUE)
	else
		data["reagent_mode_reagent"] = null

	//reaction lookup data
	if (ui_reaction_id)

		var/datum/chemical_reaction/reaction = get_chemical_reaction(ui_reaction_id)
		if(!reaction)
			to_chat(user, "Could not find reaction!")
			ui_reaction_id = null
			return data
		//Required holder
		var/container_name
		if(reaction.required_container)
			var/list/names = splittext("[reaction.required_container]", "/")
			container_name = "[names[names.len-1]] [names[names.len]]"
			container_name = replacetext(container_name, "_", " ")

		//Next, find the product
		var/has_product = TRUE
		//If we have no product, use the typepath to create a name for it
		if(!length(reaction.results))
			has_product = FALSE
			var/list/names = splittext("[reaction.type]", "/")
			var/product_name = names[names.len]
			data["reagent_mode_recipe"] = list("name" = product_name, "id" = reaction.type, "hasProduct" = has_product, "reagentCol" = COLOR_WHITE, "thermodynamics" = generate_thermodynamic_profile(reaction), "explosive" = generate_explosive_profile(reaction), "lowerpH" = reaction.optimal_ph_min, "upperpH" = reaction.optimal_ph_max, "thermics" = determine_reaction_thermics(reaction), "thermoUpper" = reaction.rate_up_lim, "minPurity" = reaction.purity_min, "inversePurity" = "N/A", "tempMin" = reaction.required_temp, "explodeTemp" = reaction.overheat_temp, "reqContainer" = container_name, "subReactLen" = 1, "subReactIndex" = 1)

		//If we do have a product then we find it
		else
			//Find out if we have multiple reactions for the same product
			var/datum/reagent/primary_reagent = find_reagent_object_from_type(reaction.results[1])//We use the first product - though it might be worth changing this
			//If we're syncing from the beaker
			var/list/sub_reactions = list()
			if(ui_beaker_sync && reaction_list)
				for(var/_ongoing_eq in reaction_list)
					var/datum/equilibrium/ongoing_eq = _ongoing_eq
					var/ongoing_r = ongoing_eq.reaction
					sub_reactions += ongoing_r
			else
				sub_reactions = get_recipe_from_reagent_product(primary_reagent.type)
			var/sub_reaction_length = length(sub_reactions)
			var/i = 1
			for(var/datum/chemical_reaction/sub_reaction in sub_reactions)
				if(sub_reaction.type == reaction.type)
					ui_reaction_index = i //update our index
					break
				i += 1
			data["reagent_mode_recipe"] = list("name" = primary_reagent.name, "id" = reaction.type, "hasProduct" = has_product, "reagentCol" = primary_reagent.color, "thermodynamics" = generate_thermodynamic_profile(reaction), "explosive" = generate_explosive_profile(reaction), "lowerpH" = reaction.optimal_ph_min, "upperpH" = reaction.optimal_ph_max, "thermics" = determine_reaction_thermics(reaction), "thermoUpper" = reaction.rate_up_lim, "minPurity" = reaction.purity_min, "inversePurity" = primary_reagent.inverse_chem_val, "tempMin" = reaction.required_temp, "explodeTemp" = reaction.overheat_temp, "reqContainer" = container_name, "subReactLen" = sub_reaction_length, "subReactIndex" = ui_reaction_index)

		//Results sweep
		var/has_reagent = "default"
		for(var/_reagent in reaction.results)
			var/datum/reagent/reagent = find_reagent_object_from_type(_reagent)
			if(has_reagent(_reagent))
				has_reagent = "green"
			data["reagent_mode_recipe"]["products"] += list(list("name" = reagent.name, "id" = reagent.type, "ratio" = reaction.results[reagent.type], "hasReagentCol" = has_reagent))

		//Reactant sweep
		for(var/_reagent in reaction.required_reagents)
			var/datum/reagent/reagent = find_reagent_object_from_type(_reagent)
			var/color_r = "default" //If the holder is missing the reagent, it's displayed in orange
			if(has_reagent(reagent.type))
				color_r = "green" //It's green if it's present
			var/tooltip
			var/tooltip_bool = FALSE
			var/list/sub_reactions = get_recipe_from_reagent_product(reagent.type)
			//Get sub reaction possibilities, but ignore ones that need a specific holder atom
			var/sub_index = 0
			for(var/datum/chemical_reaction/sub_reaction as anything in sub_reactions)
				if(sub_reaction.required_container)//So we don't have slime reactions confusing things
					sub_index++
					continue
				sub_index++
				break
			if(sub_index)
				var/datum/chemical_reaction/sub_reaction = sub_reactions[sub_index]
				//Subreactions sweep (if any)
				for(var/_sub_reagent in sub_reaction.required_reagents)
					var/datum/reagent/sub_reagent = find_reagent_object_from_type(_sub_reagent)
					tooltip += "[sub_reaction.required_reagents[_sub_reagent]]u [sub_reagent.name]\n" //I forgot the better way of doing this - fix this after this works
					tooltip_bool = TRUE
			data["reagent_mode_recipe"]["reactants"] += list(list("name" = reagent.name, "id" = reagent.type, "ratio" = reaction.required_reagents[reagent.type], "color" = color_r, "tooltipBool" = tooltip_bool, "tooltip" = tooltip))

		//Catalyst sweep
		for(var/_reagent in reaction.required_catalysts)
			var/datum/reagent/reagent = find_reagent_object_from_type(_reagent)
			var/color_r = "default"
			if(has_reagent(reagent.type))
				color_r = "green"
			var/tooltip
			var/tooltip_bool = FALSE
			var/list/sub_reactions = get_recipe_from_reagent_product(reagent.type)
			if(length(sub_reactions))
				var/datum/chemical_reaction/sub_reaction = sub_reactions[1]
				//Subreactions sweep (if any)
				for(var/_sub_reagent in sub_reaction.required_reagents)
					var/datum/reagent/sub_reagent = find_reagent_object_from_type(_sub_reagent)
					tooltip += "[sub_reaction.required_reagents[_sub_reagent]]u [sub_reagent.name]\n" //I forgot the better way of doing this - fix this after this works
					tooltip_bool = TRUE
			data["reagent_mode_recipe"]["catalysts"] += list(list("name" = reagent.name, "id" = reagent.type, "ratio" = reaction.required_catalysts[reagent.type], "color" = color_r, "tooltipBool" = tooltip_bool, "tooltip" = tooltip))
		data["reagent_mode_recipe"]["isColdRecipe"] = reaction.is_cold_recipe
	else
		data["reagent_mode_recipe"] = null

	return data

/datum/reagents/ui_static_data(mob/user)
	var/data = list()
	//Use GLOB list - saves processing
	data["master_reaction_list"] = GLOB.chemical_reactions_results_lookup_list
	data["bitflags"] = list()
	data["bitflags"]["BRUTE"] = REACTION_TAG_BRUTE
	data["bitflags"]["BURN"] = REACTION_TAG_BURN
	data["bitflags"]["TOXIN"] = REACTION_TAG_TOXIN
	data["bitflags"]["OXY"] = REACTION_TAG_OXY
	data["bitflags"]["HEALING"] = REACTION_TAG_HEALING
	data["bitflags"]["DAMAGING"] = REACTION_TAG_DAMAGING
	data["bitflags"]["EXPLOSIVE"] = REACTION_TAG_EXPLOSIVE
	data["bitflags"]["OTHER"] = REACTION_TAG_OTHER
	data["bitflags"]["DANGEROUS"] = REACTION_TAG_DANGEROUS
	data["bitflags"]["EASY"] = REACTION_TAG_EASY
	data["bitflags"]["MODERATE"] = REACTION_TAG_MODERATE
	data["bitflags"]["HARD"] = REACTION_TAG_HARD
	data["bitflags"]["ORGAN"] = REACTION_TAG_ORGAN
	data["bitflags"]["DRINK"] = REACTION_TAG_DRINK
	data["bitflags"]["FOOD"] = REACTION_TAG_FOOD
	data["bitflags"]["SLIME"] = REACTION_TAG_SLIME
	data["bitflags"]["DRUG"] = REACTION_TAG_DRUG
	data["bitflags"]["UNIQUE"] = REACTION_TAG_UNIQUE
	data["bitflags"]["CHEMICAL"] = REACTION_TAG_CHEMICAL
	data["bitflags"]["PLANT"] = REACTION_TAG_PLANT
	data["bitflags"]["COMPETITIVE"] = REACTION_TAG_COMPETITIVE

	return data

/* Returns a reaction type by index from an input reagent type
* i.e. the input reagent's associated reactions are found, and the index determines which one to return
* If the index is out of range, it is set to 1
*/
/datum/reagents/proc/get_reaction_from_indexed_possibilities(path, index = null)
	if(index)
		ui_reaction_index = index
	var/list/sub_reactions = get_recipe_from_reagent_product(path)
	if(!length(sub_reactions))
		to_chat(usr, "There is no recipe associated with this product.")
		return FALSE
	if(ui_reaction_index > length(sub_reactions))
		ui_reaction_index = 1
	var/datum/chemical_reaction/reaction = sub_reactions[ui_reaction_index]
	return reaction.type

/datum/reagents/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("find_reagent_reaction")
			ui_reaction_id = get_reaction_from_indexed_possibilities(text2path(params["id"]))
			return TRUE
		if("reagent_click")
			ui_reagent_id = text2path(params["id"])
			return TRUE
		if("recipe_click")
			ui_reaction_id = text2path(params["id"])
			return TRUE
		if("search_reagents")
			var/input_reagent = tgui_input_list(usr, "Select reagent", "Reagent", GLOB.name2reagent)
			input_reagent = get_reagent_type_from_product_string(input_reagent) //from string to type
			var/datum/reagent/reagent = find_reagent_object_from_type(input_reagent)
			if(!reagent)
				to_chat(usr, "Could not find reagent!")
				return FALSE
			ui_reagent_id = reagent.type
			return TRUE
		if("search_recipe")
			var/input_reagent = (input("Enter the name of product reagent", "Input") as text|null)
			input_reagent = get_reagent_type_from_product_string(input_reagent) //from string to type
			var/datum/reagent/reagent = find_reagent_object_from_type(input_reagent)
			if(!reagent)
				to_chat(usr, "Could not find product reagent!")
				return
			ui_reaction_id = get_reaction_from_indexed_possibilities(reagent.type)
			return TRUE
		if("increment_index")
			ui_reaction_index += 1
			if(!ui_beaker_sync || !reaction_list)
				ui_reaction_id = get_reaction_from_indexed_possibilities(get_reagent_type_from_product_string(params["id"]))
			return TRUE
		if("reduce_index")
			if(ui_reaction_index == 1)
				return
			ui_reaction_index -= 1
			if(!ui_beaker_sync || !reaction_list)
				ui_reaction_id = get_reaction_from_indexed_possibilities(get_reagent_type_from_product_string(params["id"]))
			return TRUE
		if("beaker_sync")
			ui_beaker_sync = !ui_beaker_sync
			return TRUE
		if("toggle_tag_brute")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_BRUTE
			return TRUE
		if("toggle_tag_burn")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_BURN
			return TRUE
		if("toggle_tag_toxin")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_TOXIN
			return TRUE
		if("toggle_tag_oxy")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_OXY
			return TRUE
		if("toggle_tag_healing")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_HEALING
			return TRUE
		if("toggle_tag_damaging")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_DAMAGING
			return TRUE
		if("toggle_tag_explosive")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_EXPLOSIVE
			return TRUE
		if("toggle_tag_other")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_OTHER
			return TRUE
		if("toggle_tag_easy")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_EASY
			return TRUE
		if("toggle_tag_moderate")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_MODERATE
			return TRUE
		if("toggle_tag_hard")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_HARD
			return TRUE
		if("toggle_tag_organ")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_ORGAN
			return TRUE
		if("toggle_tag_drink")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_DRINK
			return TRUE
		if("toggle_tag_food")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_FOOD
			return TRUE
		if("toggle_tag_dangerous")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_DANGEROUS
			return TRUE
		if("toggle_tag_slime")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_SLIME
			return TRUE
		if("toggle_tag_drug")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_DRUG
			return TRUE
		if("toggle_tag_unique")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_UNIQUE
			return TRUE
		if("toggle_tag_chemical")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_CHEMICAL
			return TRUE
		if("toggle_tag_plant")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_PLANT
			return TRUE
		if("toggle_tag_competitive")
			ui_tags_selected = ui_tags_selected ^ REACTION_TAG_COMPETITIVE
			return TRUE
		if("update_ui")
			return TRUE
