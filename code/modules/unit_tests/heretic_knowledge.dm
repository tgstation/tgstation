
/*
 * This test checks all heretic knowledge nodes and validates they are setup correctly.
 * We check that all knowledge is reachable by players (through the research tree)
 * and that all knowledge have a valid next_knowledge list.
 */
/datum/unit_test/heretic_knowledge

/datum/unit_test/heretic_knowledge/Run()
	if(!GLOB.heretic_research_tree)
		GLOB.heretic_research_tree = generate_heretic_research_tree()
	// First, we get a list of all knowledge types
	// EXCLUDING all abstract types
	var/list/all_possible_knowledge = typesof(/datum/heretic_knowledge)
	for(var/datum/heretic_knowledge/knowledge_type as anything in all_possible_knowledge)
		if(initial(knowledge_type.abstract_parent_type) == knowledge_type)
			all_possible_knowledge -= knowledge_type

	// Now, let's build a list of all researchable knowledge
	// from the ground up. We start with all starting knowledge,
	// then add the next possible knowledges back into the list
	// repeatedly, until we run out of knowledges to add.
	var/list/list_to_check = GLOB.heretic_start_knowledge.Copy()
	var/i = 0
	while(i < length(list_to_check))
		var/datum/heretic_knowledge/knowledge = list_to_check[++i]
		if(!ispath(knowledge))
			TEST_FAIL("Heretic Knowledge: Got a non-heretic knowledge datum (Got: [knowledge]) in the list knowledges!")
		// Next knowledge is a list of typepaths.
		for(var/datum/heretic_knowledge/next_knowledge as anything in GLOB.heretic_research_tree[knowledge][HKT_NEXT])
			if(!ispath(next_knowledge))
				TEST_FAIL("Heretic Knowledge: [next_knowledge.type] has a [isnull(next_knowledge) ? "null":"invalid path"] in its next_knowledge list!")
				continue
			if(next_knowledge in list_to_check)
				continue
			list_to_check += next_knowledge


	// We now have a list that SHOULD contain all knowledges with a path set (list_to_check).
	// Let's compare it to our original list (all_possible_knowledge). If they're not identical,
	// then somewhere we missed a knowledge somewhere, and should throw a fail.
	if(length(all_possible_knowledge) != length(all_possible_knowledge & list_to_check))
		// Unreachables is a list of typepaths - all paths that cannot be obtained.
		var/list/unreachables = all_possible_knowledge - list_to_check
		for(var/datum/heretic_knowledge/lost_knowledge as anything in unreachables)
			TEST_FAIL("Heretic Knowledge: [lost_knowledge] is unreachable by players! Add it to another knowledge's 'next_knowledge' list. If it is purposeful, set its route to 'null'.")
