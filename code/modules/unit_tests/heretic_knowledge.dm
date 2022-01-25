/// This test checks all heretic knowledge nodes - excluding the ones which are unreachable on purpose - and ensures players can reach them in game.
/// If it finds a node that is unreachable, it throws an error.
/datum/unit_test/heretic_knowledge/Run()
	///List of all knowledge excluding the unreachable base types.
	var/list/blacklist = list(/datum/heretic_knowledge/spell,/datum/heretic_knowledge/curse,/datum/heretic_knowledge/final,/datum/heretic_knowledge/summon)
	var/list/all_possible_knowledge = subtypesof(/datum/heretic_knowledge) - blacklist

	var/list/list_to_check = GLOB.heretic_start_knowledge.Copy()
	var/i = 0
	while(i < length(list_to_check))
		var/datum/heretic_knowledge/eldritch_knowledge = allocate(list_to_check[++i])
		for(var/next_knowledge in eldritch_knowledge.next_knowledge)
			if(next_knowledge in list_to_check)
				continue
			list_to_check += next_knowledge

	if(length(all_possible_knowledge) != length(all_possible_knowledge & list_to_check))
		var/list/unreachables = all_possible_knowledge - list_to_check
		for(var/X in unreachables)
			var/datum/heretic_knowledge/eldritch_knowledge = X
			Fail("[initial(eldritch_knowledge.name)] is unreachable by players! Add it to the blacklist in /code/modules/unit_tests/heretic_knowledge.dm if it is purposeful!")
