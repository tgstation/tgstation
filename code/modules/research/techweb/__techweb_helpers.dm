
/proc/initialize_all_techweb_nodes(clearall = FALSE)
	if(islist(GLOB.techweb_nodes) && clearall)
		QDEL_LIST(GLOB.techweb_nodes)
	if(islist(GLOB.techweb_nodes_starting && clearall))
		QDEL_LIST(GLOB.techweb_nodes_starting)
	var/list/returned = list()
	for(var/path in subtypesof(/datum/techweb_node))
		var/datum/techweb_node/TN = path
		if(isnull(initial(TN.id)))
			continue
		TN = new path
		returned[initial(TN.id)] = TN
		if(TN.starting_node)
			GLOB.techweb_nodes_starting[TN.id] = TN
	GLOB.techweb_nodes = returned
	verify_techweb_nodes()
	calculate_techweb_nodes()
	calculate_techweb_boost_list()
	verify_techweb_nodes()

/proc/initialize_all_techweb_designs(clearall = FALSE)
	if(islist(GLOB.techweb_designs) && clearall)
		QDEL_LIST(GLOB.techweb_designs)
	var/list/returned = list()
	for(var/path in subtypesof(/datum/design))
		var/datum/design/DN = path
		if(isnull(initial(DN.id)))
			continue
		DN = new path
		returned[initial(DN.id)] = DN
	GLOB.techweb_designs = returned
	verify_techweb_designs()

/proc/get_techweb_node_by_id(id)
	if(GLOB.techweb_nodes[id])
		return GLOB.techweb_nodes[id]

/proc/get_techweb_design_by_id(id)
	if(GLOB.techweb_designs[id])
		return GLOB.techweb_designs[id]

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

/proc/verify_techweb_nodes()
	for(var/n in GLOB.techweb_nodes)
		var/datum/techweb_node/N = GLOB.techweb_nodes[n]
		if(!istype(N))
			stack_trace("WARNING: Invalid research node with ID [n] detected and removed.")
			GLOB.techweb_nodes -= n
			research_node_id_error(n)
		for(var/p in N.prerequisites)
			var/datum/techweb_node/P = N.prerequisites[p]
			if(!istype(P))
				stack_trace("WARNING: Invalid research prerequisite node with ID [p] detected in node [N.display_name]\[[N.id]\] removed.")
				N.prerequisites -= p
				research_node_id_error(p)
		for(var/u in N.unlocks)
			var/datum/techweb_node/U = N.unlocks[u]
			if(!istype(U))
				stack_trace("WARNING: Invalid research unlock node with ID [u] detected in node [N.display_name]\[[N.id]\] removed.")
				N.unlocks -= u
				research_node_id_error(u)
		for(var/d in N.designs)
			var/datum/design/D = N.designs[d]
			if(!istype(D))
				stack_trace("WARNING: Invalid research design with ID [d] detected in node [N.display_name]\[[N.id]\] removed.")
				N.designs -= d
				design_id_error(d)
		CHECK_TICK

/proc/verify_techweb_designs()
	for(var/d in GLOB.techweb_designs)
		var/datum/design/D = GLOB.techweb_designs[d]
		if(!istype(D))
			stack_trace("WARNING: Invalid research design with ID [d] detected and removed.")
			GLOB.techweb_designs -= d

/proc/calculate_techweb_nodes()
	for(var/node_id in GLOB.techweb_nodes)
		var/datum/techweb_node/node = GLOB.techweb_nodes[node_id]
		node.prerequisites = list()
		node.unlocks = list()
		node.designs = list()
		for(var/i in node.prereq_ids)
			node.prerequisites[i] = GLOB.techweb_nodes[i]
		for(var/i in node.design_ids)
			node.designs[i] = GLOB.techweb_designs[i]
		CHECK_TICK
	generate_techweb_unlock_linking()

/proc/generate_techweb_unlock_linking()
	for(var/node_id in GLOB.techweb_nodes)						//Clear all unlock links to avoid duplication.
		var/datum/techweb_node/node = GLOB.techweb_nodes[node_id]
		node.unlocks = list()
	for(var/node_id in GLOB.techweb_nodes)
		var/datum/techweb_node/node = GLOB.techweb_nodes[node_id]
		for(var/prereq_id in node.prerequisites)
			var/datum/techweb_node/prereq_node = node.prerequisites[prereq_id]
			prereq_node.unlocks += node

/proc/calculate_techweb_boost_list(clearall = FALSE)
	if(clearall)
		GLOB.techweb_boost_items = list()
	for(var/node_id in GLOB.techweb_nodes)
		var/datum/techweb_node/node = GLOB.techweb_nodes[node_id]
		for(var/path in node.boost_item_paths)
			if(!ispath(path))
				continue
			GLOB.techweb_boost_items[path] = list(node = node.boost_item_paths[path])
		CHECK_TICK
