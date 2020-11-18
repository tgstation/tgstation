/datum/unit_test/heretic_knowledge/Run()
	///List of all knowledge excluding the unreachable base types.
	var/list/blacklist = list(/datum/eldritch_knowledge/spell,/datum/eldritch_knowledge/curse,/datum/eldritch_knowledge/final,/datum/eldritch_knowledge/summon)
	var/list/all_possible_knowledge = subtypesof(/datum/eldritch_knowledge) - blacklist

	var/list/list_to_check = GLOB.heretic_start_knowledge.Copy()
	var/list/already_checked = list()
	for(var/X in list_to_check)
		var/datum/eldritch_knowledge/EK = X

		already_checked += EK

		for(var/Y in initial(EK.next_knowledge))
			if((Y in already_checked) || (Y in list_to_check))
				continue
			list_to_check += Y


	if(length(all_possible_knowledge) != length(all_possible_knowledge | list_to_check))
		Fail("Some eldritch knowledge is inaccessible. If this is on purpose add the path to the blacklist.")

