/datum/computer_file/program/research
	filename = "research"
	filedesc = "Research and Development"
	program_icon_state = "research"
	extended_desc = "NT's proprietary management software for research and development."
	requires_ntnet = TRUE
	size = 5
	tgui_id = "NtosResearch"
	program_icon = "flask"
	transfer_access = ACCESS_HEADS

/datum/computer_file/program/research/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/research_designs),
	)

/datum/computer_file/program/research/ui_data(mob/user)
	var/list/data = get_header_data()
	// Points
	data["research_points"] = SSresearch.science_tech.research_points
	// Research Servers
	data["servers"] = list()
	for(var/obj/machinery/rnd/server/S in SSresearch.servers)
		data["servers"] += list(S.ui_data())
	// Tech
	data["researched_nodes"] = SSresearch.science_tech.get_researched_nodes()
	data["available_nodes"] = SSresearch.science_tech.get_available_nodes()
	data["visible_nodes"] = SSresearch.science_tech.get_visible_nodes()
	data["hidden_nodes"] = SSresearch.science_tech.hidden_nodes
	// Queue
	data["research_queue"] = SSresearch.science_tech.research_queue
	data["researching_nodes"] = SSresearch.science_tech.researching_nodes
	return data

/datum/computer_file/program/research/ui_static_data(mob/user)
	return SSresearch.science_tech.serialized_ui_data;

/datum/computer_file/program/research/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/datum/techweb_node/N = SSresearch.techweb_node_by_id(params["node_id"])
	if(!N)
		to_chat(usr, "<span class='warning'>R&D Console: Unable to find research node `[params["node_id"]]`.</span>")
		return FALSE
	switch(action)
		if("add_node_to_queue")
			var/pos = SSresearch.science_tech.add_research_to_queue(N)
			if(!pos)
				to_chat(usr, "<span class='warning'>R&D Console: Failed to add research node `[params["node_id"]]` to the techweb queue.</span>")
			return TRUE
		if("remove_node_from_queue")
			var/pos = SSresearch.science_tech.remove_research_from_queue(N)
			if(!pos)
				to_chat(usr, "<span class='warning'>R&D Console: Failed to remove research node `[params["node_id"]]` from the techweb queue.</span>")
			return TRUE
		if("boost_node")
			if(SSresearch.science_tech.researched_nodes[N.id])
				to_chat(usr, "<span class='warning'>R&D Console: Failed to boost research node `[params["node_id"]]` as it is already researched.</span>")
				return FALSE
			if(!SSresearch.science_tech.available_nodes[N.id])
				to_chat(usr, "<span class='warning'>R&D Console: Failed to boost research node `[params["node_id"]]` as it is not available.</span>")
				return FALSE
			// Attempts to instantly unlock a node by spending pooled research points.
			var/list/points_to_spend = list()
			for(var/pool in SSresearch.science_tech.research_points)
				// Points in this pool?
				if(!SSresearch.science_tech.research_points[pool])
					continue
				var/points = SSresearch.science_tech.research_points[pool]
				// Can this node accept points from pool?
				// Can be FALSE if we already researched this pool, or if it doesn't need it.
				if(!SSresearch.science_tech.can_node_use_research_points(N, pool))
					continue
				// Determine how much progress already exists in this pool.
				var/progress = 0
				// If statement written like this because we may not have any research in this node or for this pool.
				if(!SSresearch.science_tech.researching_nodes[N.id])
					progress = 0
				else if(!SSresearch.science_tech.researching_nodes[N.id][pool])
					progress = 0
				else
					progress = SSresearch.science_tech.researching_nodes[N.id][pool]
				var/remainder = N.research_costs[pool] - progress
				// Spend either what we need to, or all we have - whichever is less.
				var/points_used = min(remainder, points)
				// Deduct spend
				SSresearch.science_tech.research_points[pool] -= points_used
				// Add to (pool => points,) spent after all math is done.
				points_to_spend[pool] = points_used
			if(points_to_spend.len == 0)
				return FALSE
			SSresearch.science_tech.add_research_points_to_node(N, points_to_spend)
			return TRUE
