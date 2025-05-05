//Global typecache of all heretic knowledges -> instantiate the tree columns -> make them link themselves -> replace the old heretic stuff

//heretic research tree is a directional graph so we can use some basic graph stuff to make internally handling it easier
GLOBAL_LIST(heretic_research_tree)

//HKT = Heretic Knowledge Tree (Heretic Research Tree :3) these objects really only exist for a short period of time at startup and then get deleted
/datum/heretic_knowledge_tree_column
	///Route that symbolizes what path this is
	var/route
	///Used to determine if this is a side path or a main path
	var/abstract_parent_type = /datum/heretic_knowledge_tree_column
	///UI background
	var/ui_bgr = "node_side"

	//-- Knowledge in order of unlocking
	///Starting knowledge - first thing you pick. Gives you access to blades, grasp, mark and passive
	var/start
	///Tier1 knowledge
	var/knowledge_tier1
	/// First Draft
	var/draft_tier1 = list(/datum/heretic_knowledge/drafting, /datum/heretic_knowledge/drafting, /datum/heretic_knowledge/drafting)
	///Tier2 knowledge
	var/knowledge_tier2
	/// Second Draft
	var/draft_tier2 = list(/datum/heretic_knowledge/drafting, /datum/heretic_knowledge/drafting, /datum/heretic_knowledge/drafting)
	///Path-Specific Heretic robes
	var/robes
	///Tier3 knowledge
	var/knowledge_tier3
	/// Third Draft
	var/draft_tier3 = list(/datum/heretic_knowledge/drafting, /datum/heretic_knowledge/drafting, /datum/heretic_knowledge/drafting)
	///Blade upgrade
	var/blade
	///Tier4 knowledge
	var/knowledge_tier4
	/// Fourth Draft
	var/draft_tier4 = list(/datum/heretic_knowledge/drafting, /datum/heretic_knowledge/drafting, /datum/heretic_knowledge/drafting)
	///Ascension
	var/ascension

