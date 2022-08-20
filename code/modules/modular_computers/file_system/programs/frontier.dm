/datum/computer_file/program/scipaper_program
	filename = "ntfrontier"
	filedesc = "NT Frontier"
	category = PROGRAM_CATEGORY_SCI
	extended_desc = "Scientific paper publication and navigation software."
	requires_ntnet = TRUE
	size = 12
	program_icon_state = "research"
	tgui_id = "NtosScipaper"
	program_icon = "paper-plane"
	transfer_access = list(ACCESS_ORDNANCE)

	var/datum/techweb/linked_techweb
	/// Unpublished, temporary paper datum.
	var/datum/scientific_paper/paper_to_be
	/// Here to reduce load. Corresponds to the tab in the UI.
	var/current_tab = 1
	/// The file under consideration.
	var/datum/computer_file/data/ordnance/selected_file

/datum/computer_file/program/scipaper_program/New()
	. = ..()
	paper_to_be = new

/datum/computer_file/program/scipaper_program/on_start(mob/living/user)
	. = ..()
	linked_techweb = SSresearch.science_tech

/datum/computer_file/program/scipaper_program/proc/recheck_file_presence()
	if(selected_file in holder.stored_files)
		return FALSE
	UnregisterSignal(selected_file, COMSIG_MODULAR_COMPUTER_FILE_DELETED)
	selected_file = null
	paper_to_be.set_experiment()

/datum/computer_file/program/scipaper_program/ui_static_data(mob/user)
	var/list/data = list()
	var/list/parsed_experiments = list()
	for (var/datum/experiment/ordnance/experiment in SSresearch.ordnance_experiments)
		var/list/singular_experiment = list()
		singular_experiment["path"] = experiment.type
		singular_experiment["name"] = experiment.name
		singular_experiment["description"] = experiment.description
		singular_experiment["target"] = experiment.target_amount
		if(istype(experiment, /datum/experiment/ordnance/explosive))
			singular_experiment["suffix"] = "tiles"
			singular_experiment["prefix"] = "Range"
		else if(istype(experiment, /datum/experiment/ordnance/gaseous))
			singular_experiment["suffix"] = "moles"
			singular_experiment["prefix"] = "Gas"
		parsed_experiments += list(singular_experiment)

	var/list/parsed_partners = list()
	for (var/datum/scientific_partner/partner in SSresearch.scientific_partners)
		var/list/singular_partner = list()
		singular_partner["name"] = partner.name
		singular_partner["flufftext"] = partner.flufftext
		singular_partner["multipliers"] = partner.multipliers
		singular_partner["path"] = partner.type
		singular_partner["boostedNodes"] = list()
		singular_partner["acceptedExperiments"] = list()
		for (var/node_id in partner.boosted_nodes)
			var/datum/techweb_node/node = SSresearch.techweb_node_by_id(node_id)
			singular_partner["boostedNodes"] += list(list("name" = node.display_name, "discount" = partner.boosted_nodes[node_id], "id"=node_id))
		for (var/datum/experiment/ordnance/ordnance_experiment as anything in partner.accepted_experiments)
			singular_partner["acceptedExperiments"] += initial(ordnance_experiment.name)
		parsed_partners += list(singular_partner)

	data["experimentInformation"] = parsed_experiments
	data["partnersInformation"] = parsed_partners
	data["coopIndex"] = SCIPAPER_COOPERATION_INDEX
	data["fundingIndex"] = SCIPAPER_FUNDING_INDEX
	return data

