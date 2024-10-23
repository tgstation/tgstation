//Global typecache of all heretic knowledges -> instantiate the tree columns -> make them link themselves -> replace the old heretic stuff

//heretic research tree is a directional graph so we can use some basic graph stuff to make internally handling it easier
GLOBAL_LIST_INIT(heretic_research_tree,generate_heretic_research_tree())


//HKT = Heretic Knowledge Tree (Heretic Research Tree :3)
//(whats the point of doing macros if typing them out is signigicantly longer than the string they get replaced by?)
#define HKT_NEXT "next"
#define HKT_BAN "ban"
#define HKT_DEPTH "depth"
#define HKT_ROUTE "route"

/datum/heretic_knowledge_tree_column

	var/

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

/proc/generate_heretic_research_tree()
	var/list/heretic_research_tree = list()
	for(var/type in subtypesof(/datum/heretic_knowledge))
		heretic_research_tree[type] = list()
		heretic_research_tree[type][HKT_NEXT] = list()
		heretic_research_tree[type][HKT_BAN] = list()
		heretic_research_tree[type][HKT_DEPTH] = 0

		var/datum/heretic_knowledge/knowledge = type
		if(initial(knowledge.is_starting_knowledge) == TRUE)
			heretic_research_tree[type][HKT_ROUTE] = PATH_START
			continue

		heretic_research_tree[type][HKT_ROUTE] = null

	var/list/paths = list()
	for(var/type in subtypesof(/datum/heretic_knowledge_tree_column))
		var/datum/heretic_knowledge_tree_column/column_path = type
		if(initial(column_path.abstract_parent_type) == column_path)
			continue

		var/datum/heretic_knowledge_tree_column/column = new type()
		paths[column.id] = column

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
		//we don't stuff them into a single list coz it is technically possible for these to be lists aswell and we dont want to nest them
		heretic_research_tree[this_column.tier1][HKT_NEXT] += neighbour_0.tier1
		heretic_research_tree[this_column.tier1][HKT_NEXT] += neighbour_1.tier1

		heretic_research_tree[this_column.tier2][HKT_NEXT] += neighbour_0.tier2
		heretic_research_tree[this_column.tier2][HKT_NEXT] += neighbour_1.tier2

		heretic_research_tree[this_column.tier3][HKT_NEXT] += neighbour_0.tier3
		heretic_research_tree[this_column.tier3][HKT_NEXT] += neighbour_1.tier3

		if(this_column.abstract_parent_type != /datum/heretic_knowledge_tree_column/main)
			continue

		var/datum/heretic_knowledge_tree_column/main/main_column = this_column
		//vertical (one way)
		heretic_research_tree[/datum/heretic_knowledge/spell/basic] 	+= main_column.start
		heretic_research_tree[main_column.start][HKT_NEXT] 				+= main_column.grasp
		heretic_research_tree[main_column.grasp][HKT_NEXT] 				+= main_column.tier1
		heretic_research_tree[main_column.tier1][HKT_NEXT] 				+= main_column.mark
		heretic_research_tree[main_column.mark][HKT_NEXT]  				+= main_column.ritual_of_knowledge
		heretic_research_tree[main_column.ritual_of_knowledge][HKT_NEXT] 	+= main_column.unique_ability
		heretic_research_tree[main_column.unique_ability][HKT_NEXT] 		+= main_column.tier2
		heretic_research_tree[main_column.tier2][HKT_NEXT] 				+= main_column.blade
		heretic_research_tree[main_column.blade][HKT_NEXT] 				+= main_column.tier3
		heretic_research_tree[main_column.tier3][HKT_NEXT] 				+= main_column.ascension

		//blacklist
		heretic_research_tree[main_column.start][HKT_BAN] 		+= (start_blacklist - main_column.start)
		heretic_research_tree[main_column.grasp][HKT_BAN] 		+= (grasp_blacklist - main_column.grasp)
		heretic_research_tree[main_column.mark][HKT_BAN] 		+= (mark_blacklist  - main_column.mark)
		heretic_research_tree[main_column.blade][HKT_BAN] 		+= (blade_blacklist - main_column.blade)
		heretic_research_tree[main_column.ascension][HKT_BAN] 	+= (asc_blacklist   - main_column.ascension)

		//Per path bullshit goes here \/\/\/
		heretic_research_tree[this_column.tier2][HKT_NEXT] += /datum/heretic_knowledge/reroll_targets

	// If you want to do any custom bullshit put it here \/\/\/
	heretic_research_tree[/datum/heretic_knowledge/rifle][HKT_NEXT] += /datum/heretic_knowledge/rifle_ammo

	return heretic_research_tree
