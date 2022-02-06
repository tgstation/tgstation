/*
* A debug chem tester that will process through all recipies automatically and try to react them.
* Highlights low purity reactions and and reactions that don't happen
*/
/obj/machinery/chem_recipe_debug
	name = "chemical reaction tester"
	density = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "HPLC_debug"
	use_power = IDLE_POWER_USE
	idle_power_usage = 40
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	///List of every reaction in the game kept locally for easy access
	var/list/cached_reactions = list()
	///What index in the cached_reactions we're in
	var/index = 1
	///If the machine is currently processing through the list
	var/processing = FALSE
	///Final output that highlights all of the reactions with inoptimal purity/voolume at base
	var/problem_string
	///Final output that highlights all of the reactions with inoptimal purity/voolume at base
	var/impure_string
	///The count of reactions that resolve between 1 - 0.9 purity
	var/minorImpurity
	///The count of reactions that resolve below 0.9 purity
	var/majorImpurity
	///If we failed to react this current chem so use a lower temp - all reactions only
	var/failed = 0
	///If we're forcing optimal conditions
	var/should_force_temp = FALSE
	var/should_force_ph = FALSE
	///Forced values
	var/force_temp = 300
	var/force_ph = 7
	///Multiplier of product
	var/vol_multiplier = 20
	///If we're reacting
	var/react = FALSE
	///Number of delta times taken to react
	var/react_time = 0
	///IF we're doing EVERY reaction
	var/process_all = FALSE
	///The name
	var/list/reaction_names = list()
	///If it's started
	var/reaction_stated = FALSE
	///If we spawn a beaker at the end of a reaction or not
	var/beaker_spawn = FALSE
	///If we force min temp on reaction setup
	var/min_temp = FALSE
	///The recipe we're editing
	var/datum/chemical_reaction/edit_recipe

///Create reagents datum
/obj/machinery/chem_recipe_debug/Initialize(mapload)
	. = ..()
	create_reagents(9000)//I want to make sure everything fits
	end_processing()

///Enable the machine
/obj/machinery/chem_recipe_debug/attackby(obj/item/I, mob/user, params)
	. = ..()
	ui_interact(usr)

///Enable the machine
/obj/machinery/chem_recipe_debug/AltClick(mob/living/user)
	. = ..()
	if(processing)
		say("currently processing reaction [index]: [cached_reactions[index]] of [cached_reactions.len]")
		return
	process_all = TRUE
	say("Starting processing")
	setup_reactions()
	begin_processing()

///Resets the index, and creates the cached_reaction list from all possible reactions
/obj/machinery/chem_recipe_debug/proc/setup_reactions()
	cached_reactions = list()
	if(process_all)
		for(var/reaction in GLOB.chemical_reactions_list_reactant_index)
			if(is_type_in_list(GLOB.chemical_reactions_list_reactant_index[reaction], cached_reactions))
				continue
			cached_reactions += GLOB.chemical_reactions_list_reactant_index[reaction]
	else
		cached_reactions = reaction_names
	reagents.clear_reagents()
	index = 1
	processing = TRUE

/*
* The main loop that sets up, creates and displays results from a reaction
* warning: this code is a hot mess
*/
/obj/machinery/chem_recipe_debug/process(delta_time)
	if(processing == FALSE)
		setup_reactions()
	if(should_force_ph)
		reagents.ph = force_ph
	if(should_force_temp)
		reagents.chem_temp = force_temp
	if(reagents.is_reacting == TRUE)
		react_time += delta_time
		return
	if(reaction_stated == TRUE)
		reaction_stated = FALSE
		relay_ended_reaction()
	if(index > cached_reactions.len)
		relay_all_reactions()
		return
	setup_reaction()
	reaction_stated = TRUE

/obj/machinery/chem_recipe_debug/proc/relay_all_reactions()
	say("Completed testing, missing reactions products (may have exploded) are:")
	say("[problem_string]", sanitize=FALSE)
	say("Problem with results are:")
	say("[impure_string]", sanitize=FALSE)
	say("Reactions with minor impurity: [minorImpurity], reactions with major impurity: [majorImpurity]")
	processing = FALSE
	problem_string = null
	impure_string = null
	minorImpurity = null
	majorImpurity = null
	end_processing()

