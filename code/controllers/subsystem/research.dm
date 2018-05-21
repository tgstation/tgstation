SUBSYSTEM_DEF(research)
	name = "Research"
	priority = FIRE_PRIORITY_RESEARCH
	wait = 10
	init_order = INIT_ORDER_RESEARCH

	//Reference globally used things. This is the only place in the code where these things should be referenced, so garbage collection is actual practical without (too) ugly code.
	var/list/designs = list()					//All the design datums in the game. associative id = node datum
	var/list/nodes = list()						//All the techweb nodes in the game. associative id = node datum

	var/list/invalid_design_ids = list()		//associative id = number of times
	var/list/invalid_node_ids = list()			//associative id = number of times
	var/list/invalid_node_boost = list()		//associative id = error message
	var/list/obj/machinery/rnd/server/servers = list()
	var/list/techwebs = list()					//associative id = techweb datum
	var/datum/techweb/science/science_tech
	var/datum/techweb/admin/admin_tech
	var/list/techweb_categories = list()		//category name = list(node.id = node)
	var/list/techweb_node_ids_starting = list()	//Nodes that should be unlocked by default. associative id = TRUE
	var/list/techweb_boost_items = list()		//associative double-layer path = list(id = list(point_type = point_discount))
	var/list/techweb_node_ids_hidden = list()		//Nodes that should be hidden by default. id = TRUE
	var/list/techweb_point_items = list(		//path = list(point type = value)
	/obj/item/assembly/signaler/anomaly = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	)
	var/list/errored_datums = list()
	var/list/point_types = list()				//typecache style type = TRUE list
	//----------------------------------------------
	var/list/single_server_income = list(TECHWEB_POINT_TYPE_GENERIC = 54.3)
	var/multiserver_calculation = FALSE
	var/last_income = 0
	//^^^^^^^^ ALL OF THESE ARE PER SECOND! ^^^^^^^^

	//Aiming for 1.5 hours to max R&D
	//[88nodes * 5000points/node] / [1.5hr * 90min/hr * 60s/min]
	//Around 450000 points max???

/datum/controller/subsystem/research/Initialize()
	point_types = TECHWEB_POINT_TYPE_LIST_ASSOCIATIVE_NAMES
	initialize_all_designs()
	initialize_all_nodes()
	science_tech = new /datum/techweb/science
	admin_tech = new /datum/techweb/admin
	autosort_categories()
	return ..()

/datum/controller/subsystem/research/fire()
	handle_research_income()

/datum/controller/subsystem/research/proc/handle_research_income()
	var/list/bitcoins
	if(multiserver_calculation)
		bitcoins = list()
		var/eff = calculate_server_coefficient()
		for(var/obj/machinery/rnd/server/miner in servers)
			var/list/result = (miner.mine())	//SLAVE AWAY, SLAVE.
			for(var/i in result)
				result[i] *= eff
				bitcoins[i] = bitcoins[i]? bitcoins[i] + result[i] : result[i]
	else
		for(var/obj/machinery/rnd/server/miner in servers)
			if(miner.working)
				bitcoins = single_server_income.Copy()
				break			//Just need one to work.
	var/income_time_difference = world.time - last_income
	science_tech.last_bitcoins = bitcoins  // Doesn't take tick drift into account
	for(var/i in bitcoins)
		bitcoins[i] *= income_time_difference / 10
	science_tech.add_point_list(bitcoins)
	last_income = world.time

/datum/controller/subsystem/research/proc/calculate_server_coefficient()	//Diminishing returns.
	var/amt = servers.len
	if(!amt)
		return 0
	var/coeff = 100
	coeff = sqrt(coeff / amt)
	return coeff

/datum/controller/subsystem/research/proc/autosort_categories()
	for(var/i in nodes)
		var/datum/techweb_node/I = nodes[i]
		if(techweb_categories[I.category])
			techweb_categories[I.category][I.id] = I
		else
			techweb_categories[I.category] = list(I.id = I)

/datum/controller/subsystem/research/proc/json_export_nodes()
	return json_export_node_list(nodes)

