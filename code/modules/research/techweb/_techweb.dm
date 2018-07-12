
//Used \n[\s]*origin_tech[\s]*=[\s]*"[\S]+" to delete all origin techs.
//Or \n[\s]*origin_tech[\s]*=[\s]list\([A-Z_\s=0-9,]*\)
//Used \n[\s]*req_tech[\s]*=[\s]*list\(["a-z\s=0-9,]*\) to delete all req_techs.

//Techweb datums are meant to store unlocked research, being able to be stored on research consoles, servers, and disks. They are NOT global.
/datum/techweb
	var/list/datum/techweb_node/researched_nodes = list()		//Already unlocked and all designs are now available. Assoc list, id = datum
	var/list/datum/techweb_node/visible_nodes = list()			//Visible nodes, doesn't mean it can be researched. Assoc list, id = datum
	var/list/datum/techweb_node/available_nodes = list()		//Nodes that can immediately be researched, all reqs met. assoc list, id = datum
	var/list/datum/design/researched_designs = list()			//Designs that are available for use. Assoc list, id = datum
	var/list/datum/techweb_node/boosted_nodes = list()			//Already boosted nodes that can't be boosted again. node datum = path of boost object.
	var/list/datum/techweb_node/hidden_nodes = list()			//Hidden nodes. id = datum. Used for unhiding nodes when requirements are met by removing the entry of the node.
	var/list/deconstructed_items = list()						//items already deconstructed for a generic point boost. path = list(point_type = points)
	var/list/research_points = list()										//Available research points. type = number
	var/list/obj/machinery/computer/rdconsole/consoles_accessing = list()
	var/id = "generic"
	var/list/research_logs = list()								//IC logs.
	var/max_bomb_value = 0
	var/organization = "Third-Party"							//Organization name, used for display.
	var/list/last_bitcoins = list()								//Current per-second production, used for display only.
	var/list/tiers = list()										//Assoc list, datum = number, 1 is available, 2 is all reqs are 1, so on

/datum/techweb/New()
	for(var/i in SSresearch.techweb_nodes_starting)
		var/datum/techweb_node/DN = SSresearch.techweb_nodes_starting[i]
		research_node(DN, TRUE, FALSE)
	hidden_nodes = SSresearch.techweb_nodes_hidden
	return ..()

/datum/techweb/admin
	id = "ADMIN"
	organization = "CentCom"

/datum/techweb/admin/New()	//All unlocked.
	. = ..()
	for(var/i in SSresearch.techweb_nodes)
		var/datum/techweb_node/TN = SSresearch.techweb_nodes[i]
		research_node(TN, TRUE)
	for(var/i in SSresearch.point_types)
		research_points[i] = INFINITY
	hidden_nodes = list()

/datum/techweb/science	//Global science techweb for RND consoles.
	id = "SCIENCE"
	organization = "Nanotrasen"

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
		update_node_status(TN, FALSE)
		CHECK_TICK
	for(var/v in consoles_accessing)
		var/obj/machinery/computer/rdconsole/V = v
		V.rescan_views()
		V.updateUsrDialog()

/datum/techweb/proc/add_point_list(list/pointlist)
	for(var/i in pointlist)
		if(SSresearch.point_types[i] && pointlist[i] > 0)
			research_points[i] += pointlist[i]

/datum/techweb/proc/add_points_all(amount)
	var/list/l = SSresearch.point_types.Copy()
	for(var/i in l)
		l[i] = amount
	add_point_list(l)

/datum/techweb/proc/remove_point_list(list/pointlist)
	for(var/i in pointlist)
		if(SSresearch.point_types[i] && pointlist[i] > 0)
			research_points[i] = max(0, research_points[i] - pointlist[i])

/datum/techweb/proc/remove_points_all(amount)
	var/list/l = SSresearch.point_types.Copy()
	for(var/i in l)
		l[i] = amount
	remove_point_list(l)

