
SUBSYSTEM_DEF(reagents)
	flags = SS_NO_FIRE

	var/list/reagents_by_id = list()			//id = reagent datum
	var/list/reactions_by_id = list()			//id = reaction datum

	var/list/reagent_ids_by_type = list()		//type = id - used for lookup

	var/list/reactions_by_reagent_id = list()

/datum/controller/subsystem/reagents/Initialize()
	initialize_reagents(TRUE)
	initialize_reactions(TRUE)
	generate_reaction_reagent_list()
	return ..()

/datum/controller/subsystem/reagents/proc/initialize_reagents(clear_all = FALSE)
	if(clear_all)
		reagents_by_id = list()
		reagent_ids_by_type = list()
	else
		LAZYINITLIST(reagents_by_id)
		LAZYINITLIST(reagent_ids_by_type)

	var/list/paths = subtypesof(/datum/reagent)

	for(var/i in paths)
		var/datum/reagent/D = new i
		reagents_by_id[D.id] = D
		reagent_ids_by_type[i] = D.id

/datum/controller/subsystem/reagents/proc/initialize_reactions(clear_all = FALSE)
	if(clear_all)
		reactions_by_id = list()
	else
		LAZYINITLIST(reactions_by_id)

	var/list/paths = subtypesof(/datum/chemical_reaction)

	for(var/i in paths)
		var/datum/chemical_reaction/D = new i
		reactions_by_id[D.id] = D

/datum/controller/subsystem/reagents/proc/generate_reaction_reagent_list()
	reactions_by_reagent_id = list()

	for(var/id in reactions_by_id)
		var/datum/chemical_reaction/D = reactions_by_id[id]

		if(D.required_reagents && D.required_reagents.len)
			for(var/trigger_id in D.required_reagents)
				LAZYADD(reactions_by_reagent_id[trigger_id], D)
				break //Don't bother adding ourselves to other reagent ids, it is redundant
