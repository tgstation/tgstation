
//Used \n[\s]*origin_tech[\s]*=[\s]*"[\S]+" to delete all origin techs.
//Or \n[\s]*origin_tech[\s]*=[\s]list\([A-Z_\s=0-9,]*\)
//Used \n[\s]*req_tech[\s]*=[\s]*list\(["a-z\s=0-9,]*\) to delete all req_techs.

//Techweb datums are meant to store unlocked research, being able to be stored on research consoles, servers, and disks. They are NOT global.
/datum/techweb
	var/list/researched_node_ids = list()		//Already unlocked and all designs are now available. Assoc list, id = TRUE
	var/list/visible_node_ids = list()			//Visible nodes, doesn't mean it can be researched. Assoc list, id = TRUE
	var/list/available_node_ids = list()		//Nodes that can immediately be researched, all reqs met. assoc list, id = TRUE
	var/list/researched_design_ids = list()			//Designs that are available for use. Assoc list, id = TRUE
	var/list/boosted_node_ids = list()			//Already boosted nodes that can't be boosted again. node id = path of boost object.
	var/list/hidden_node_ids = list()			//Hidden nodes. id = TRUE. Used for unhiding nodes when requirements are met by removing the entry of the node.
	var/list/deconstructed_items = list()						//items already deconstructed for a generic point boost. path = list(point_type = points)
	var/list/research_points = list()										//Available research points. type = number
	var/list/custom_design_ids	= list()		//id = TRUE
	var/list/obj/machinery/computer/rdconsole/consoles_accessing = list()
	var/id = "generic"
	var/base_node_id = "base"
	var/list/research_logs = list()								//IC logs.
	var/max_bomb_value = 0
	var/organization = "Third-Party"							//Organization name, used for display.
	var/list/last_bitcoins = list()								//Current per-second production, used for display only.
	var/list/tiers = list()										//Assoc list, datum = number, 1 is available, 2 is all reqs are 1, so on
	var/tech_tree_node_height = 0
	var/tech_tree_node_width = 0

/datum/techweb/New(new_id)
	var/static/next_id = 1
	if(!isnull(new_id))
		id = new_id
	if(id == "generic" || !istext(id) || !id)
		id = "generic_techweb_[next_id++]"
	if(SSresearch.techwebs[id])
		qdel(SSresearch.techwebs[id])
	SSresearch.techwebs[id] = src
	subsystem_resync()
	return ..()

/datum/techweb/serialize_list(list/options)
	var/list/jsonlist = list()
	if(islist(researched_node_ids))
		jsonlist["researched_node_ids"] = researched_node_ids
	if(islist(available_node_ids))
		jsonlist["available_node_ids"] = available_node_ids
	if(islist(visible_node_ids))
		jsonlist["visible_node_ids"] = visible_node_ids
	if(islist(researched_design_ids))
		jsonlist["researched_design_ids"] = researched_design_ids
	if(islist(boosted_node_ids))
		jsonlist["boosted_node_ids"] = boosted_node_ids
	if(islist(hidden_node_ids))
		jsonlist["hidden_node_ids"] = hidden_node_ids
	if(islist(deconstructed_items))
		jsonlist["deconstructed_items"] = deconstructed_items
	if(islist(research_points))
		jsonlist["research_points"] = research_points
	if(istext(id))
		jsonlist["id"] = id
	if(islist(research_logs))
		jsonlist["research_logs"] = research_logs
	if(isnum(max_bomb_value))
		jsonlist["max_bomb_value"] = max_bomb_value
	if(istext(organization))
		jsonlist["organization"] = organization
	return jsonlist

/datum/techweb/deserialize_list(jsonlist, list/options)
	if(!islist(jsonlist))
		if(!istext(jsonlist))
			CRASH("Invalid JSON")
			return
		jsonlist = json_decode(jsonlist)
		if(!islist(jsonlist))
			CRASH("Invalid JSON")
			return
	if(islist(jsonlist["researched_node_ids"]))
		researched_node_ids = jsonlist["researched_node_ids"]
	if(islist(jsonlist["available_node_ids"]))
		available_node_ids = jsonlist["available_node_ids"]
	if(islist(jsonlist["visible_node_ids"]))
		visible_node_ids = jsonlist["visible_node_ids"]
	if(islist(jsonlist["researched_design_ids"]))
		researched_design_ids = jsonlist["researched_design_ids"]
	if(islist(jsonlist["boosted_node_ids"]))
		boosted_node_ids = jsonlist["boosted_node_ids"]
	if(islist(jsonlist["hidden_node_ids"]))
		hidden_node_ids = jsonlist["hidden_node_ids"]
	if(islist(jsonlist["deconstructed_items"]))
		deconstructed_items = jsonlist["deconstructed_items"]
	if(islist(jsonlist["research_points"]))
		research_points = jsonlist["research_points"]
	if(istext(jsonlist["id"]))
		id = jsonlist["id"]
	if(islist(jsonlist["research_logs"]))
		research_logs = jsonlist["research_logs"]
	if(isnum(jsonlist["max_bomb_value"]))
		max_bomb_value = jsonlist["max_bomb_value"]
	if(istext(jsonlist["organization"]))
		organization = jsonlist["organization"]
	return src

