
/proc/initialize_all_techweb_nodes(clearall = FALSE)
	if(islist(SSresearch.techweb_nodes) && clearall)
		QDEL_LIST(SSresearch.techweb_nodes)
	if(islist(SSresearch.techweb_nodes_starting && clearall))
		QDEL_LIST(SSresearch.techweb_nodes_starting)
	var/list/returned = list()
	for(var/path in subtypesof(/datum/techweb_node))
		var/datum/techweb_node/TN = path
		if(isnull(initial(TN.id)))
			continue
		TN = new path
		if(returned[initial(TN.id)])
			stack_trace("WARNING: Techweb node ID clash with ID [initial(TN.id)] detected!")
			SSresearch.errored_datums[TN] = initial(TN.id)
			continue
		returned[initial(TN.id)] = TN
		if(TN.starting_node)
			SSresearch.techweb_nodes_starting[TN.id] = TN
	SSresearch.techweb_nodes = returned
	verify_techweb_nodes()				//Verify all nodes have ids and such.
	calculate_techweb_nodes()
	calculate_techweb_boost_list()
	verify_techweb_nodes()		//Verify nodes and designs have been crosslinked properly.

/proc/initialize_all_techweb_designs(clearall = FALSE)
	if(islist(SSresearch.techweb_designs) && clearall)
		QDEL_LIST(SSresearch.techweb_designs)
	var/list/returned = list()
	for(var/path in subtypesof(/datum/design))
		var/datum/design/DN = path
		if(isnull(initial(DN.id)))
			stack_trace("WARNING: Design with null ID detected. Build path: [initial(DN.build_path)]")
			continue
		else if(initial(DN.id) == DESIGN_ID_IGNORE)
			continue
		DN = new path
		if(returned[initial(DN.id)])
			stack_trace("WARNING: Design ID clash with ID [initial(DN.id)] detected!")
			SSresearch.errored_datums[DN] = initial(DN.id)
			continue
		returned[initial(DN.id)] = DN
	SSresearch.techweb_designs = returned
	verify_techweb_designs()

/proc/count_unique_techweb_nodes()
	var/static/list/L = typesof(/datum/techweb_node)
	return L.len

/proc/count_unique_techweb_designs()
	var/static/list/L = typesof(/datum/design)
	return L.len

/proc/get_techweb_node_by_id(id)
	if(SSresearch.techweb_nodes[id])
		return SSresearch.techweb_nodes[id]

/proc/get_techweb_design_by_id(id)
	if(SSresearch.techweb_designs[id])
		return SSresearch.techweb_designs[id]

/proc/research_node_id_error(id)
	if(SSresearch.invalid_node_ids[id])
		SSresearch.invalid_node_ids[id]++
	else
		SSresearch.invalid_node_ids[id] = 1

/proc/design_id_error(id)
	if(SSresearch.invalid_design_ids[id])
		SSresearch.invalid_design_ids[id]++
	else
		SSresearch.invalid_design_ids[id] = 1

/proc/node_boost_error(id, message)
	WARNING("Invalid boost information for node \[[id]\]: [message]")
	SSresearch.invalid_node_boost[id] = message

/proc/verify_techweb_nodes()
	for(var/n in SSresearch.techweb_nodes)
		var/datum/techweb_node/N = SSresearch.techweb_nodes[n]
		if(!istype(N))
			WARNING("Invalid research node with ID [n] detected and removed.")
			SSresearch.techweb_nodes -= n
			research_node_id_error(n)
		for(var/p in N.prereq_ids)
			var/datum/techweb_node/P = SSresearch.techweb_nodes[p]
			if(!istype(P))
				WARNING("Invalid research prerequisite node with ID [p] detected in node [N.display_name]\[[N.id]\] removed.")
				N.prereq_ids  -= p
				research_node_id_error(p)
		for(var/d in N.design_ids)
			var/datum/design/D = SSresearch.techweb_designs[d]
			if(!istype(D))
				WARNING("Invalid research design with ID [d] detected in node [N.display_name]\[[N.id]\] removed.")
				N.designs -= d
				design_id_error(d)
		for(var/p in N.prerequisites)
			var/datum/techweb_node/P = N.prerequisites[p]
			if(!istype(P))
				WARNING("Invalid research prerequisite node with ID [p] detected in node [N.display_name]\[[N.id]\] removed.")
				N.prerequisites -= p
				research_node_id_error(p)
		for(var/u in N.unlocks)
			var/datum/techweb_node/U = N.unlocks[u]
			if(!istype(U))
				WARNING("Invalid research unlock node with ID [u] detected in node [N.display_name]\[[N.id]\] removed.")
				N.unlocks -= u
				research_node_id_error(u)
		for(var/d in N.designs)
			var/datum/design/D = N.designs[d]
			if(!istype(D))
				WARNING("Invalid research design with ID [d] detected in node [N.display_name]\[[N.id]\] removed.")
				N.designs -= d
				design_id_error(d)
		for(var/p in N.boost_item_paths)
			if(!ispath(p))
				N.boost_item_paths -= p
				node_boost_error(N.id, "[p] is not a valid path.")
			var/list/points = N.boost_item_paths[p]
			if(islist(points))
				for(var/i in points)
					if(!isnum(points[i]))
						node_boost_error(N.id, "[points[i]] is not a valid number.")
					else if(!SSresearch.point_types[i])
						node_boost_error(N.id, "[i] is not a valid point type.")
			else if(!isnull(points))
				N.boost_item_paths -= p
				node_boost_error(N.id, "No valid list.")
		CHECK_TICK