/datum/controller/subsystem/research/proc/json_import_nodes(list/jsonlist, replacing = FALSE, refresh = TRUE)
	. = json_import_node_list(jsonlist, replacing, nodes)
	if(refresh)
		full_refresh()

/datum/controller/subsystem/research/proc/json_export_node_list(list/nodelist)
	var/list/L = list()
	for(var/id in nodelist)
		var/datum/techweb_node/D = nodelist[id]
		if(istype(D))
			L[D.id] = json_serialize_datum(D)
	return json_encode(L)

/datum/controller/subsystem/research/proc/json_import_node_list(list/jsonlist, replacing = FALSE, list/nodelist = list())
	if(!islist(jsonlist))
		if(!istext(jsonlist))
			CRASH("Invalid json")
			return
		jsonlist = json_decode(jsonlist)
	if(replacing)
		QDEL_LIST_ASSOC_VAL(nodelist)
		nodelist = list()
	var/list/assembled = list()
	for(var/id in jsonlist)
		if(jsonlist[id] == "DELETE")
			qdel(nodes[id])
			nodes -= id
			continue
		assembled[id] = json_deserialize_datum(jsonlist[id], null, /datum/techweb_node)
	for(var/id in assembled)
		if(nodelist[id])						//New overwrites old incase of conflict.
			qdel(nodelist[id])
		if(!istype(assembled[id], /datum/techweb_node))
			qdel(assembled[id])
			assembled -= id
			continue
		nodelist[id] = assembled[id]
	return assembled

/datum/controller/subsystem/research/proc/json_export_designs()
	return json_export_design_list(designs)

/datum/controller/subsystem/research/proc/json_import_designs(list/jsonlist, replacing = FALSE, refresh = TRUE)
	. = json_import_design_list(jsonlist, replacing, designs)
	if(refresh)
		full_refresh()

/datum/controller/subsystem/research/proc/json_export_design_list(list/designlist)
	var/list/L = list()
	for(var/id in designlist)
		var/datum/design/D = designlist[id]
		if(istype(D))
			L[D.id] = json_serialize_datum(D)
	return json_encode(L)

/datum/controller/subsystem/research/proc/json_import_design_list(list/jsonlist, replacing = FALSE, list/designlist = list())
	if(!islist(jsonlist))
		if(!istext(jsonlist))
			CRASH("Invalid json")
			return
		jsonlist = json_decode(jsonlist)
	if(replacing)
		QDEL_LIST_ASSOC_VAL(designlist)
		designlist = list()
	var/list/assembled = list()
	for(var/id in jsonlist)
		if(jsonlist[id] == "DELETE")
			if(designs[id])
				qdel(designs[id])
				designs -= id
				continue
		assembled[id] = json_deserialize_datum(jsonlist[id], null, /datum/design)
	for(var/id in assembled)
		to_chat(world, "DEBUG: assembled id [id]")
		if(designlist[id])						//New overwrites old incase of conflict.
			qdel(designlist[id])
		if(!istype(assembled[id], /datum/design))
			to_chat(world, "DEBUG [__LINE__] removing id [id] from assembled")
			qdel(assembled[id])
			assembled -= id
			continue
		designlist[id] = assembled[id]
	return assembled

/datum/controller/subsystem/research/proc/full_refresh()
	verify_designs()
	verify_nodes()
	calculate_nodes()
	generate_techweb_unlock_linking()
	calculate_techweb_boost_list()
	verify_nodes()						//do it again as links will be made/broken.
	for(var/i in techwebs)
		var/datum/techweb/T = techwebs[i]
		T.subsystem_resync()

/datum/controller/subsystem/research/proc/initialize_all_nodes(clearall = FALSE)
	if(islist(nodes) && clearall)
		QDEL_LIST(nodes)
	if(islist(techweb_node_ids_starting && clearall))
		QDEL_LIST(techweb_node_ids_starting)
	var/list/returned = list()
	for(var/path in subtypesof(/datum/techweb_node))
		var/datum/techweb_node/TN = path
		if(isnull(initial(TN.id)))
			continue
		TN = new path
		if(returned[initial(TN.id)])
			stack_trace("WARNING: Techweb node ID clash with ID [initial(TN.id)] detected!")
			errored_datums[TN] = initial(TN.id)
			continue
		returned[initial(TN.id)] = TN
		if(TN.starting_node)
			techweb_node_ids_starting[TN.id] = TRUE
	nodes = returned
	verify_nodes()				//Verify all nodes have ids and such.
	calculate_nodes()
	generate_techweb_unlock_linking()
	calculate_techweb_boost_list()
	verify_nodes()		//Verify nodes and designs have been crosslinked properly.