/proc/generate_heretic_research_tree()
	var/list/heretic_research_tree = list()

	//Initialize the data structure
	for(var/type in subtypesof(/datum/heretic_knowledge))
		heretic_research_tree[type] = list()
		heretic_research_tree[type][HKT_NEXT] = list()
		heretic_research_tree[type][HKT_BAN] = list()
		heretic_research_tree[type][HKT_DEPTH] = 1
		heretic_research_tree[type][HKT_UI_BGR] = "node_side"

		var/datum/heretic_knowledge/knowledge = type
		if(initial(knowledge.is_starting_knowledge))
			heretic_research_tree[type][HKT_ROUTE] = PATH_START
			continue

		heretic_research_tree[type][HKT_ROUTE] = null

	var/list/paths = list()
	for(var/type in subtypesof(/datum/heretic_knowledge_tree_column))
		var/datum/heretic_knowledge_tree_column/column_path = type
		if(initial(column_path.abstract_parent_type) == column_path)
			continue

		var/datum/heretic_knowledge_tree_column/column = new type()
		paths[column.type] = column

	var/list/start_blacklist = list()
	var/list/blade_blacklist = list()
	var/list/asc_blacklist = list()

	for(var/id in paths)
		if(!istype(paths[id],/datum/heretic_knowledge_tree_column))
			continue
		var/datum/heretic_knowledge_tree_column/column = paths[id]

		start_blacklist += column.start
		blade_blacklist += column.blade
		asc_blacklist += column.ascension

	heretic_research_tree[/datum/heretic_knowledge/spell/basic][HKT_NEXT] += start_blacklist

	for(var/id in paths)
		var/datum/heretic_knowledge_tree_column/this_column = paths[id]
		//horizontal (two way)
		var/list/knowledge_tier1 = this_column.knowledge_tier1
		var/list/knowledge_tier2 = this_column.knowledge_tier2
		var/list/knowledge_tier3 = this_column.knowledge_tier3
		var/list/knowledge_tier4 = this_column.knowledge_tier4

		//Tier1, 2 and 3 can technically be lists so we handle them here
		if(!islist(this_column.knowledge_tier1))
			knowledge_tier1 = list(this_column.knowledge_tier1)

		if(!islist(this_column.knowledge_tier2))
			knowledge_tier2 = list(this_column.knowledge_tier2)

		if(!islist(this_column.knowledge_tier3))
			knowledge_tier3 = list(this_column.knowledge_tier3)

		if(!islist(this_column.knowledge_tier4))
			knowledge_tier4 = list(this_column.knowledge_tier4)

		for(var/t1_knowledge in knowledge_tier1)
			heretic_research_tree[t1_knowledge][HKT_ROUTE] = this_column.route
			heretic_research_tree[t1_knowledge][HKT_UI_BGR] = this_column.ui_bgr
			heretic_research_tree[t1_knowledge][HKT_DEPTH] = 3

		for(var/t2_knowledge in knowledge_tier2)
			heretic_research_tree[t2_knowledge][HKT_ROUTE] = this_column.route
			heretic_research_tree[t2_knowledge][HKT_UI_BGR] = this_column.ui_bgr
			heretic_research_tree[t2_knowledge][HKT_DEPTH] = 5

		for(var/t3_knowledge in knowledge_tier3)
			heretic_research_tree[t3_knowledge][HKT_ROUTE] = this_column.route
			heretic_research_tree[t3_knowledge][HKT_UI_BGR] = this_column.ui_bgr
			heretic_research_tree[t3_knowledge][HKT_DEPTH] = 8

		for(var/t4_knowledge in knowledge_tier4)
			heretic_research_tree[t4_knowledge][HKT_ROUTE] = this_column.route
			heretic_research_tree[t4_knowledge][HKT_UI_BGR] = this_column.ui_bgr
			heretic_research_tree[t4_knowledge][HKT_DEPTH] = 11

		//Everything below this line is considered to be a "main path" and not a side path
		//Since we are handling the heretic research tree column by column this is required
		if(this_column.abstract_parent_type != /datum/heretic_knowledge_tree_column)
			continue

		var/datum/heretic_knowledge_tree_column/main_column = this_column
		//vertical (one way)
		heretic_research_tree[/datum/heretic_knowledge/spell/basic] += main_column.start
		heretic_research_tree[main_column.start][HKT_NEXT] += main_column.knowledge_tier1

		//t1 handling
		for(var/t1_knowledge in knowledge_tier1)
			heretic_research_tree[t1_knowledge][HKT_NEXT] += main_column.knowledge_tier2
		//t2 handling
		for(var/t2_knowledge in knowledge_tier2)
			heretic_research_tree[t2_knowledge][HKT_NEXT] += main_column.robes

		// Robes upgrade gives us access to T3
		heretic_research_tree[main_column.robes][HKT_NEXT] += main_column.knowledge_tier3

		//t3 handling
		for(var/t3_knowledge in knowledge_tier3)
			heretic_research_tree[t3_knowledge][HKT_NEXT] += main_column.blade

		// Blade upgrade gives us access to T4
		heretic_research_tree[main_column.blade][HKT_NEXT] += main_column.knowledge_tier4

		//t4 handling
		for(var/t4_knowledge in knowledge_tier4)
			heretic_research_tree[t4_knowledge][HKT_NEXT] += main_column.ascension

		//blacklist
		heretic_research_tree[main_column.start][HKT_BAN] += (start_blacklist - main_column.start) + (asc_blacklist - main_column.ascension)
		heretic_research_tree[main_column.blade][HKT_BAN] += (blade_blacklist - main_column.blade)

		//route stuff
		heretic_research_tree[main_column.start][HKT_ROUTE] = main_column.route
		heretic_research_tree[main_column.robes][HKT_ROUTE] = main_column.route
		heretic_research_tree[main_column.blade][HKT_ROUTE] = main_column.route
		heretic_research_tree[main_column.ascension][HKT_ROUTE] = main_column.route

		heretic_research_tree[main_column.start][HKT_UI_BGR] = main_column.ui_bgr
		heretic_research_tree[main_column.robes][HKT_UI_BGR] = main_column.ui_bgr
		heretic_research_tree[main_column.blade][HKT_UI_BGR] = main_column.ui_bgr
		heretic_research_tree[main_column.ascension][HKT_UI_BGR] = main_column.ui_bgr
		//depth stuff
		heretic_research_tree[main_column.start][HKT_DEPTH] = 2
		heretic_research_tree[main_column.robes][HKT_DEPTH] = 7
		heretic_research_tree[main_column.blade][HKT_DEPTH] = 10
		heretic_research_tree[main_column.ascension][HKT_DEPTH] = 13

		//Per path bullshit goes here \/\/\/
		for(var/t3_knowledge in knowledge_tier3)
			heretic_research_tree[t3_knowledge][HKT_NEXT] += /datum/heretic_knowledge/reroll_targets

	// Drafting knowledge here. They are placeholders when the tree is built because only 1 tree is built for all heretics.
	// This means that the knowledge itself is randomized once the heretic unlocks them
		for(var/t1_knowledge in knowledge_tier1)
			heretic_research_tree[t1_knowledge][HKT_NEXT] += /datum/heretic_knowledge/drafting/one
			heretic_research_tree[t1_knowledge][HKT_NEXT] += /datum/heretic_knowledge/drafting/one
			heretic_research_tree[t1_knowledge][HKT_NEXT] += /datum/heretic_knowledge/drafting/one
		for(var/t2_knowledge in knowledge_tier2)
			heretic_research_tree[t2_knowledge][HKT_NEXT] += /datum/heretic_knowledge/drafting/two
			heretic_research_tree[t2_knowledge][HKT_NEXT] += /datum/heretic_knowledge/drafting/two
			heretic_research_tree[t2_knowledge][HKT_NEXT] += /datum/heretic_knowledge/drafting/two
		for(var/t3_knowledge in knowledge_tier3)
			heretic_research_tree[t3_knowledge][HKT_NEXT] += /datum/heretic_knowledge/drafting/three
			heretic_research_tree[t3_knowledge][HKT_NEXT] += /datum/heretic_knowledge/drafting/three
			heretic_research_tree[t3_knowledge][HKT_NEXT] += /datum/heretic_knowledge/drafting/three
		for(var/t4_knowledge in knowledge_tier4)
			heretic_research_tree[t4_knowledge][HKT_NEXT] += /datum/heretic_knowledge/drafting/four
			heretic_research_tree[t4_knowledge][HKT_NEXT] += /datum/heretic_knowledge/drafting/four
			heretic_research_tree[t4_knowledge][HKT_NEXT] += /datum/heretic_knowledge/drafting/four

	heretic_research_tree[/datum/heretic_knowledge/drafting/one][HKT_ROUTE] = PATH_SIDE
	heretic_research_tree[/datum/heretic_knowledge/drafting/one][HKT_DEPTH] = 4
	heretic_research_tree[/datum/heretic_knowledge/drafting/two][HKT_ROUTE] = PATH_SIDE
	heretic_research_tree[/datum/heretic_knowledge/drafting/two][HKT_DEPTH] = 6
	heretic_research_tree[/datum/heretic_knowledge/drafting/three][HKT_ROUTE] = PATH_SIDE
	heretic_research_tree[/datum/heretic_knowledge/drafting/three][HKT_DEPTH] = 9
	heretic_research_tree[/datum/heretic_knowledge/drafting/four][HKT_ROUTE] = PATH_SIDE
	heretic_research_tree[/datum/heretic_knowledge/drafting/four][HKT_DEPTH] = 12


	// If you want to do any custom bullshit put it here \/\/\/
	heretic_research_tree[/datum/heretic_knowledge/reroll_targets][HKT_ROUTE] = PATH_SIDE
	heretic_research_tree[/datum/heretic_knowledge/reroll_targets][HKT_DEPTH] = 8

	heretic_research_tree[/datum/heretic_knowledge/rifle][HKT_NEXT] += /datum/heretic_knowledge/rifle_ammo
	heretic_research_tree[/datum/heretic_knowledge/rifle_ammo][HKT_ROUTE] = PATH_SIDE
	heretic_research_tree[/datum/heretic_knowledge/rifle_ammo][HKT_DEPTH] = heretic_research_tree[/datum/heretic_knowledge/rifle][HKT_DEPTH]

	//and we're done
	QDEL_LIST_ASSOC_VAL(paths)
	return heretic_research_tree
