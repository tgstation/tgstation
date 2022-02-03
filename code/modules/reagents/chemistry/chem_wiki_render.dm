//Generates a wikitable txt file for use with the wiki - does not support productless reactions at the moment
/client/proc/generate_wikichem_list()
	set category = "Debug"
	set name = "Parse Wikichems"

	//If we're a reaction product
	var/prefix_reaction = {"{| class=\"wikitable sortable\" style=\"width:100%; text-align:left; border: 3px solid #FFDD66; cellspacing=0; cellpadding=2; background-color:white;\"
! scope=\"col\" style='width:150px; background-color:#FFDD66;'|Name
! scope=\"col\" class=\"unsortable\" style='background-color:#FFDD66;'|Formula
! scope=\"col\" class=\"unsortable\" style='background-color:#FFDD66; width:170px;'|Reaction conditions
! scope=\"col\" class=\"unsortable\" style='background-color:#FFDD66;'|Description
! scope=\"col\" class=\"unsortable\" style='background-color:#FFDD66;'|Chemical properties
|-
"}

	var/input_text = tgui_input_text(usr, "Input a name of a reagent, or a series of reagents split with a comma (no spaces) to get it's wiki table entry", "Recipe") //95% of the time, the reagent type is a lowercase, no spaces / underscored version of the name
	if(!input_text)
		to_chat(usr, "Input was blank!")
		return
	text2file(prefix_reaction, "[GLOB.log_directory]/chem_parse.txt")
	var/list/names = splittext("[input_text]", ",")

	for(var/name in names)
		var/datum/reagent/reagent = find_reagent_object_from_type(get_chem_id(name))
		if(!reagent)
			to_chat(usr, "Could not find [name]. Skipping.")
			continue
		//Get reaction
		var/list/reactions = GLOB.chemical_reactions_list_product_index[reagent.type]

		if(!length(reactions))
			to_chat(usr, "Could not find [name] reaction! Continuing anyways.")
			var/single_parse = generate_chemwiki_line(reagent, null)
			text2file(single_parse, "[GLOB.log_directory]/chem_parse.txt")
			continue

		for(var/datum/chemical_reaction/reaction as anything in reactions)
			var/single_parse = generate_chemwiki_line(reagent, reaction)
			text2file(single_parse, "[GLOB.log_directory]/chem_parse.txt")
	text2file("|}", "[GLOB.log_directory]/chem_parse.txt") //Cap off the table
	to_chat(usr, "Done! Saved file to (wherever your root folder is, i.e. where the DME is)/[GLOB.log_directory]/chem_parse.txt OR use the Get Current Logs verb under the Admin tab. (if you click Open, and it does nothing, that's because you've not set a .txt default program! Try downloading it instead, and use that file to set a default program! Have a nice day!")


/// Generate the big list of reagent based reactions.
/proc/generate_chemwiki_line(datum/reagent/reagent, datum/chemical_reaction/reaction)
	//name | Reagent pH | reagents | reaction temp | Overheat temp | pH range | Kinetics | description | OD level | Addiction level | Metabolism rate | impure chem | inverse chem

	//NAME
	//!style='background-color:#FFEE88;'|{{anchor|Synthetic-derived growth factor}}Synthetic-derived growth factor<span style="color:#A502E0;background-color:white">▮</span>
	var/outstring = "!style='background-color:#FFEE88;'|{{anchor|[reagent.name]}}[reagent.name]<span style=\"color:[reagent.color];background-color:white\">▮</span>"
	//Impurities
	if(istype(reagent, /datum/reagent/impurity))
		outstring += "\n<br>Impure reagent"

	if(istype(reagent, /datum/reagent/inverse))
		outstring += "\n<br>Inverse reagent"

	else
		var/datum/reagent/impure_reagent = GLOB.chemical_reagents_list[reagent.impure_chem]
		if(impure_reagent)
			outstring += "\n<br>Impurity: \[\[#[impure_reagent.name]|[impure_reagent.name]\]\]"

		var/datum/reagent/inverse_reagent = GLOB.chemical_reagents_list[reagent.inverse_chem]
		if(inverse_reagent)
			outstring += "\n<br>Inverse: \[\[#[inverse_reagent.name]|[inverse_reagent.name]\]\] <[reagent.inverse_chem_val*100]%"

		var/datum/reagent/failed_reagent = GLOB.chemical_reagents_list[reagent.failed_chem]
		if(failed_reagent && reaction)
			outstring += "\n<br>Failed: \[\[#[failed_reagent.name]|[failed_reagent.name]\]\] <[reaction.purity_min*100]%"
	var/ph_color
	CONVERT_PH_TO_COLOR(reagent.ph, ph_color)
	outstring += "\n<br>pH: [reagent.ph]<span style=\"color:[ph_color];background-color:white\">▮</span>"
	outstring += "\n|"

	//RECIPE
	//|{{RecursiveChem/Oil}}
	if(reaction)
		outstring += "{{RecursiveChem/[reagent.name]}}"
		outstring += "\n|"

		//Reaction conditions
		//min temp
		if(reaction.is_cold_recipe)
			outstring += "<b>Cold reaction</b>\n<br>"
		outstring += "<b>Min temp:</b> [reaction.required_temp]K\n<br><b>Overheat:</b> [reaction.overheat_temp]K\n<br><b>Optimal pH:</b> [reaction.optimal_ph_min] to [reaction.optimal_ph_max]"

		//Overly impure levels
		if(reaction.purity_min)
			outstring += "\n<br><b>Unstable purity:</b> <[reaction.purity_min*100]%"

		//Kinetics
		var/thermic = reaction.thermic_constant
		if(reaction.reaction_flags & REACTION_HEAT_ARBITARY)
			thermic *= 100 //Because arbitary is a lower scale
		switch(thermic)
			if(-INFINITY to -1500)
				outstring += "\n<br>Overwhelmingly endothermic"
			if(-1500 to -1000)
				outstring += "\n<br>Extremely endothermic"
			if(-1000 to -500)
				outstring += "\n<br>Strongly endothermic"
			if(-500 to -200)
				outstring += "\n<br>Moderately endothermic"
			if(-200 to -50)
				outstring += "\n<br>Endothermic"
			if(-50 to 0)
				outstring += "\n<br>Weakly endothermic"
			if(0)
				outstring += "\n<br>"
			if(0 to 50)
				outstring += "\n<br>Weakly Exothermic"
			if(50 to 200)
				outstring += "\n<br>Exothermic"
			if(200 to 500)
				outstring += "\n<br>Moderately exothermic"
			if(500 to 1000)
				outstring += "\n<br>Strongly exothermic"
			if(1000 to 1500)
				outstring += "\n<br>Extremely exothermic"
			if(1500 to INFINITY)
				outstring += "\n<br>Overwhelmingly exothermic"
			//if("cheesey")
				//outstring += "<br>Dangerously Cheesey"

		//pH drift
		if(reaction.results)
			var/start_ph = 0
			var/reactant_vol = 0
			for(var/typepath in reaction.required_reagents)
				var/datum/reagent/req_reagent = GLOB.chemical_reagents_list[typepath]
				start_ph += req_reagent.ph * reaction.required_reagents[typepath]
				reactant_vol += reaction.required_reagents[typepath]

			var/product_vol = 0
			var/end_ph = 0
			for(var/typepath in reaction.results)
				var/datum/reagent/prod_reagent = GLOB.chemical_reagents_list[typepath]
				end_ph += prod_reagent.ph * reaction.results[typepath]
				product_vol += reaction.results[typepath]

			if(reactant_vol || product_vol)
				start_ph = start_ph / reactant_vol
				end_ph = end_ph / product_vol
				var/sum_change = end_ph - start_ph
				sum_change += reaction.H_ion_release

				if(sum_change > 0)
					outstring += "\n<br>H+ consuming"
				else if (sum_change < 0)
					outstring += "\n<br>H+ producing"
			else
				to_chat(usr, "[reaction] doesn't have valid product and reagent volumes! Please tell Fermi.")
		else
			if(reaction.H_ion_release > 0)
				outstring += "\n<br>H+ consuming"
			else if (reaction.H_ion_release < 0)
				outstring += "\n<br>H+ producing"

		//container
		if(reaction.required_container)
			var/list/names = splittext("[reaction.required_container]", "/")
			var/container_name = "[names[names.len]] [names[names.len-1]]"
			container_name = replacetext(container_name, "_", " ")
			outstring += "\n<br>[container_name]"

		//Warn if it's dangerous
		if(reaction.reaction_tags & REACTION_TAG_DANGEROUS)
			outstring += "\n<br><b>Dangerous</b>"
		outstring += "\n|"

	//Description
	outstring += "[reagent.description]"
	outstring += "\n|"

	//Chemical properties - *2 because 1 tick is every 2s
	outstring += "<b>Rate:</b> [reagent.metabolization_rate*2]u/tick\n<br><b>Unreacted purity:</b> [reagent.creation_purity*100]%[(reagent.overdose_threshold ? "\n<br><b>OD:</b> [reagent.overdose_threshold]u" : "")]"

	if(length(reagent.addiction_types))
		outstring += "\n<br><b>Addictions:</b>"
	for(var/entry in reagent.addiction_types)
		var/datum/addiction/ref = SSaddiction.all_addictions[entry]
		switch(reagent.addiction_types[entry])
			if(-INFINITY to 0)
				continue
			if(0 to 5)
				outstring += "\n<br>Weak [ref.name]"
			if(5 to 10)
				outstring += "\n<br>[ref.name]"
			if(10 to 20)
				outstring += "\n<br>Strong [ref.name]"
			if(20 to INFINITY)
				outstring += "\n<br>Potent [ref.name]"

	if(reagent.chemical_flags & REAGENT_DEAD_PROCESS)
		outstring += "\n<br>Works on the dead"

	if(reagent.chemical_flags & REAGENT_CLEANS)
		outstring += "\n<br>Sanitizes well"

	outstring += "\n|-"
	return outstring
