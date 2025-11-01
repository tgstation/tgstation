
/*
 * This test checks all heretic knowledge nodes and validates they are setup correctly.
 * We check that all knowledge is reachable by players (through the research tree)
 * and that all knowledge have a valid next_knowledge list.
 */
/datum/unit_test/heretic_knowledge
TEST_FOCUS(/datum/unit_test/heretic_knowledge)

/datum/unit_test/heretic_knowledge/Run()
	GLOB.heretic_path_knowledges = generate_global_heretic_tree()

	var/list/all_knowledges = list()

	var/list/start_knowledges = list()
	generate_heretic_starting_knowledge(start_knowledges)
	all_knowledges += start_knowledges

	// we need to generate a set of shop_knowledges and drafted knowledges as they're unique per path and slightly random in drafted knowledges
	for(var/path in GLOB.heretic_path_knowledges)
		var/list/tree = GLOB.heretic_path_knowledges[path]
		var/list/shop = list()
		var/list/draft = list()
		determine_drafted_knowledge(path, tree, shop, draft)
		all_knowledges += tree
		all_knowledges += shop
		all_knowledges += draft

	var/list/all_ids = get_knowledge_ids(all_knowledges)

	var/list/all_possible_knowledge = typesof(/datum/heretic_knowledge)

	for(var/datum/heretic_knowledge/knowledge_type as anything in all_possible_knowledge)
		if(initial(knowledge_type.abstract_parent_type) == knowledge_type)
			all_possible_knowledge -= knowledge_type

	// Now, let's build a list of all researchable knowledge
	// from the ground up. We start with all starting knowledge,
	// then add the next possible knowledges back into the list
	// repeatedly, until we run out of knowledges to add.
	var/list/list_to_check = start_knowledges
	var/i = 0
	while(i < length(list_to_check))
		var/datum/heretic_knowledge/knowledge = list_to_check[++i]
		// Next knowledge is a list of id that consistents of typepath_shopcategory
		// we basically need to go through the entire chain of HKT_NEXT's to validate the ID's starting from GLOB.heretic_start_knowledge
		/// TODO
		var/list/knowledge_info = all_knowledges[knowledge]
		for(var/next_id in knowledge_info[HKT_NEXT])
			if(!istext(next_id))
				TEST_FAIL("Heretic Knowledge: [knowledge] has an invalid non-string next_knowledge entry (Got: [next_id])!")
			if(!(next_id in all_ids))
				TEST_FAIL("Heretic Knowledge: [knowledge] has a next_knowledge entry that does not exist (Got: [next_id])!")
			list_to_check[knowledge] = knowledge_info


	// We now have a list that SHOULD contain all knowledges with a path set (list_to_check).
	// Let's compare it to our original list (all_possible_knowledge). If they're not identical,
	// then somewhere we missed a knowledge somewhere, and should throw a fail.
	if(length(all_possible_knowledge) != length(all_possible_knowledge & list_to_check))
		// Unreachables is a list of typepaths - all paths that cannot be obtained.
		var/list/unreachables = all_possible_knowledge - list_to_check
		for(var/datum/heretic_knowledge/lost_knowledge as anything in unreachables)
			TEST_FAIL("Heretic Knowledge: [lost_knowledge] is unreachable by players! Add it to another knowledge's 'next_knowledge' list. If it is purposeful, set its route to 'null'.")

/proc/get_knowledge_ids(list/knowledges)
	var/list/ids = list()
	for(var/datum/heretic_knowledge/knowledge_path as anything in knowledges)
		var/datum/heretic_knowledge/knowledge = knowledges[knowledge_path]
		ids += knowledge[HKT_ID]
	return ids
