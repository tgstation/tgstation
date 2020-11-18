/datum/unit_test/heretic_knowledge/Run()
	///List of all knowledge excluding the unreachable base types.
	var/list/blacklist = list(/datum/eldritch_knowledge/spell,/datum/eldritch_knowledge/curse,/datum/eldritch_knowledge/final,/datum/eldritch_knowledge/summon)
	var/list/all_possible_knowledge = subtypesof(/datum/eldritch_knowledge) - blacklist
	//Convert to assoc
	for(var/X in all_possible_knowledge)
		all_possible_knowledge[X] = FALSE

	var/list/list_to_check = initial(/datum/antagonist/heretic.initial_knowledge)
	for(var/X in list_to_check)

		var/datum/eldritch_knowledge/knowledge = X

		if(all_possible_knowledge[knowledge])
			continue

		all_possible_knowledge[knowledge] = TRUE
		list_to_check |= initial(knowledge.next_knowledge)

	for(var/X in all_possible_knowledge)
		if(!all_possible_knowledge[X])
			var/datum/eldritch_knowledge/knowledge = X
			Fail("[initial(knowledge.name)] is not accessible by the player! If this is done on purpose add it to the blacklist!")