/datum/controller/subsystem/research/proc/initialize_all_designs(clearall = FALSE)
	if(islist(designs) && clearall)
		QDEL_LIST(designs)
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
			errored_datums[DN] = initial(DN.id)
			continue
		returned[initial(DN.id)] = DN
	designs = returned
	verify_designs()

/datum/controller/subsystem/research/proc/verify_nodes(log_error = TRUE)
	var/list/collision_detection = list()
	var/list/collision_needs_resolve = list()
	for(var/n in nodes)
		if(!collision_detection[n])
			collision_detection[n] = 1
		else			//Uh oh!
			collision_detection[n]++
			if(log_error)
				stack_trace("WARNING: Techweb node ID collision detected. ID: [n]. Collisions: [collision_detection[n] - 1]. ")
			collision_needs_resolve[n] = TRUE
		var/datum/techweb_node/N = nodes[n]
		if(!istype(N))
			if(log_error)
				stack_trace("WARNING: Invalid research node with ID [n] detected and removed.")
			nodes -= n
			research_node_id_error(n)
		for(var/p in N.prereq_ids)
			var/datum/techweb_node/P = get_techweb_node_by_id(p)
			if(!istype(P))
				if(log_error)
					stack_trace("WARNING: Invalid research prerequisite node with ID [p] detected in node [N.display_name]\[[N.id]\] removed.")
				N.prereq_ids  -= p
				research_node_id_error(p)
		for(var/d in N.design_ids)
			var/datum/design/D = designs[d]
			if(!istype(D))
				if(log_error)
					stack_trace("WARNING: Invalid research design with ID [d] detected in node [N.display_name]\[[N.id]\] removed.")
				N.design_ids -= d
				design_id_error(d)
		for(var/u in N.unlock_ids)
			var/datum/techweb_node/U = get_techweb_node_by_id(u)
			if(!istype(U))
				if(log_error)
					stack_trace("WARNING: Invalid research unlock node with ID [u] detected in node [N.display_name]\[[N.id]\] removed.")
				N.unlock_ids -= u
				research_node_id_error(u)
		for(var/p in N.boost_item_paths)
			if(!ispath(p))
				N.boost_item_paths -= p
				node_boost_define_error(N.id, "[p] is not a valid path.")
			var/list/points = N.boost_item_paths[p]
			if(!islist(points))
				N.boost_item_paths -= p
				node_boost_define_error(N.id, "No valid list.")
			else
				for(var/i in points)
					if(!isnum(points[i]))
						node_boost_define_error(N.id, "[points[i]] is not a valid number.")
					else if(!point_types[i])
						node_boost_define_error(N.id, "[i] is not a valid point type.")
		CHECK_TICK
	var/list/found = list()
	for(var/i in 1 to nodes.len)
		var/id = nodes[i]
		if(collision_needs_resolve[id])
			var/datum/techweb_node/D = nodes[id]
			if(istype(D) && !found[id])
				found[id] = D
				collision_needs_resolve -= id
				if(!collision_needs_resolve.len)
					break
	for(var/i in 1 to nodes.len)
		var/id = nodes[i]
		if(found[id])
			nodes -= id
	for(var/id in found)
		nodes[id] = found[id]