/datum/techweb/proc/prune(resync = TRUE)			//get rid of invalid nodes and designs
	for(var/id in researched_node_ids)
		if(!get_techweb_node_by_id(id))
			researched_node_ids -= id
	for(var/id in visible_node_ids)
		if(!get_techweb_node_by_id(id))
			visible_node_ids -= id
	for(var/id in available_node_ids)
		if(!get_techweb_node_by_id(id))
			available_node_ids -= id
	for(var/id in researched_design_ids)
		if(!get_techweb_design_by_id(id))
			researched_design_ids -= id
	for(var/id in boosted_node_ids)
		if(!get_techweb_node_by_id(id))
			boosted_node_ids -= id
	for(var/id in hidden_node_ids)
		if(!get_techweb_node_by_id(id))
			hidden_node_ids -= id
	if(resync)
		subsystem_resync()

/datum/techweb/proc/calculate_tree_graphic_params()
	techweb_tree_node_width = 0
	techweb_tree_node_height = 0
	if(!get_techweb_node_by_id(base_node_id))
		return
	var/datum/techweb_node/node = techweb_node_by_id(base_node_id)
	var/list/processing = list()
	while(processing.len)



/datum/techweb/proc/subsystem_resync()
	prune(FALSE)
	for(var/id in SSresearch.techweb_node_ids_starting)
		var/datum/techweb_node/DN = get_techweb_node_by_id(id)
		research_node(DN, TRUE, FALSE)
	hidden_node_ids = SSresearch.techweb_node_ids_hidden - available_node_ids

/datum/techweb/proc/recalculate_nodes(recalculate_designs = FALSE, preserve_custom_designs = TRUE)
	var/list/datum/techweb_node/processing = list()
	for(var/i in researched_node_ids)
		processing[i] = researched_node_ids[i]
	for(var/i in visible_node_ids)
		processing[i] = visible_node_ids[i]
	for(var/i in available_node_ids)
		processing[i] = available_node_ids[i]
	if(recalculate_designs)					//Wipes custom added designs like from design disks or anything like that!
		researched_design_ids = preserve_custom_designs? custom_design_ids.Copy() : list()
	for(var/i in processing)
		update_node_status(get_techweb_node_by_id(i), FALSE)
	update_consoles()

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

/datum/techweb/proc/copy_research_to(datum/techweb/reciever, unlock_hidden = TRUE)				//Adds any missing research to theirs.
	for(var/i in researched_node_ids)
		CHECK_TICK
		reciever.research_node_id(i, TRUE, FALSE)
	for(var/i in researched_design_ids)
		CHECK_TICK
		reciever.add_design_by_id(i)
	if(unlock_hidden)
		for(var/i in reciever.hidden_node_ids)
			CHECK_TICK
			if(!hidden_node_ids[i])
				reciever.hidden_node_ids -= i		//We can see it so let them see it too.
	reciever.recalculate_nodes()

/datum/techweb/proc/copy()
	var/datum/techweb/returned = new()
	returned.researched_node_ids = researched_node_ids.Copy()
	returned.visible_node_ids = visible_node_ids.Copy()
	returned.available_node_ids = available_node_ids.Copy()
	returned.researched_design_ids = researched_design_ids.Copy()
	returned.hidden_node_ids = hidden_node_ids.Copy()
	return returned

/datum/techweb/proc/get_visible_node_ids()			//The way this is set up is shit but whatever.
	return visible_node_ids - hidden_node_ids

/datum/techweb/proc/get_available_node_ids()
	return available_node_ids - hidden_node_ids

/datum/techweb/proc/get_researched_node_ids()
	return researched_node_ids - hidden_node_ids

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

/datum/techweb/proc/add_design_by_id(id, custom = FALSE)
	return add_design(get_techweb_design_by_id(id), custom)

/datum/techweb/proc/add_design(datum/design/design, custom = FALSE)
	if(!istype(design))
		return FALSE
	researched_design_ids[design.id] = TRUE
	if(custom)
		custom_design_ids[design.id] = TRUE
	return TRUE

/datum/techweb/proc/remove_design_by_id(id)
	return remove_design(get_techweb_design_by_id(id))

/datum/techweb/proc/remove_design(datum/design/design)
	if(!istype(design))
		return FALSE
	researched_design_ids -= design.id
	custom_design_ids -= design.id
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
		if(!available_node_ids[node.id] || (auto_adjust_cost && (!can_afford(node.get_price(src)))))
			return FALSE
	if(auto_adjust_cost)
		remove_point_list(node.get_price(src))
	researched_node_ids[node.id] = TRUE				//Add to our researched list
	for(var/i in node.unlock_ids)
		visible_node_ids[i] = TRUE
		update_node_status(get_techweb_node_by_id(i))
	for(var/i in node.design_ids)
		add_design_by_id(i)
	update_node_status(node)
	return TRUE

