/*
 * This test checks all heretic knowledge nodes and validates they are setup correctly.
 * We check that all knowledge is reachable by players (through the research tree)
 * and that all knowledge have a valid next_knowledge list.
 */
/datum/unit_test/heretic_knowledge

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
		var/datum/heretic_knowledge/path_to_create = list_to_check[++i]
		if(!ispath(path_to_create))
			Fail("Heretic Knowlege: Got a non-heretic knowledge datum (Got: [path_to_create]) in the list knowledges!")
		var/datum/heretic_knowledge/instantiated_knowledge = new path_to_create()
		// Next knowledge is a list of typepaths.
		for(var/datum/heretic_knowledge/next_knowledge as anything in instantiated_knowledge.next_knowledge)
			if(!ispath(next_knowledge))
				Fail("Heretic Knowlege: [next_knowledge.type] has a [isnull(next_knowledge) ? "null":"invalid path"] in its next_knowledge list!")
				continue
			if(next_knowledge in list_to_check)
				continue
			list_to_check += next_knowledge

		qdel(instantiated_knowledge)

	// We now have a list that SHOULD contain all knowledges with a path set (list_to_check).
	// Let's compare it to our original list (all_possible_knowledge). If they're not identical,
	// then somewhere we missed a knowledge somewhere, and should throw a fail.
	if(length(all_possible_knowledge) != length(all_possible_knowledge & list_to_check))
		// Unreachables is a list of typepaths - all paths that cannot be obtained.
		var/list/unreachables = all_possible_knowledge - list_to_check
		for(var/datum/heretic_knowledge/lost_knowledge as anything in unreachables)
			Fail("Heretic Knowlege: [lost_knowledge] is unreachable by players! Add it to another knowledge's 'next_knowledge' list. If it is purposeful, set its route to 'null'.")


/*
 * This test checks that all main heretic paths are of the same length.
 *
 * If any two main paths are not equal length, the test will fail and quit, reporting
 * which two paths did not match. Then, whichever is erroneous can be determined manually.
 */
/datum/unit_test/heretic_main_paths

/datum/unit_test/heretic_main_paths/Run()
	// A list of path strings we don't need to check.
	var/list/paths_we_dont_check = list(PATH_SIDE, PATH_START)
	// An assoc list of [path string] to [number of nodes we found of that path].
	var/list/paths = list()
	// The starting knowledge node, we use this to deduce what main paths we have.
	var/datum/heretic_knowledge/spell/basic/starter_node = new()

	// Go through and determine what paths exist from our base node.
	for(var/datum/heretic_knowledge/possible_path as anything in starter_node.next_knowledge)
		paths[initial(possible_path.route)] = 0

	qdel(starter_node) // Get rid of that starter node, we don't need it anymore.

	// Now go through all the knowledges and record how many of each  main path exist.
	for(var/datum/heretic_knowledge/knowledge as anything in subtypesof(/datum/heretic_knowledge))
		var/knowledge_route = initial(knowledge.route)
		// null (abstract), side paths, and start paths we can skip
		if(isnull(knowledge_route) || (knowledge_route in paths_we_dont_check))
			continue

		if(isnull(paths[knowledge_route]))
			Fail("Heretic Knowledge: An invalid knowledge route ([knowledge_route]) was found on [knowledge].")
			continue

		paths[knowledge_route]++

	// Now all entries in the paths list should have an equal value.
	// If any two entries do not match, then one of them is incorrect, and the test fails.
	for(var/main_path in paths)
		for(var/other_main_path in (paths - main_path))
			TEST_ASSERT(paths[main_path] == paths[other_main_path], \
				"Heretic Knowledge: [main_path] had [paths[main_path]] knowledges, \
				which was not equal to [other_main_path]'s [paths[other_main_path]] knowledges. \
				All main paths should have the same number of knowledges!")