/datum/controller/subsystem/research/proc/verify_designs(log_error = FALSE)
	var/list/collision_detection = list()
	var/list/collision_needs_resolve = list()
	for(var/d in designs)
		if(!collision_detection[d])
			collision_detection[d] = 1
		else			//Uh oh!
			collision_detection[d]++
			if(log_error)
				stack_trace("WARNING: Design ID collision detected. ID: [d]. Collisions: [collision_detection[d] - 1]. ")
			collision_needs_resolve[d] = TRUE
		var/datum/design/D = designs[d]
		if(!istype(D))
			if(log_error)
				stack_trace("WARNING: Invalid research design with ID [d] detected and removed.")
			designs -= d
		CHECK_TICK
	var/list/found = list()
	for(var/i in 1 to designs.len)
		var/id = designs[i]
		if(collision_needs_resolve[id])
			var/datum/design/D = designs[id]
			if(istype(D) && !found[id])
				found[id] = D
				collision_needs_resolve -= id
				if(!collision_needs_resolve.len)
					break
	for(var/i in 1 to designs.len)
		var/id = designs[i]
		if(found[id])
			designs -= id
	for(var/id in found)
		nodes[id] = found[id]

/datum/controller/subsystem/research/proc/calculate_nodes()
	for(var/design_id in designs)
		var/datum/design/D = designs[design_id]
		if(!istype(D))
			stack_trace("WARNING: calculate_nodes() encountered something that isn't a techweb node in research subsystem nodes list. ID: [design_id].")
			designs -= design_id
			continue
		D.unlocking_node_ids = list()
	for(var/node_id in nodes)
		var/datum/techweb_node/node = nodes[node_id]
		if(!istype(node))
			stack_trace("WARNING: calculate_nodes() encountered something that isn't a techweb node in research subsystem nodes list. ID: [node_id].")
			nodes -= node_id
			continue
		node.unlock_ids = list()
		for(var/i in node.design_ids)
			var/datum/design/D = designs[i]
			if(!istype(D))
				stack_trace("WARNING: calculate_nodes() encountered something that isn't a techweb node in research subsystem nodes list. ID: [i].")
				node.design_ids -= i
				continue
			D.unlocking_node_ids[node.id] = TRUE
		if(node.hidden)
			techweb_node_ids_hidden[node.id] = TRUE
		CHECK_TICK

/datum/controller/subsystem/research/proc/generate_techweb_unlock_linking()
	for(var/node_id in nodes)						//Clear all unlock links to avoid duplication.
		var/datum/techweb_node/node = nodes[node_id]
		if(!istype(node))
			stack_trace("WARNING: generate_techweb_unlock_linking() encountered something that isn't a techweb node in research subsystem nodes list. ID: [node_id].")
			nodes -= node_id
			continue
		node.unlock_ids = list()
	for(var/node_id in nodes)
		var/datum/techweb_node/node = nodes[node_id]
		for(var/prereq_id in node.prereq_ids)
			var/datum/techweb_node/prereq_node = get_techweb_node_by_id(prereq_id)
			prereq_node.unlock_ids[node.id] = TRUE

/datum/controller/subsystem/research/proc/calculate_techweb_boost_list(clearall = FALSE)
	if(clearall)
		techweb_boost_items = list()
	for(var/node_id in nodes)
		var/datum/techweb_node/node = nodes[node_id]
		if(!istype(node))
			stack_trace("WARNING: calculate_techweb_boost_list() encountered something that isn't a techweb node in research subsystem nodes list. ID: [node_id].")
			nodes -= node_id
			continue
		for(var/path in node.boost_item_paths)
			if(!ispath(path))
				continue
			if(length(techweb_boost_items[path]))
				techweb_boost_items[path][node.id] = node.boost_item_paths[path]
			else
				techweb_boost_items[path] = list(node.id = node.boost_item_paths[path])
		CHECK_TICK

/datum/controller/subsystem/research/proc/research_node_id_error(id)
	if(invalid_node_ids[id])
		invalid_node_ids[id]++
	else
		invalid_node_ids[id] = 1

/datum/controller/subsystem/research/proc/design_id_error(id)
	if(invalid_design_ids[id])
		invalid_design_ids[id]++
	else
		invalid_design_ids[id] = 1

/datum/controller/subsystem/research/proc/node_boost_define_error(id, message)
	invalid_node_boost[id] = message