/obj/machinery/chem_recipe_debug/proc/relay_ended_reaction()
	if(reagents.reagent_list)
		var/cached_purity
		say("Reaction completed for [cached_reactions[index]] final temperature = [reagents.chem_temp], ph = [reagents.ph], time taken = [react_time]s.")
		var/datum/chemical_reaction/reaction = cached_reactions[index]
		for(var/reagent_type in reaction.results)
			var/datum/reagent/reagent = reagents.get_reagent(reagent_type)
			if(!reagent)
				say(span_warning("Unable to find product [reagent_type] in holder after reaction! reagents found are:"))
				for(var/other_reagent in reagents.reagent_list)
					say("[other_reagent]")
				var/obj/item/reagent_containers/glass/beaker/bluespace/beaker = new /obj/item/reagent_containers/glass/beaker/bluespace(loc)
				reagents.trans_to(beaker)
				beaker.name = "[cached_reactions[index]] failed"
				if(!failed)
					problem_string += "[cached_reactions[index]] [span_warning("Unable to find product [reagent_type] in holder after reaction! Trying alternative setup. index:[index]")]\n"
					failed++
					return
			say("Reaction has a product [reagent_type] [reagent.volume]u purity of [reagent.purity]")
			if(reagent.purity < 0.9)
				impure_string += "Reaction [cached_reactions[index]] has a product [reagent_type] [reagent.volume]u [span_boldwarning("purity of [reagent.purity]")] index:[index]\n"
				majorImpurity++
			else if (reagent.purity < 1)
				impure_string += "Reaction [cached_reactions[index]] has a product [reagent_type] [reagent.volume]u [span_warning("purity of [reagent.purity]")] index:[index]\n"
				minorImpurity++
			if(reagent.volume < reaction.results[reagent_type])
				impure_string += "Reaction [cached_reactions[index]] has a product [reagent_type] [span_warning("[reagent.volume]u")] purity of [reagent.purity] index:[index]\n"
			cached_purity = reagent.purity
		if(beaker_spawn && reagents.total_volume)
			var/obj/item/reagent_containers/glass/beaker/bluespace/beaker = new /obj/item/reagent_containers/glass/beaker/bluespace(loc)
			reagents.trans_to(beaker)
			beaker.name = "[cached_reactions[index]] purity: [cached_purity]"
		reagents.clear_reagents()
		reagents.chem_temp = 300
		index++
		failed = 0
	else
		say("No reagents left in beaker!")
		index++

/obj/machinery/chem_recipe_debug/proc/setup_reaction()
	react_time = 0
	if(!length(cached_reactions))
		return FALSE
	var/datum/chemical_reaction/reaction = cached_reactions[index]
	if(!reaction)
		say("Unable to find reaction on index: [index]")
	say("Using forced temperatures.")
	if(reaction.reaction_flags & REACTION_INSTANT)
		say("This reaction is instant")
	for(var/reagent_type in reaction.required_reagents)
		reagents.add_reagent(reagent_type, reaction.required_reagents[reagent_type]*vol_multiplier)
	for(var/catalyst_type in reaction.required_catalysts)
		reagents.add_reagent(catalyst_type, reaction.required_catalysts[catalyst_type])
	if(should_force_temp && !min_temp)
		say("Using forced temperatures.")
		reagents.chem_temp = force_temp ? force_temp : reaction.optimal_temp
	if(should_force_ph)
		say("Using forced pH.")
		reagents.ph = force_ph ? force_ph : (reaction.optimal_ph_max + reaction.optimal_ph_min)/2
	if(failed == 0 && !should_force_temp)
		reagents.chem_temp = reaction.optimal_temp
	if(failed == 1 && !should_force_temp)
		reagents.chem_temp = reaction.required_temp+25
		failed++
	if(min_temp)
		say("Overriding temperature to required temp.")
		reagents.chem_temp = reaction.is_cold_recipe ? reaction.required_temp - 1 : reaction.required_temp + 1
	say("Reacting [span_nicegreen("[cached_reactions[index]]")] starting pH: [reagents.ph] index [index] of [cached_reactions.len]")

