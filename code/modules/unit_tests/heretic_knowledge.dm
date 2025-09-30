

// /*
//  * This test checks all heretic knowledge nodes and validates they are setup correctly.
//  * We check that all knowledge is reachable by players (through the research tree)
//  * and that all knowledge have a valid next_knowledge list.
//  */
/datum/unit_test/heretic_knowledge

/datum/unit_test/heretic_knowledge/Run()
	if(!GLOB.heretic_paths)
		GLOB.heretic_paths = generate_global_heretic_tree()
	// First, we get a list of all knowledge types
	// EXCLUDING all abstract types
	var/list/all_possible_knowledge = typesof(/datum/heretic_knowledge)
	var/list/all_possible_ids = list()

	var/list/shop_categories = list(
		HERETIC_KNOWLEDGE_START,
		HERETIC_KNOWLEDGE_TREE,
		HERETIC_KNOWLEDGE_SHOP,
		HERETIC_KNOWLEDGE_DRAFT,
	)

	for(var/datum/heretic_knowledge/knowledge_type as anything in all_possible_knowledge)
		if(initial(knowledge_type.abstract_parent_type) == knowledge_type)
			all_possible_knowledge -= knowledge_type

		for(var/category in shop_categories)
			var/new_id = make_knowledge_id(knowledge_type, category)
			if(new_id in all_possible_ids)
				TEST_FAIL("Heretic Knowledge: Duplicate knowledge ID [new_id] found for [knowledge_type] in category [category]! ID's are created by combining the typepath and category, something fucked up!")
			all_possible_ids |= new_id

	// Now, let's build a list of all researchable knowledge
	// from the ground up. We start with all starting knowledge,
	// then add the next possible knowledges back into the list
	// repeatedly, until we run out of knowledges to add.
	var/list/list_to_check = GLOB.heretic_start_knowledge.Copy()

	for(var/route in GLOB.heretic_paths)
		var/knowledge_tree = GLOB.heretic_paths[route]
		for(var/datum/heretic_knowledge/knowledge_path as anything in route)
			if(!ispath(knowledge_path))
				TEST_FAIL("Heretic Knowledge: Got a non-heretic knowledge datum (Got: [knowledge_path]) in the list knowledges!")
			var/list/knowledge_data = knowledge_tree[knowledge_path]
			if(isnull(knowledge_data) || !islist(knowledge_data))
				TEST_FAIL("Heretic Knowledge: Got a invalid knowledge data for [knowledge_path] in the heretic paths!")
				continue
			var/list/next_knowledge = knowledge_data[HKT_NEXT]
			list_to_check |= next_knowledge


	// We now have a list that SHOULD contain all knowledges with a path set (list_to_check).
	// Let's compare it to our original list (all_possible_knowledge). If they're not identical,
	// then somewhere we missed a knowledge somewhere, and should throw a fail.
	if(length(all_possible_knowledge) != length(all_possible_knowledge & list_to_check))
		// Unreachables is a list of path + typepaths - all paths that cannot be obtained.
		var/list/unreachables = all_possible_knowledge - list_to_check
		for(var/datum/heretic_knowledge/lost_knowledge as anything in unreachables)
			TEST_FAIL("Heretic Knowledge: [lost_knowledge] is unreachable by players! Add it to another knowledge's 'next_knowledge' list. If it is purposeful, set its route to 'null'.")