/datum/controller/subsystem/research/proc/load_techwebs_config(log_error = TRUE)
	var/path = "[config.directory]/[CONFIG_GET(string/techweb_config_path)]"
	if(!fexists(path))
		return
	var/list/lines = world.file2list(path)
	for(var/i in lines)
		if(!i)
			continue
		if(copytext(i, 1, 2) == "#")
			continue
		var/sep_index = findtext(i, " ")
		if(!sep_index)
			continue
		var/entry_type = copytext(i, 1, sep_index)
		var/entry_value = copytext(i, sep_index)
		if(!entry_value || !entry_type)
			continue
		var/their_path = "[config.directory]/[entry_value]"
		if(!fexists(their_path))
			if(log_error)
				stack_trace("WARNING: Techweb config entry not found: [entry_type] [entry_value]")
			continue
		switch(entry_type)
			if("MODIFICATION_FILE")
				file_amend_techwebs(their_path, FALSE)
			if("REPLACE_TECHWEB_NODES")
				file_replace_nodes(their_path, FALSE)
			if("OVERWRITE_TECHWEB_NODES")
				file_amend_nodes(their_path, FALSE)
			if("REPLACE_TECHWEB_DESIGNS")
				file_replace_designs(their_path, FALSE)
			if("OVERWRITE_TECHWEB_DESIGNS")
				file_amend_designs(their_path, FALSE)
			else
				if(log_error)
					stack_trace("WARNING: Invalid entry type found in techwebs config: [entry_type]")
	full_refresh()

/datum/controller/subsystem/research/proc/file_amend_techwebs(path, refresh = TRUE)
	var/list/entries = world.file2list(path)
	for(var/i in entries)
		if(!i)
			continue
		if(copytext(i, 1, 2) == "#")
			continue
		var/sep_index = findtext(i, " ")
		if(!sep_index)
			continue
		var/entry_type = copytext(i, 1, sep_index)
		var/entry_value = copytext(i, sep_index)
		if(!entry_value || !entry_type)
			continue
		switch(entry_type)
			if("NODE_ADD")
				var/list/L = json_decode(entry_value)
				if(L["DATUM_TYPE"])
					var/datum/techweb_node/D = json_deserialize_datum(L, null, /datum/techweb_node)
					if(D)
						nodes[D.id] = D
				else
					var/datum/techweb_node/D = new
					var/ret = D.deserialize_json(entry_value)
					if(istype(ret, /datum/techweb_node))
						nodes[D.id] = D
			if("NODE_REMOVE")
				if(nodes[entry_value])
					qdel(nodes[entry_value])
				nodes -= entry_value
			if("DESIGN_ADD")
				var/list/L = json_decode(entry_value)
				if(L["DATUM_TYPE"])
					var/datum/design/D = json_deserialize_datum(L, null, /datum/design)
					if(D)
						designs[D.id] = D
				else
					var/datum/design/D = new
					var/ret = D.deserialize_json(entry_value)
					if(istype(ret, /datum/design))
						designs[D.id] = D
			if("DESIGN_REMOVE")
				if(designs[entry_value])
					qdel(designs[entry_value])
				designs -= entry_value
	if(refresh)
		full_refresh()

/datum/controller/subsystem/research/proc/file_replace_nodes(path, refresh = TRUE)
	json_import_nodes(file2text(path), TRUE, refresh)

/datum/controller/subsystem/research/proc/file_amend_nodes(path, refresh = TRUE)
	json_import_nodes(file2text(path), FALSE, refresh)

/datum/controller/subsystem/research/proc/file_replace_designs(path, refresh = TRUE)
	json_import_designs(file2text(path), TRUE, refresh)

/datum/controller/subsystem/research/proc/file_amend_designs(path, refresh = TRUE)
	json_import_designs(file2text(path), FALSE, refresh)

/datum/controller/subsystem/research/proc/debug_test()
	json_import_designs(json_export_designs(), refresh = FALSE)
	json_import_nodes(json_export_nodes(), refresh = FALSE)
	full_refresh()

//How the configs were generated.
#ifdef TESTING
/datum/controller/subsystem/research/proc/SAVE_EXAMPLES()
	var/Npath = "[config.directory]/research/example_techweb_nodes.json"
	var/Dpath = "[config.directory]/research/example_techweb_designs.json"
	fdel(Npath)
	fdel(Dpath)
	var/file/N = file(Npath)
	var/file/D = file(Dpath)
	N << json_export_nodes()
	D << json_export_designs()
#endif
