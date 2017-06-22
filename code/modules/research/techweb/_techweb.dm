
//Techweb datums are meant to store unlocked research, being able to be stored on research consoles, servers, and disks. They are NOT global.
/datum/techweb
	var/list/datum/techweb_node/researched_nodes = list()		//Already unlocked and all designs are now available. Assoc list, id = datum
	var/list/datum/techweb_node/visible_nodes = list()			//Visible nodes, doesn't mean it can be researched. Assoc list, id = datum
	var/list/datum/techweb_node/available_nodes = list()		//Nodes that can immediately be researched, all reqs met. assoc list, id = datum
	var/list/datum/design/researched_designs = list()			//Designs that are available for use. Assoc list, id = datum
	var/list/datum/techweb_node/boosted_nodes = list()			//Already boosted nodes that can't be boosted again. node datum = path of boost object.
	var/research_points = 0										//Available research points.

/datum/techweb/New()
	for(var/i in SSresearch.techweb_nodes_starting)
		var/datum/techweb_node/DN = SSresearch.techweb_nodes_starting[i]
		research_node(DN)
	return ..()

/datum/techweb/admin
	research_points = INFINITY	//KEKKLES.

/datum/techweb/admin/New()	//All unlocked.
	. = ..()
	for(var/i in SSresearch.techweb_nodes)
		var/datum/techweb_node/TN = SSresearch.techweb_nodes[i]
		research_node(TN, TRUE)

/datum/techweb/science	//Global science techweb for RND consoles.

/datum/techweb/Destroy()
	researched_nodes = null
	researched_designs = null
	available_nodes = null
	visible_nodes = null
	return ..()

/datum/techweb/proc/recalculate_nodes(recalculate_designs = FALSE)
	var/list/datum/techweb_node/processing = list()
	for(var/i in researched_nodes)
		processing[i] = researched_nodes[i]
	for(var/i in visible_nodes)
		processing[i] = visible_nodes[i]
	for(var/i in available_nodes)
		processing[i] = available_nodes[i]
	for(var/i in processing)
		update_node_status(processing[i])
	if(recalculate_designs)					//Wipes custom added designs like from design disks or anything like that!
		researched_designs = list()
	for(var/i in processing)
		var/datum/techweb_node/TN = processing[i]
		for(var/I in TN.designs)
			researched_designs[I] = TN.designs[I]

/datum/techweb/proc/copy_research_to(datum/techweb/reciever)				//Adds any missing research to theirs.
	for(var/i in researched_nodes)
		reciever.researched_nodes[i] = researched_nodes[i]
	for(var/i in researched_designs)
		reciever.researched_designs[i] = researched_designs[i]
	reciever.recalculate_nodes()

/datum/techweb/proc/copy()
	var/datum/techweb/returned = new()
	returned.researched_nodes = researched_nodes.Copy()
	returned.visible_nodes = visible_nodes.Copy()
	returned.available_nodes = available_nodes.Copy()
	returned.researched_designs = researched_designs.Copy()

/datum/techweb/proc/add_design_by_id(id)
	return add_design(get_techweb_design_by_id(id))

/datum/techweb/proc/add_design(datum/design/design)
	if(!istype(design))
		return FALSE
	researched_designs[design.id] = design
	return TRUE

/datum/techweb/proc/remove_design_by_id(id)
	return remove_design(get_techweb_design_by_id(id))

/datum/techweb/proc/remove_design(datum/design/design)
	if(!istype(design))
		return FALSE
	researched_designs[design.id] = design
	return TRUE

/datum/techweb/proc/research_node_id(id, force = FALSE)
	return research_node(get_techweb_node_by_id(id), force)

/datum/techweb/proc/research_node(datum/techweb_node/node, force = FALSE)
	if(!istype(node))
		return FALSE
	update_node_status(node)
	if(!force)
		if(!available_nodes[node.id])
			return FALSE
	researched_nodes[node.id] = node				//Add to our researched list
	for(var/i in node.unlocks)
		visible_nodes[i] = node.unlocks[i]
		update_node_status(node.unlocks[i])
	for(var/i in node.designs)
		researched_designs[i] = node.designs[i]
	update_node_status(node)
	return TRUE