/datum/techweb/proc/unresearch_node_id(id)
	return unresearch_node(get_techweb_node_by_id(id))

/datum/techweb/proc/unresearch_node(datum/techweb_node/node)
	if(!istype(node))
		return FALSE
	researched_node_ids -= node.id
	recalculate_nodes(TRUE)				//Fully rebuild the tree.

/datum/techweb/proc/boost_with_path(datum/techweb_node/N, itempath)
	if(!istype(N) || !ispath(itempath))
		return FALSE
	LAZYINITLIST(boosted_node_ids[N])
	for(var/i in N.boost_item_paths[itempath])
		boosted_node_ids[N.id][i] = max(boosted_node_ids[N.id][i], N.boost_item_paths[itempath][i])
	if(N.autounlock_by_boost)
		hidden_node_ids -= N.id
	update_node_status(N)
	return TRUE

/datum/techweb/proc/update_tiers(datum/techweb_node/base)
	var/list/current = list(base)
	max_tier = 0
	while (current.len)
		var/list/next = list()
		for (var/node_ in current)
			var/datum/techweb_node/node = node_
			var/tier = 0
			if(!researched_node_ids[node.id])  // researched is tier 0
				for (var/id in node.prereq_ids)
					var/prereq_tier = tiers[get_techweb_node_by_id(id)]
					tier = max(tier, prereq_tier + 1)

			if(tier != tiers[node])
				tiers[node] = tier
				for (var/id in node.unlock_ids)
					next += get_techweb_node_by_id(id)
		current = next

/datum/techweb/proc/update_node_status(datum/techweb_node/node, autoupdate_consoles = TRUE)
	var/researched = FALSE
	var/available = FALSE
	var/visible = FALSE
	if(researched_node_ids[node.id])
		researched = TRUE
	var/needed = node.prereq_ids.len
	for(var/i in node.prereq_ids)
		if(researched_node_ids[i])
			visible = TRUE
			needed--
	if(!needed)
		available = TRUE
	researched_node_ids -= node.id
	available_node_ids -= node.id
	visible_node_ids -= node.id
	if(hidden_node_ids[node.id])	//Hidden.
		return
	if(researched)
		researched_node_ids[node.id] = TRUE
		for(var/i in node.design_ids)
			add_design(get_techweb_design_by_id(i))
	else
		if(available)
			available_node_ids[node.id] = TRUE
		else
			if(visible)
				visible_node_ids[node.id] = TRUE
	update_tiers(node)
	if(autoupdate_consoles)
		update_consoles()

/datum/techweb/proc/update_consoles()
	for(var/v in consoles_accessing)
		var/obj/machinery/computer/rdconsole/V = v
		V.rescan_views()
		V.updateUsrDialog()

//Laggy procs to do specific checks, just in case. Don't use them if you can just use the vars that already store all this!
/datum/techweb/proc/designHasReqs(datum/design/D)
	for(var/i in researched_node_ids)
		var/datum/techweb_node/N = get_techweb_node_by_id(i)
		if(N.design_ids[D.id])
			return TRUE
	return FALSE

/datum/techweb/proc/is_design_researched(datum/design/D)
	return is_design_researched_id(D.id)

/datum/techweb/proc/is_design_researched_id(id)
	return researched_design_ids[id]? get_techweb_design_by_id(id) : FALSE

/datum/techweb/proc/is_node_researched(datum/techweb_node/N)
	return is_node_researched_id(N.id)

/datum/techweb/proc/is_node_researched_id(id)
	return researched_node_ids[id]

/datum/techweb/proc/is_node_visible(datum/techweb_node/N)
	return is_node_researched_id(N.id)

/datum/techweb/proc/is_node_visible_id(id)
	return visible_node_ids[id]

/datum/techweb/proc/is_node_available(datum/techweb_node/N)
	return is_node_available_id(N.id)

/datum/techweb/proc/is_node_available_id(id)
	return available_node_ids[id]

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
	for(var/id in SSresearch.designs)
		var/datum/design/D = SSresearch.designs[id]
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

/datum/techweb/admin
	id = "ADMIN"
	organization = "CentCom"

/datum/techweb/admin/subsystem_resync()
	. = ..()
	for(var/i in SSresearch.nodes)
		var/datum/techweb_node/TN = SSresearch.nodes[i]
		research_node(TN, TRUE)
	for(var/i in SSresearch.point_types)
		research_points[i] = INFINITY
	for(var/i in SSresearch.designs)
		add_design_by_id(i)
	hidden_node_ids = list()

/datum/techweb/science	//Global science techweb for RND consoles.
	id = "SCIENCE"
	organization = "Nanotrasen"

/datum/techweb/Destroy()
	researched_node_ids = null
	researched_design_ids = null
	available_node_ids = null
	visible_node_ids = null
	return ..()