/datum/techweb/proc/modify_point_list(list/pointlist)
	for(var/i in pointlist)
		if(SSresearch.point_types[i] && pointlist[i] != 0)
			research_points[i] = max(0, research_points[i] + pointlist[i])

/datum/techweb/proc/modify_points_all(amount)
	var/list/l = SSresearch.point_types.Copy()
	for(var/i in l)
		l[i] = amount
	modify_point_list(l)

/datum/techweb/proc/copy_research_to(datum/techweb/receiver, unlock_hidden = TRUE)				//Adds any missing research to theirs.
	for(var/i in researched_nodes)
		CHECK_TICK
		receiver.research_node_id(i, TRUE, FALSE)
	for(var/i in researched_designs)
		CHECK_TICK
		receiver.add_design_by_id(i)
	if(unlock_hidden)
		for(var/i in receiver.hidden_nodes)
			CHECK_TICK
			if(!hidden_nodes[i])
				receiver.hidden_nodes -= i		//We can see it so let them see it too.
	receiver.recalculate_nodes()

/datum/techweb/proc/copy()
	var/datum/techweb/returned = new()
	returned.researched_nodes = researched_nodes.Copy()
	returned.visible_nodes = visible_nodes.Copy()
	returned.available_nodes = available_nodes.Copy()
	returned.researched_designs = researched_designs.Copy()
	returned.hidden_nodes = hidden_nodes.Copy()
	return returned

/datum/techweb/proc/get_visible_nodes()			//The way this is set up is shit but whatever.
	return visible_nodes - hidden_nodes

/datum/techweb/proc/get_available_nodes()
	return available_nodes - hidden_nodes

/datum/techweb/proc/get_researched_nodes()
	return researched_nodes - hidden_nodes

/datum/techweb/proc/add_point_type(type, amount)
	if(!SSresearch.point_types[type] || (amount <= 0))
		return FALSE
	research_points[type] += amount
	return TRUE

/datum/techweb/proc/modify_point_type(type, amount)
	if(!SSresearch.point_types[type])
		return FALSE
	research_points[type] = max(0, research_points[type] + amount)
	return TRUE

/datum/techweb/proc/remove_point_type(type, amount)
	if(!SSresearch.point_types[type] || (amount <= 0))
		return FALSE
	research_points[type] = max(0, research_points[type] - amount)
	return TRUE

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
	researched_designs -= design.id
	return TRUE

/datum/techweb/proc/can_afford(list/pointlist)
	for(var/i in pointlist)
		if(research_points[i] < pointlist[i])
			return FALSE
	return TRUE

/datum/techweb/proc/printout_points()
	return techweb_point_display_generic(research_points)

/datum/techweb/proc/research_node_id(id, force, auto_update_points)
	return research_node(get_techweb_node_by_id(id), force, auto_update_points)

/datum/techweb/proc/research_node(datum/techweb_node/node, force = FALSE, auto_adjust_cost = TRUE)
	if(!istype(node))
		return FALSE
	update_node_status(node)
	if(!force)
		if(!available_nodes[node.id] || (auto_adjust_cost && (!can_afford(node.get_price(src)))))
			return FALSE
	if(auto_adjust_cost)
		remove_point_list(node.get_price(src))
	researched_nodes[node.id] = node				//Add to our researched list
	for(var/i in node.unlocks)
		visible_nodes[i] = node.unlocks[i]
		update_node_status(node.unlocks[i])
	for(var/i in node.designs)
		add_design(node.designs[i])
	update_node_status(node)
	return TRUE

/datum/techweb/proc/unresearch_node_id(id)
	return unresearch_node(get_techweb_node_by_id(id))

/datum/techweb/proc/unresearch_node(datum/techweb_node/node)
	if(!istype(node))
		return FALSE
	researched_nodes -= node.id
	recalculate_nodes(TRUE)				//Fully rebuild the tree.