/datum/techweb/proc/unresearch_node_id(id)
	return unresearch_node(get_techweb_node_by_id(id))

/datum/techweb/proc/unresearch_node(datum/techweb_node/node)
	if(!istype(node))
		return FALSE
	researched_nodes -= node.id
	recalculate_nodes(TRUE)				//Fully rebuild the tree.

/datum/techweb/proc/update_node_status(datum/techweb_node/node)
	var/researched = FALSE
	var/available = FALSE
	var/visible = FALSE
	if(researched_nodes[node.id])
		researched = TRUE
	var/needed = node.prereq_ids.len
	for(var/i in node.prereq_ids)
		if(researched_nodes[i])
			visible = TRUE
		needed--
	if(!needed)
		available = TRUE
	if(researched)
		researched_nodes[node.id] = node
		for(var/i in node.designs)
			add_design(node.designs[i])
	else
		researched_nodes -= node.id
		if(available)
			available_nodes[node.id] = node
		else
			available_nodes -= node.id
			if(visible)
				visible_nodes[node.id] = node
			else
				visible_nodes -= node.id

//Laggy procs to do specific checks, just in case. Don't use them if you can just use the vars that already store all this!
/datum/techweb/proc/designHasReqs(datum/design/D)
	for(var/i in researched_nodes)
		var/datum/techweb_node/N = researched_nodes[i]
		for(var/I in N.designs)
			if(D == N.designs[I])
				return TRUE
	return FALSE

/datum/techweb/proc/isDesignResearched(datum/design/D)
	return isDesignResearchedID(D.id)

/datum/techweb/proc/isDesignResearchedID(id)
	return researched_designs[id]

/datum/techweb/proc/isNodeResearched(datum/techweb_node/N)
	return isNodeResearchedID(N.id)

/datum/techweb/proc/isNodeResearchedID(id)
	return researched_nodes[id]

/datum/techweb/proc/isNodeVisible(datum/techweb_node/N)
	return isNodeResearchedID(N.id)

/datum/techweb/proc/isNodeVisibleID(id)
	return visible_nodes[id]

/datum/techweb/proc/isNodeAvailable(datum/techweb_node/N)
	return isNodeAvailableID(N.id)

/datum/techweb/proc/isNodeAvailableID(id)
	return available_nodes[id]

/datum/techweb/autolathe/New()
	. = ..()
	for(var/D in SSresearch.techweb_designs)
		var/datum/design/d = SSresearch.techweb_designs[D]
		if((d.build_type & AUTOLATHE) && ("initial" in d.category))
			add_design(d)

/datum/techweb/autolathe/add_design(datum/design/D)
	if(!(D.build_type & AUTOLATHE))
		return FALSE
	return ..()

/datum/techweb/limbgrower/New()
	. = ..()
	for(var/D in SSresearch.techweb_designs)
		var/datum/design/d = SSresearch.techweb_designs[D]
		if((d.build_type & LIMBGROWER) && ("initial" in d.category))
			add_design(d)

/datum/techweb/limbgrower/add_design(datum/design/D)
	if(!(D.build_type & LIMBGROWER))
		return FALSE
	return TRUE

/datum/techweb/biogenerator/New()
	. = ..()
	for(var/D in SSresearch.techweb_designs)
		var/datum/design/d = SSresearch.techweb_designs[D]
		if((d.build_type & BIOGENERATOR) && ("initial" in d.category))
			add_design(d)

/datum/techweb/biogenerator/add_design(datum/design/D)
	if(!(D.build_type & BIOGENERATOR))
		return FALSE
	return ..()

/datum/techweb/smelter/New()
	for(var/D in SSresearch.techweb_designs)
		var/datum/design/d = SSresearch.techweb_designs[D]
		if((d.build_type & SMELTER) && ("initial" in d.category))
			add_design(d)

/datum/techweb/smelter/add_design(datum/design/D)
	if(!(D.build_type & SMELTER))
		return FALSE
	return ..()
