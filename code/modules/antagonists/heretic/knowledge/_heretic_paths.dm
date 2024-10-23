//Global typecache of all heretic knowledges -> instantiate the tree columns -> make them link themselves -> replace the old heretic stuff

//heretic research tree is a directional graph so we can use some basic graph stuff to make internally handling it easier
GLOBAL_LIST_INIT(heretic_research_tree,generate_heretic_research_tree())

/proc/generate_heretic_research_tree()
	var/list/heretic_research_tree = list()
	for(var/type in subtypesof(/datum/heretic_knowledge))
		heretic_research_tree[type] = list()
		heretic_research_tree[type]["next"] = list()
		heretic_research_tree[type]["banned"] = list()

	var/list/paths = list()
	for(var/type in subtypesof(/datum/heretic_research_tree_column))
		if(initial(abstract_parent_type) == type)
			continue

		var/datum/heretic_knowledge_tree_column/column = new type()
		paths[column.id] = id

	var/list/start_blacklist = list()
	var/list/grasp_blacklist = list()
	var/list/mark_blacklist = list()
	var/list/blade_blacklist = list()
	var/list/asc_blacklist = list()

	for(var/id in paths)
		if(!istype(paths[id],/datum/heretic_knowledge_tree_column/main))
			continue
		var/datum/heretic_knowledge_tree_column/main/column = paths[id]

		start_blacklist += column.start
		grasp_blacklist += column.grasp
		mark_blacklist += column.mark
		blade_blacklist += column.blade
		asc_blacklist += column.ascension


	for(var/id in paths)
		var/datum/heretic_knowledge_tree_column/this_column = paths[id]
		var/datum/heretic_knowledge_tree_column/neighbour_0 = paths[this_column.neighbour_id_0]
		var/datum/heretic_knowledge_tree_column/neighbour_1 = paths[this_column.neighbour_id_1]

		//horizontal (two way)
		heretic_research_tree[this_column.tier1]["next"] += neighbour_0.tier1
		heretic_research_tree[this_column.tier1]["next"] += neighbour_1.tier1
		heretic_research_tree[this_column.tier2]["next"] += neighbour_0.tier2
		heretic_research_tree[this_column.tier2]["next"] += neighbour_1.tier2
		heretic_research_tree[this_column.tier3]["next"] += neighbour_0.tier3
		heretic_research_tree[this_column.tier3]["next"] += neighbour_1.tier3

		if(this_column.abstract_parent_type != /datum/heretic_knowledge_tree_column/main)
			continue

		//vertical (one way)
		heretic_research_tree[this_column.start]["next"] 				+= this_column.grasp
		heretic_research_tree[this_column.grasp]["next"] 				+= this_column.tier1
		heretic_research_tree[this_column.tier1]["next"] 				+= this_column.mark
		heretic_research_tree[this_column.mark]["next"]  				+= this_column.ritual_of_knowledge
		heretic_research_tree[this_column.ritual_of_knowledge]["next"] 	+= this_column.unique_ability
		heretic_research_tree[this_column.unique_ability]["next"] 		+= this_column.tier2
		heretic_research_tree[this_column.tier2]["next"] 				+= this_column.blade
		heretic_research_tree[this_column.blade]["next"] 				+= this_column.tier3
		heretic_research_tree[this_column.tier3]["next"] 				+= this_column.ascension

		//blacklist
		heretic_research_tree[this_column.start]["banned"] 		+= (start_blacklist - this_column.start)
		heretic_research_tree[this_column.grasp]["banned"] 		+= (grasp_blacklist - this_column.grasp)
		heretic_research_tree[this_column.mark]["banned"] 		+= (mark_blacklist  - this_column.mark)
		heretic_research_tree[this_column.blade]["banned"] 		+= (blade_blacklist - this_column.blade)
		heretic_research_tree[this_column.ascension]["banned"] 	+= (asc_blacklist   - this_column.ascension)

		//Per path bullshit goes here \/\/\/
		heretic_research_tree[this_column.tier2]["next"] += /datum/heretic_knowledge/reroll_targets

	// If you want to do any custom bullshit put it here \/\/\/
	heretic_research_tree[/datum/heretic_knowledge/rifle]["next"] += /datum/heretic_knowledge/rifle_ammo

	return heretic_research_tree

/datum/heretic_knowledge_tree_column

	var/abstract_parent_type = /datum/heretic_knowledge_tree_column

	var/id

	var/neighbour_id_0
	var/neighbour_id_1

	var/tier1

	var/tier2

	var/tier3

/datum/heretic_knowledge_tree_column/main

	abstract_parent_type = /datum/heretic_knowledge_tree_column/main

	var/start

	var/grasp

	var/mark

	var/ritual_of_knowledge

	var/unique_ability

	var/blade

	var/ascension