/datum/techweb/proc/boost_with_path(datum/techweb_node/N, itempath)
	if(!istype(N) || !ispath(itempath))
		return FALSE
	LAZYINITLIST(boosted_nodes[N])
	for(var/i in N.boost_item_paths[itempath])
		boosted_nodes[N][i] = max(boosted_nodes[N][i], N.boost_item_paths[itempath][i])
	if(N.autounlock_by_boost)
		hidden_nodes -= N.id
	update_node_status(N)
	return TRUE

/datum/techweb/proc/update_tiers(datum/techweb_node/base)
	var/list/current = list(base)
	while (current.len)
		var/list/next = list()
		for (var/node_ in current)
			var/datum/techweb_node/node = node_
			var/tier = 0
			if (!researched_nodes[node.id])  // researched is tier 0
				for (var/id in node.prereq_ids)
					var/prereq_tier = tiers[node.prerequisites[id]]
					tier = max(tier, prereq_tier + 1)

			if (tier != tiers[node])
				tiers[node] = tier
				for (var/id in node.unlocks)
					next += node.unlocks[id]
		current = next

/datum/techweb/proc/update_node_status(datum/techweb_node/node, autoupdate_consoles = TRUE)
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
	researched_nodes -= node.id
	available_nodes -= node.id
	visible_nodes -= node.id
	if(hidden_nodes[node.id])	//Hidden.
		return
	if(researched)
		researched_nodes[node.id] = node
		for(var/i in node.designs)
			add_design(node.designs[i])
	else
		if(available)
			available_nodes[node.id] = node
		else
			if(visible)
				visible_nodes[node.id] = node
	update_tiers(node)
	if(autoupdate_consoles)
		for(var/v in consoles_accessing)
			var/obj/machinery/computer/rdconsole/V = v
			V.rescan_views()
			V.updateUsrDialog()

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

/datum/techweb/specialized
	var/allowed_buildtypes = ALL

/datum/techweb/specialized/add_design(datum/design/D)
	if(!(D.build_type & allowed_buildtypes))
		return FALSE
	return ..()

/datum/techweb/specialized/autounlocking
	var/design_autounlock_buildtypes = NONE
	var/design_autounlock_categories = list("initial")		//if a design has a buildtype that matches the abovea and either has a category in this or this is null, unlock it.
	var/node_autounlock_ids = list()				//autounlock nodes of this type.

/datum/techweb/specialized/autounlocking/New()
	..()
	autounlock()

/datum/techweb/specialized/autounlocking/proc/autounlock()
	for(var/id in node_autounlock_ids)
		research_node_id(id, TRUE, FALSE)
	for(var/id in SSresearch.techweb_designs)
		var/datum/design/D = SSresearch.techweb_designs[id]
		if(D.build_type & design_autounlock_buildtypes)
			for(var/i in D.category)
				if(i in design_autounlock_categories)
					add_design(D)
					break

/datum/techweb/specialized/autounlocking/autolathe
	design_autounlock_buildtypes = AUTOLATHE
	allowed_buildtypes = AUTOLATHE

/datum/techweb/specialized/autounlocking/limbgrower
	design_autounlock_buildtypes = LIMBGROWER
	allowed_buildtypes = LIMBGROWER

/datum/techweb/specialized/autounlocking/biogenerator
	design_autounlock_buildtypes = BIOGENERATOR
	allowed_buildtypes = BIOGENERATOR

/datum/techweb/specialized/autounlocking/smelter
	design_autounlock_buildtypes = SMELTER
	allowed_buildtypes = SMELTER

/datum/techweb/specialized/autounlocking/exofab
	node_autounlock_ids = list("robotics", "mmi", "cyborg", "mecha_odysseus", "mech_gygax", "mech_durand", "mecha_phazon", "mecha", "mech_tools", "clown")
	allowed_buildtypes = MECHFAB
