
/proc/calculate_techweb_nodes()
	for(var/node_id in GLOB.techweb_nodes)
		var/datum/techweb_node/node = GLOB.techweb_nodes[node_id]
		node.prerequisites = list()
		node.unlocks = list()
		node.designs = list()
		for(var/i in node.prereq_ids)
			node.prerequisites += GLOB.techweb_nodes[i]
		for(var/i in node.design_ids)
			node.designs += GLOB.techweb_designs[i]
		CHECK_TICK
	generate_techweb_unlock_linking()

/proc/generate_techweb_unlock_linking()
	for(var/node_id in GLOB.techweb_nodes)
		var/datum/techweb_node/node = GLOB.techweb_nodes[node_id]
		for(var/prereq_id in node.prerequisites)
			var/datum/techweb_node/prereq_node = node.prerequisites[prereq_id]
			prereq_node.unlocks += node

/proc/calculate_techweb_boost_list()
	for(var/node_id in GLOB.techweb_nodes)
		var/datum/techweb_node/node = GLOB.techweb_nodes[node_id]
		for(var/path in node.boost_item_paths)
			if(!ispath(path))
				continue
			GLOB.techweb_boost_items[path] = list(node = node.boost_item_paths[path])
		CHECK_TICK

//Techweb nodes are GLOBAL, there should only be one instance of them in the game. Persistant changes should never be made to them in-game.

/datum/techweb_node
	var/id
	var/display_name = "Errored Node"
	var/description = "Why are you seeing this?"
	var/starting_node = FALSE	//Whether it's available without any research.
	var/list/prereq_ids = list()
	var/list/design_ids = list()
	var/list/datum/techweb_node/prerequisites = list()
	var/list/datum/techweb_node/unlocks = list()			//CALCULATED FROM OTHER NODE'S PREREQUISITES
	var/list/datum/design/designs = list()
	var/list/boost_item_paths = list()		//Associative list, path = point_value.
	var/export_price = 0					//Cargo export price.









