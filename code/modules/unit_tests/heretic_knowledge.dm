/*
 * This test checks all heretic knowledge nodes
 * (excluding the ones which are unreachable on purpose)
 * and ensures players can reach them in game.
 *
 * If it finds a node that is unreachable, it throws an error.
 */
/datum/unit_test/heretic_knowledge/Run()

	// First, we get a list of all knowledge types
	// EXCLUDING types which have route unset / set to null.
	// (Types without a route set are assumed to be abstract or purposefully unreachable)
	var/list/all_possible_knowledge = typesof(/datum/heretic_knowledge)
	for(var/datum/heretic_knowledge/knowledge_type as anything in all_possible_knowledge)
		if(isnull(initial(knowledge_type.route)))
			all_possible_knowledge -= knowledge_type

	// Now, let's build a list of all researchable knowledge
	// from the ground up. We start with all starting knowledge,
	// then add the next possible knowledges back into the list
	// repeatedly, until we run out of knowledges to add.
	var/list/list_to_check = GLOB.heretic_start_knowledge.Copy()
	var/i = 0
	while(i < length(list_to_check))
		var/datum/heretic_knowledge/eldritch_knowledge = allocate(list_to_check[++i])
		for(var/next_knowledge in eldritch_knowledge.next_knowledge)
			if(next_knowledge in list_to_check)
				continue
			list_to_check += next_knowledge

	// We now have a list that SHOULD contain all knowledges with a path set (list_to_check).
	// Let's compare it to our original list (all_possible_knowledge). If they're not identical,
	// then somewhere we missed a knowledge somewhere, and should throw a fail.
	if(length(all_possible_knowledge) != length(all_possible_knowledge & list_to_check))
		var/list/unreachables = all_possible_knowledge - list_to_check
		for(var/datum/heretic_knowledge/lost_knowledge as anything in unreachables)
			Fail("[initial(lost_knowledge.name)] is unreachable by players! Add it to another knowledge's 'next_knowledge' list. If it is purposeful, set its route to 'null'.")