/datum/computer_file/program/scipaper_program/ui_data()
	// Program Headers:
	var/list/data = get_header_data()
	data["currentTab"]  = current_tab

	// First page. Form submission.
	if(current_tab == 1)
		data["fileList"] = list()
		data["expList"] = list()
		data["allowedTiers"] = list()
		data["allowedPartners"] =  list()
		// Both the file and experiment list are assoc lists. ID as value, display name as keys.
		for(var/datum/computer_file/data/ordnance/ordnance_file in holder.stored_files)
			data["fileList"] += list(ordnance_file.filename = ordnance_file.uid)
		if(selected_file)
			for (var/possible_experiment in selected_file.possible_experiments)
				var/datum/experiment/ordnance/experiment = possible_experiment
				data["expList"] += list(initial(experiment.name) = experiment)
		data["allowedTiers"] = paper_to_be.calculate_tier()
		for (var/partner in SSresearch.scientific_partners)
			var/datum/scientific_partner/scientific_partner = partner
			if(paper_to_be.experiment_path in scientific_partner.accepted_experiments)
				data["allowedPartners"] += list(scientific_partner.name = scientific_partner.type)

		data += paper_to_be.return_gist()
		data["selectedFile"] = selected_file?.filename
		// Renamed both of these to be more topical.
		data["selectedExperiment"] = data["experimentName"]
		data -= "experimentName"
		data["selectedPartner"] = data["partner"]
		data -= "partner"

	// Second page. View previous
	if(current_tab == 2)
		data["publishedPapers"] = list()
		for (var/experiment_types in linked_techweb.published_papers)
			for (var/datum/scientific_paper/paper in linked_techweb.published_papers[experiment_types])
				data["publishedPapers"] += list(paper.return_gist())

	if(current_tab == 4)
		data["purchaseableBoosts"] = list()
		data["relations"] = list()
		var/list/visible_nodes = list()
		visible_nodes += linked_techweb.get_available_nodes()
		visible_nodes += linked_techweb.get_researched_nodes()
		data["visibleNodes"] = list()
		for (var/id in visible_nodes)
			if(visible_nodes[id])
				data["visibleNodes"] += id

		for (var/datum/scientific_partner/partner as anything in SSresearch.scientific_partners)
			var/relations = linked_techweb.scientific_cooperation[partner.type]
			switch (round(relations / SCIENTIFIC_COOPERATION_PURCHASE_MULTIPLIER)) // We use points to determine these
				if(-INFINITY to 0)
					data["relations"][partner.type] = "Nonexistant"
				if(1 to 2499)
					data["relations"][partner.type] = "Negligible"
				if(2500 to 4999)
					data["relations"][partner.type] = "Limited"
				if(5000 to 9999)
					data["relations"][partner.type] = "Cordial"
				if(10000 to 19999)
					data["relations"][partner.type] = "Partners"
				if(20000 to INFINITY)
					data["relations"][partner.type] = "Devoted"
				else
					data["relations"][partner.type] = "Undefined"
			data["purchaseableBoosts"][partner.type] = list()
			for(var/node_id in linked_techweb.get_available_nodes())
				// Not from our partner
				if(!(node_id in partner.boosted_nodes))
					continue
				if(!partner.allowed_to_boost(linked_techweb, node_id))
					continue
				data["purchaseableBoosts"][partner.type] += node_id
	return data

/datum/computer_file/program/scipaper_program/ui_act(action, params)
	. = ..()
	if (.)
		return

	switch(action)
		if("et_alia")
			paper_to_be.et_alia = !paper_to_be.et_alia
			return TRUE
		// Handle the publication
		if("publish")
			publish()
			return TRUE
		// For every change in the input, we correspond it with the paper_data list and update it.
		if("rewrite")
			if(length(params))
				for (var/changed_entry in params)
					if (changed_entry == "title")
						paper_to_be.title = sanitize(params[changed_entry])
					if (changed_entry == "author")
						paper_to_be.author = sanitize(params[changed_entry])
					if (changed_entry == "abstract")
						paper_to_be.abstract = sanitize(params[changed_entry])
				return TRUE
		if("change_tab")
			current_tab = params["new_tab"]
			return TRUE
		if("select_file") // Selecting new file will necessitate a change in paper type. This will be done on select_experiment and not here.
			if(selected_file)
				UnregisterSignal(selected_file, COMSIG_MODULAR_COMPUTER_FILE_DELETED)
			paper_to_be.set_experiment() // Clears the paper info.
			for(var/datum/computer_file/data/ordnance/ordnance_data in holder.stored_files)
				if(ordnance_data.uid == params["selected_uid"])
					selected_file = ordnance_data
					RegisterSignal(selected_file, COMSIG_MODULAR_COMPUTER_FILE_DELETED, .proc/recheck_file_presence)
					return TRUE
		if("select_experiment")
			var/ex_path = text2path(params["selected_expath"])
			var/variable = selected_file.possible_experiments[text2path(params["selected_expath"])]
			var/data = null
			if(ispath(ex_path, /datum/experiment/ordnance/explosive))
				paper_to_be = paper_to_be.clone_into(/datum/scientific_paper/explosive)
			if(ispath(ex_path, /datum/experiment/ordnance/gaseous))
				paper_to_be = paper_to_be.clone_into(/datum/scientific_paper/gaseous)
			data = selected_file.return_data()
			paper_to_be.set_experiment(ex_path, variable, data)
			return TRUE
		if("select_tier")
			paper_to_be.set_tier(params["selected_tier"])
			return TRUE
		if("select_partner")
			paper_to_be.set_partner(text2path(params["selected_partner"]), linked_techweb)
			return TRUE
		if("purchase_boost")
			var/datum/scientific_partner/partner = locate(text2path(params["boost_seller"])) in SSresearch.scientific_partners
			var/datum/techweb_node/node = SSresearch.techweb_node_by_id(params["purchased_boost"])
			if(partner && node)
				if(partner.purchase_boost(linked_techweb, node))
					computer.say("Purchase succesful.")
					playsound(computer, 'sound/machines/ping.ogg', 25)
					return TRUE
			playsound(computer, 'sound/machines/terminal_error.ogg', 25)
			return FALSE

/// Publication and adding points.
/datum/computer_file/program/scipaper_program/proc/publish()
	if(linked_techweb.add_scientific_paper(paper_to_be))
		computer.say("\"[paper_to_be.title]\" has been published!")
		paper_to_be = new
		UnregisterSignal(selected_file, COMSIG_MODULAR_COMPUTER_FILE_DELETED)
		selected_file = null
		SStgui.update_uis(src)
		playsound(computer, 'sound/machines/ping.ogg', 25)
		return TRUE
	playsound(computer, 'sound/machines/terminal_error.ogg', 25)
	return FALSE
