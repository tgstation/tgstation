
//Techweb nodes are GLOBAL, there should only be one instance of them in the game. Persistant changes should never be made to them in-game.

/datum/techweb_node
	var/id
	var/display_name = "Errored Node"
	var/description = "Why are you seeing this?"
	var/hidden = FALSE			//Whether it starts off hidden.
	var/starting_node = FALSE	//Whether it's available without any research.
	var/list/prereq_ids = list()			//id = TRUE
	var/list/design_ids = list()			//id = TRUE
	var/list/unlock_ids = list()			//CALCULATED FROM OTHER NODE'S PREREQUISITES. Assoc list id = TRUE
	var/list/boost_item_paths = list()		//Associative list, path = list(point type = point_value).
	var/autounlock_by_boost = TRUE			//boosting this will autounlock this node.
	var/export_price = 0					//Cargo export price.
	var/list/research_costs = list()					//Point cost to research. type = amount
	var/category = "Misc"				//Category

/datum/techweb_node/serialize_list(list/options)
	var/list/jsonlist = list()
	if(istext(id))
		jsonlist["id"] = id
	if(istext(display_name))
		jsonlist["display_name"] = display_name
	if(istext(description))
		jsonlist["description"] = description
	if(isnum(hidden))
		jsonlist["hidden"] = hidden
	if(isnum(starting_node))
		jsonlist["starting_node"] = starting_node
	if(islist(prereq_ids))
		jsonlist["prereq_ids"] = prereq_ids
	if(islist(design_ids))
		jsonlist["design_ids"] = design_ids
	if(islist(boost_item_paths))
		jsonlist["boost_item_paths"] = boost_item_paths
	if(isnum(autounlock_by_boost))
		jsonlist["autounlock_by_boost"] = autounlock_by_boost
	if(isnum(export_price))
		jsonlist["export_price"] = export_price
	if(islist(research_costs))
		jsonlist["research_costs"] = research_costs
	if(istext(category))
		jsonlist["category"] = category
	return jsonlist

/datum/techweb_node/deserialize_list(list/jsonlist, list/options)
	if(!islist(jsonlist))
		if(!istext(jsonlist))
			CRASH("Invalid JSON")
			return
		jsonlist = json_decode(jsonlist)
		if(!islist(jsonlist))
			CRASH("Invalid JSON")
			return
	if(istext(jsonlist["id"]))
		id = jsonlist["id"]
	if(istext(jsonlist["display_name"]))
		display_name = jsonlist["display_name"]
	if(istext(jsonlist["description"]))
		description = jsonlist["description"]
	if(isnum(jsonlist["hidden"]))
		hidden = jsonlist["hidden"]
	if(isnum(jsonlist["starting_node"]))
		starting_node = jsonlist["starting_node"]
	if(islist(jsonlist["prereq_ids"]))
		prereq_ids = jsonlist["prereq_ids"]
	if(islist(jsonlist["design_ids"]))
		design_ids = jsonlist["design_ids"]
	if(islist(jsonlist["boost_item_paths"]))
		boost_item_paths = jsonlist["boost_item_paths"]
	if(isnum(jsonlist["autounlock_by_boost"]))
		autounlock_by_boost = jsonlist["autounlock_by_boost"]
	if(isnum(jsonlist["export_price"]))
		export_price = jsonlist["export_price"]
	if(islist(jsonlist["research_costs"]))
		research_costs = jsonlist["research_costs"]
	if(istext(jsonlist["category"]))
		category = jsonlist["category"]
	return src

/datum/techweb_node/proc/prune()
	for(var/i in prereq_ids)
		if(!get_techweb_node_by_id(i))
			prereq_ids -= i
	for(var/i in unlock_ids)
		if(!get_techweb_node_by_id(i))
			unlock_ids -= i
	for(var/i in design_ids)
		if(!get_techweb_design_by_id(i))
			design_ids -= i
	for(var/i in boost_item_paths)
		if(!ispath(i))
			if(istext(i))
				var/changed = text2path(i)
				if(ispath(changed))
					var/val = boost_item_paths[i]
					boost_item_paths -= i
					boost_item_paths[changed] = val
				else
					boost_item_paths -= i
			else
				boost_item_paths -= i

/datum/techweb_node/proc/prepare_lists()
	for(var/i in prereq_ids)
		prereq_ids[i] = TRUE
	for(var/i in design_ids)
		design_ids[i] = TRUE
	for(var/i in unlock_ids)
		unlock_ids[i] = TRUE

/datum/techweb_node/proc/get_price(datum/techweb/host)
	if(host)
		var/list/actual_costs = research_costs
		if(host.boosted_node_ids[id])
			var/list/L = host.boosted_node_ids[id]
			for(var/i in L)
				if(actual_costs[i])
					actual_costs[i] -= L[i]
		return actual_costs
	else
		return research_costs

/datum/techweb_node/proc/price_display(datum/techweb/TN)
	return techweb_point_display_generic(get_price(TN))