/proc/verify_techweb_designs()
	for(var/d in SSresearch.techweb_designs)
		var/datum/design/D = SSresearch.techweb_designs[d]
		if(!istype(D))
			stack_trace("WARNING: Invalid research design with ID [d] detected and removed.")
			SSresearch.techweb_designs -= d
		CHECK_TICK

/proc/calculate_techweb_nodes()
	for(var/design_id in SSresearch.techweb_designs)
		var/datum/design/D = SSresearch.techweb_designs[design_id]
		D.unlocked_by.Cut()
	for(var/node_id in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		node.prerequisites = list()
		node.unlocks = list()
		node.designs = list()
		for(var/i in node.prereq_ids)
			node.prerequisites[i] = SSresearch.techweb_nodes[i]
		for(var/i in node.design_ids)
			var/datum/design/D = SSresearch.techweb_designs[i]
			node.designs[i] = D
			D.unlocked_by += node
		if(node.hidden)
			SSresearch.techweb_nodes_hidden[node.id] = node
		CHECK_TICK
	generate_techweb_unlock_linking()

/proc/generate_techweb_unlock_linking()
	for(var/node_id in SSresearch.techweb_nodes)						//Clear all unlock links to avoid duplication.
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		node.unlocks = list()
	for(var/node_id in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		for(var/prereq_id in node.prerequisites)
			var/datum/techweb_node/prereq_node = node.prerequisites[prereq_id]
			prereq_node.unlocks[node.id] = node

/proc/calculate_techweb_boost_list(clearall = FALSE)
	if(clearall)
		SSresearch.techweb_boost_items = list()
	for(var/node_id in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		for(var/path in node.boost_item_paths)
			if(!ispath(path))
				continue
			if(length(SSresearch.techweb_boost_items[path]))
				SSresearch.techweb_boost_items[path][node.id] = node.boost_item_paths[path]
			else
				SSresearch.techweb_boost_items[path] = list(node.id = node.boost_item_paths[path])
		CHECK_TICK

/proc/techweb_item_boost_check(obj/item/I)			//Returns an associative list of techweb node datums with values of the boost it gives.	var/list/returned = list()
	if(SSresearch.techweb_boost_items[I.type])
		return SSresearch.techweb_boost_items[I.type]		//It should already be formatted in node datum = list(point type = value)

/proc/techweb_item_point_check(obj/item/I)
	if(SSresearch.techweb_point_items[I.type])
		return SSresearch.techweb_point_items[I.type]

/proc/techweb_point_display_generic(pointlist)
	var/list/ret = list()
	for(var/i in pointlist)
		if(SSresearch.point_types[i])
			ret += "[SSresearch.point_types[i]]: [pointlist[i]]"
		else
			ret += "ERRORED POINT TYPE: [pointlist[i]]"
	return ret.Join("<BR>")

/proc/techweb_point_display_rdconsole(pointlist, last_pointlist)
	var/list/ret = list()
	for(var/i in pointlist)
		ret += "[SSresearch.point_types[i] || "ERRORED POINT TYPE"]: [pointlist[i]] (+[(last_pointlist[i]) * ((SSresearch.flags & SS_TICKER)? (600 / (world.tick_lag * SSresearch.wait)) : (600 / SSresearch.wait))]/ minute)"
	return ret.Join("<BR>")