/obj/machinery/chem_recipe_debug/ui_data(mob/user)
	var/data = list()
	data["targetTemp"] = force_temp
	data["targatpH"] = force_ph
	data["isActive"] = reagents.is_reacting
	data["forcepH"] = should_force_ph
	data["forceTemp"] = should_force_temp
	data["targetVol"] = vol_multiplier
	data["processAll"] = process_all
	data["currentTemp"] = reagents.chem_temp
	data["currentpH"] = round(reagents.ph, 0.01)
	data["processing"] = processing
	data["index"] = index
	data["endIndex"] = cached_reactions.len
	data["beakerSpawn"] = beaker_spawn
	data["minTemp"] = min_temp
	data["editRecipe"] = null

	var/list/beaker_contents = list()
	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		beaker_contents.len++
		beaker_contents[length(beaker_contents)] = list("name" = reagent.name, "volume" = round(reagent.volume, 0.01), "purity" = round(reagent.purity))
	data["chamberContents"] = beaker_contents

	var/list/queued_reactions = list()
	for(var/datum/chemical_reaction/reaction as anything in reaction_names)
		var/datum/reagent/reagent = find_reagent_object_from_type(reaction.results[1])
		queued_reactions.len++
		queued_reactions[length(queued_reactions)] = list("name" = reagent.name)
	data["queuedReactions"] = queued_reactions

	var/list/active_reactions = list()
	var/flashing = DISABLE_FLASHING //for use with alertAfter - since there is no alertBefore, I set the after to 0 if true, or to the max value if false
	for(var/datum/equilibrium/equilibrium as anything in reagents.reaction_list)
		if(!length(reagents.reaction_list))//I'm not sure why when it explodes it causes the gui to fail (it's missing danger (?) )
			stack_trace("Chem debug managed to find an equilibrium in a location where there should be none (skipping this entry and continuing). This is usually because of an ill timed explosion.")
			continue
		if(!equilibrium.reaction.results)//Incase of no result reactions
			continue
		var/datum/reagent/reagent = reagents.get_reagent(equilibrium.reaction.results[1]) //Reactions are named after their primary products
		if(!reagent)
			continue
		var/overheat = FALSE
		var/danger = FALSE
		var/purity_alert = 2 //same as flashing
		if(reagent.purity < equilibrium.reaction.purity_min)
			purity_alert = ENABLE_FLASHING//Because 0 is seen as null
			danger = TRUE
		if(flashing != ENABLE_FLASHING)//So that the pH meter flashes for ANY reactions out of optimal
			if(equilibrium.reaction.optimal_ph_min > reagents.ph || equilibrium.reaction.optimal_ph_max < reagents.ph)
				flashing = ENABLE_FLASHING
		if(equilibrium.reaction.is_cold_recipe)
			if(equilibrium.reaction.overheat_temp > reagents.chem_temp && equilibrium.reaction.overheat_temp != NO_OVERHEAT)
				danger = TRUE
				overheat = TRUE
		else
			if(equilibrium.reaction.overheat_temp < reagents.chem_temp)
				danger = TRUE
				overheat = TRUE
		if(equilibrium.reaction.reaction_flags & REACTION_COMPETITIVE) //We have a compeitive reaction - concatenate the results for the different reactions
			for(var/entry in active_reactions)
				if(entry["name"] == reagent.name) //If we have multiple reaction methods for the same result - combine them
					entry["reactedVol"] = equilibrium.reacted_vol
					entry["targetVol"] = round(equilibrium.target_vol, 1)//Use the first result reagent to name the reaction detected
					entry["quality"] = (entry["quality"] + equilibrium.reaction_quality) /2
					continue
		active_reactions.len++
		active_reactions[length(active_reactions)] = list("name" = reagent.name, "danger" = danger, "purityAlert" = purity_alert, "quality" = equilibrium.reaction_quality, "overheat" = overheat, "inverse" = reagent.inverse_chem_val, "minPure" = equilibrium.reaction.purity_min, "reactedVol" = equilibrium.reacted_vol, "targetVol" = round(equilibrium.target_vol, 1))//Use the first result reagent to name the reaction detected
	data["activeReactions"] = active_reactions
	data["isFlashing"] = flashing

	if(edit_recipe)
		data["editRecipeName"] = edit_recipe.type
		data["editRecipeCold"] = edit_recipe.is_cold_recipe
		data["editRecipe"] = list(
			list("name" = "required_temp" , "var" = edit_recipe.required_temp),
			list("name" = "optimal_temp" , "var" = edit_recipe.optimal_temp),
			list("name" = "overheat_temp" , "var" = edit_recipe.overheat_temp),
			list("name" = "optimal_ph_min" , "var" = edit_recipe.optimal_ph_min),
			list("name" = "optimal_ph_max" , "var" = edit_recipe.optimal_ph_max),
			list("name" = "determin_ph_range" , "var" = edit_recipe.determin_ph_range),
			list("name" = "temp_exponent_factor" , "var" = edit_recipe.temp_exponent_factor),
			list("name" = "ph_exponent_factor" , "var" = edit_recipe.ph_exponent_factor),
			list("name" = "thermic_constant" , "var" = edit_recipe.thermic_constant),
			list("name" = "H_ion_release" , "var" = edit_recipe.H_ion_release),
			list("name" = "rate_up_lim" , "var" = edit_recipe.rate_up_lim),
			list("name" = "purity_min" , "var" = edit_recipe.purity_min),
		)

	return data

