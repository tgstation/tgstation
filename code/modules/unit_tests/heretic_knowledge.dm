
/*
 * This test checks all heretic knowledge nodes and validates they are setup correctly.
 * We check that all knowledge is reachable by players (through the research tree)
 * and that all knowledge have a valid next_knowledge list.
 */
/datum/unit_test/heretic_knowledge

/datum/unit_test/heretic_knowledge/Run()
	GLOB.heretic_path_knowledges = generate_global_heretic_tree()


	var/list/start_knowledges = list()
	generate_heretic_starting_knowledge(start_knowledges)
	start_knowledges = flatten_list(start_knowledges)
	var/list/all_knowledges = start_knowledges

	// we need to generate a set of shop_knowledges and drafted knowledges as they're unique per path and slightly random in drafted knowledges
	for(var/path in GLOB.heretic_path_knowledges)
		var/list/tree = GLOB.heretic_path_knowledges[path]
		var/list/shop = list()
		var/list/draft = list()
		determine_drafted_knowledge(path, tree, shop, draft)
		all_knowledges += flatten_list(tree)
		all_knowledges += flatten_list(shop)
		all_knowledges += flatten_list(draft)


	var/list/all_possible_knowledge = typesof(/datum/heretic_knowledge)

	for(var/datum/heretic_knowledge/knowledge_type as anything in all_possible_knowledge)
		if(initial(knowledge_type.abstract_parent_type) == knowledge_type)
			all_possible_knowledge -= knowledge_type

	var/list/list_to_check = get_knowledge_unlockables(start_knowledges, all_knowledges)

	// We now have a list that SHOULD contain all knowledges with a path set (list_to_check).
	// Let's compare it to our original list (all_possible_knowledge). If they're not identical,
	// then somewhere we missed a knowledge somewhere, and should throw a fail.
	var/list/unreachables = list()
	for(var/knowledge_path in all_possible_knowledge)
		var/found = FALSE
		for(var/list/knowledge_node as anything in list_to_check)
			var/type = knowledge_node["type"]
			if(type == knowledge_path)
				found = TRUE
				break
		if(!found)
			unreachables += knowledge_path
	// Unreachables is a list of typepaths - all paths that cannot be obtained.
	for(var/datum/heretic_knowledge/lost_knowledge as anything in unreachables)
		TEST_FAIL("Heretic Knowledge: [lost_knowledge] is unreachable by players! Add it to another knowledge's 'next_knowledge' list. If it is purposeful, set its route to 'null'.")

/// Expects a flat list of knowledge nodes. Returns a list of all HKT_ID entries
/datum/unit_test/heretic_knowledge/proc/get_knowledge_ids(list/knowledges)
	var/list/ids = list()
	for(var/list/knowledge_node as anything in knowledges)
		ids += knowledge_node[HKT_ID]
	return ids

/// Gets all unique HKT_NEXT entries from a list of knowledges. both lists must be flat lists of knowledge nodes
/datum/unit_test/heretic_knowledge/proc/get_knowledge_unlockables(list/starting_point, list/all_knowledges)
	// Now, let's build a list of all researchable knowledge
	// from the ground up. We start with all starting knowledge,
	// then add the next possible knowledges back into the list
	// repeatedly, until we run out of knowledges to add.
	var/list/list_to_check = starting_point.Copy()
	var/i = 0
	while(i < length(list_to_check))
		var/list/knowledge_node = list_to_check[++i]
		// Next knowledge is a list of id that consists of typepath_shopcategory
		// we basically need to go through the entire chain of HKT_NEXT's to validate the paths's starting from GLOB.heretic_start_knowledge
		for(var/next_id in knowledge_node[HKT_NEXT])
			var/list/next_knowledge_node = find_knowledge_node_by_id(all_knowledges, next_id)
			var/datum/knowledge_path = next_knowledge_node["type"]
			if(isnull(next_knowledge_node))
				TEST_FAIL("Heretic Knowledge: [next_id] in [knowledge_path] 's next_knowledge list does not point to a valid knowledge node!")
				continue
			if(!istext(next_id))
				TEST_FAIL("Heretic Knowledge: [next_id] has an invalid non-string next_knowledge entry (Got: [next_id])!")
			list_to_check += list(next_knowledge_node)
	return list_to_check

/datum/unit_test/heretic_knowledge/proc/find_knowledge_node_by_id(list/knowledges, id)
	for(var/list/knowledge_node as anything in knowledges)
		if(knowledge_node[HKT_ID] == id)
			return knowledge_node
	return null

/datum/unit_test/heretic_knowledge/proc/flatten_list(list/knowledge_nodes)
	var/list/flat_list = list()
	for(var/datum/heretic_knowledge/knowledge_path as anything in knowledge_nodes)
		var/list/knowledge_node = knowledge_nodes[knowledge_path]
		knowledge_node["type"] = knowledge_path
		flat_list += list(knowledge_node)
	return flat_list