/obj/machinery/chem_recipe_debug/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			return
		if("temperature")
			var/target = params["target"]
			if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				force_temp = clamp(target, 0, 1000)
		if("pH")
			var/target = params["target"]
			if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				force_ph = target
		if("forceTemp")
			should_force_temp = ! should_force_temp
			. = TRUE
		if("forcepH")
			should_force_ph = ! should_force_ph
			. = TRUE
		if("react")
			react = TRUE
			return TRUE
		if("all")
			process_all = !process_all
			return TRUE
		if("beakerSpawn")
			beaker_spawn = !beaker_spawn
			return TRUE
		if("setTargetList")
			var/text = tgui_input_text(usr, "Enter a list of Recipe product names separated by commas", "Recipe List", multiline = TRUE)
			reaction_names = list()
			if(!text)
				say("Could not find reaction")
			var/list/names = splittext("[text]", ",")
			for(var/name in names)
				var/datum/reagent/reagent = find_reagent_object_from_type(get_chem_id(name))
				if(!reagent)
					say("Could not find [name]")
					continue
				var/datum/chemical_reaction/reaction = GLOB.chemical_reactions_list_product_index[reagent.type]
				if(!reaction)
					say("Could not find [name] reaction!")
					continue
				reaction_names += reaction
		if("vol")
			var/target = params["target"]
			if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				vol_multiplier = clamp(target, 1, 200)
		if("start")
			if(processing)
				say("currently processing reaction [index]: [cached_reactions[index]] of [cached_reactions.len]")
				return
			say("Starting processing")
			index = 1
			setup_reactions()
			begin_processing()
			return TRUE
		if("stop")
			relay_all_reactions()
		if("minTemp")
			min_temp = !min_temp
		if("setEdit")
			var/name = (input("Enter the name of any reagent", "Input") as text|null)
			reaction_names = list()
			if(!text)
				say("Could not find reaction")
			var/datum/reagent/reagent = find_reagent_object_from_type(get_chem_id(name))
			if(!reagent)
				say("Could not find [name]")
				return
			var/datum/chemical_reaction/reaction = GLOB.chemical_reactions_list_product_index[reagent.type]
			if(!reaction)
				say("Could not find [name] reaction!")
				return
			edit_recipe = reaction[1]
		if("updateVar")
			var/target = params["target"]
			edit_recipe.vars[params["type"]] = target
		if("export")
			var/export = {"[edit_recipe.type]
[edit_recipe.is_cold_recipe ? "is_cold_recipe = TRUE" : ""]
required_temp = [edit_recipe.required_temp]
optimal_temp = [edit_recipe.optimal_temp]
overheat_temp = [edit_recipe.overheat_temp]
optimal_ph_min = [edit_recipe.optimal_ph_min]
optimal_ph_max = [edit_recipe.optimal_ph_max]
determin_ph_range = [edit_recipe.determin_ph_range]
temp_exponent_factor = [edit_recipe.temp_exponent_factor]
ph_exponent_factor = [edit_recipe.ph_exponent_factor]
thermic_constant = [edit_recipe.thermic_constant]
H_ion_release = [edit_recipe.H_ion_release]
rate_up_lim = [edit_recipe.rate_up_lim]
purity_min = [edit_recipe.purity_min]"}
			say(export)
			text2file(export, "[GLOB.log_directory]/chem_parse.txt")


/obj/machinery/chem_recipe_debug/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemRecipeDebug", name)
		ui.open()

///Moves a type of buffer from the heater to the beaker,

/obj/machinery/chem_recipe_debug/ui_status(mob/user)
	return UI_INTERACTIVE

/obj/machinery/chem_recipe_debug/ui_state(mob/user)
	return GLOB.physical_state
