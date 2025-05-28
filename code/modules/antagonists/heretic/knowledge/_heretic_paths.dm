//Global typecache of all heretic knowledges -> instantiate the tree columns -> make them link themselves -> replace the old heretic stuff

//heretic research tree is a directional graph so we can use some basic graph stuff to make internally handling it easier
GLOBAL_LIST(heretic_research_tree)

//HKT = Heretic Knowledge Tree (Heretic Research Tree :3) these objects really only exist for a short period of time at startup and then get deleted
/datum/heretic_knowledge_tree_column
	///Route that symbolizes what path this is
	var/route
	var/icon_state = "dark_blade"
	var/difficulty = "Insane"
	var/description = "A heretic knowledge tree column, used to define a path of knowledge."
	var/list/icon = list(
		"icon" = 'icons/obj/weapons/khopesh.dmi',
		"state" = "dark_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	var/list/pros = list("Is bad", "Is very bad", "Is extremely bad")
	var/list/cons = list("Smells bad", "Looks bad", "Tastes bad")
	var/list/tips = list("Don't use it", "Don't touch it", "Don't look at it")
	///Used to determine if this is a side path or a main path
	var/abstract_parent_type = /datum/heretic_knowledge_tree_column
	///UI background
	var/ui_bgr = "node_side"

	//-- Knowledge in order of unlocking
	///Starting knowledge - first thing you pick. Gives you access to blades, grasp, mark and passive
	var/start
	///Tier1 knowledge
	var/knowledge_tier1
	///Tier2 knowledge
	var/knowledge_tier2
	///Path-Specific Heretic robes
	var/robes
	///Tier3 knowledge
	var/knowledge_tier3
	///Blade upgrade
	var/blade
	///Tier4 knowledge
	var/knowledge_tier4
	///Ascension
	var/ascension
	// Drafting system, if a path has any side-knowledge that is guaranteed to be one of the options
	/// Knowledge guaranteed to show up in the first draft
	var/guaranteed_side_tier1
	/// Knowledge guaranteed to show up in the second draft
	var/guaranteed_side_tier2
	/// Knowledge guaranteed to show up in the third draft
	var/guaranteed_side_tier3

/proc/generate_heretic_research_tree()
	var/list/heretic_research_tree = list()

	//Initialize the data structure
	for(var/datum/heretic_knowledge/type as anything in subtypesof(/datum/heretic_knowledge))
		heretic_research_tree[type] = list()
		heretic_research_tree[type][HKT_NEXT] = list()
		heretic_research_tree[type][HKT_BAN] = list()
		heretic_research_tree[type][HKT_DEPTH] = 1
		heretic_research_tree[type][HKT_UI_BGR] = "node_side"
		heretic_research_tree[type][HKT_COST] = type::cost

		if(initial(type.is_starting_knowledge))
			heretic_research_tree[type][HKT_ROUTE] = PATH_START
			continue

		heretic_research_tree[type][HKT_ROUTE] = null

	var/list/paths = list()
	for(var/datum/heretic_knowledge_tree_column/column_path as anything in subtypesof(/datum/heretic_knowledge_tree_column))
		if(initial(column_path.abstract_parent_type) == column_path)
			continue

		var/datum/heretic_knowledge_tree_column/column = new column_path()
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

	// If you want to do any custom bullshit put it here \/\/\/
	heretic_research_tree[/datum/heretic_knowledge/reroll_targets][HKT_ROUTE] = PATH_SIDE
	heretic_research_tree[/datum/heretic_knowledge/reroll_targets][HKT_DEPTH] = 8

	heretic_research_tree[/datum/heretic_knowledge/rifle][HKT_NEXT] += /datum/heretic_knowledge/rifle_ammo
	heretic_research_tree[/datum/heretic_knowledge/rifle_ammo][HKT_ROUTE] = PATH_SIDE
	heretic_research_tree[/datum/heretic_knowledge/rifle_ammo][HKT_DEPTH] = heretic_research_tree[/datum/heretic_knowledge/rifle][HKT_DEPTH]

	//and we're done
	QDEL_LIST_ASSOC_VAL(paths)
	return heretic_research_tree

/**
 * Each heretic has a few drafted knowledges within their heretic knowledge tree.
 * This is not during the knowledge tree creation because we want to know what path our heretic picks so we filter out dupe knowledges.
 */
/proc/determine_drafted_knowledge(mob/user, datum/antagonist/heretic/our_heretic, heretic_path)
	var/list/heretic_research_tree = our_heretic.heretic_knowledge_tree

	// Gets our current path
	var/datum/heretic_knowledge_tree_column/current_path
	for(var/datum/heretic_knowledge_tree_column/column_path as anything in subtypesof(/datum/heretic_knowledge_tree_column))
		if(initial(column_path.route) != heretic_path)
			continue
		current_path = new column_path()

	// Relevant variables that we pull from the path
	var/knowledge_tier1 = current_path.knowledge_tier1
	var/knowledge_tier2 = current_path.knowledge_tier2
	var/knowledge_tier3 = current_path.knowledge_tier3
	var/knowledge_tier4 = current_path.knowledge_tier4
	// Every path can have a guaranteed option that will show up in the first 3 drafts (Otherwise we just run as normal)
	var/guaranteed_draft_t1 = current_path.guaranteed_side_tier1
	var/guaranteed_draft_t2 = current_path.guaranteed_side_tier2
	var/guaranteed_draft_t3 = current_path.guaranteed_side_tier3

	var/list/elligible_knowledge = list("1" = list(), "2" = list(), "3" = list(), "4" = list(), "5" = list())
	for(var/datum/heretic_knowledge/potential_knowledge as anything in heretic_research_tree)
		if(potential_knowledge.drafting_tier == 0)
			continue
		// Don't add the knowledge if it's obtainable later in the path
		if(is_path_in_list(potential_knowledge.type, list(knowledge_tier1, knowledge_tier2, knowledge_tier3, knowledge_tier4)))
			continue
		// Don't add the knowledge if it's guaranteed to show up during a specific draft
		if(is_path_in_list(potential_knowledge.type, list(guaranteed_draft_t1, guaranteed_draft_t2, guaranteed_draft_t3)))
			continue
		elligible_knowledge["[potential_knowledge.drafting_tier]"] += potential_knowledge

	// Once we've selected the path, let's let them know what to put in the knowledge shop
	our_heretic.side_knowledges = list()
	for(var/key in elligible_knowledge)
		var/list/copy_list = elligible_knowledge[key]
		our_heretic.side_knowledges += list(copy_list.Copy())

	var/selected_knowledge = null
	var/list/draft_blacklist = list()
	for(var/cycle in 1 to 3)
		while(isnull(selected_knowledge))
			if(guaranteed_draft_t1 && cycle == 1)
				selected_knowledge = guaranteed_draft_t1
			else
				var/chosen_tier = pick_weight(list("1" = 80, "2" = 5, "3" = 5, "4" = 5, "5" = 5))
				selected_knowledge = pick_n_take(elligible_knowledge[chosen_tier])
		heretic_research_tree[knowledge_tier1][HKT_NEXT] += selected_knowledge
		heretic_research_tree[selected_knowledge][HKT_NEXT] = list()
		heretic_research_tree[selected_knowledge][HKT_ROUTE] = heretic_path
		heretic_research_tree[selected_knowledge][HKT_DEPTH] = 4
		heretic_research_tree[selected_knowledge][HKT_UI_BGR] = current_path.ui_bgr
		heretic_research_tree[selected_knowledge][HKT_COST] = 0
		draft_blacklist += selected_knowledge
		selected_knowledge = null
	for(var/blacklist as anything in draft_blacklist)
		heretic_research_tree[blacklist][HKT_BAN] += (draft_blacklist - blacklist)

	draft_blacklist = list()
	for(var/cycle in 1 to 3)
		while(isnull(selected_knowledge))
			if(guaranteed_draft_t2 && cycle == 1)
				selected_knowledge = guaranteed_draft_t2
			else
				var/chosen_tier = pick_weight(list("1" = 80, "2" = 5, "3" = 5, "4" = 5, "5" = 5))
				selected_knowledge = pick_n_take(elligible_knowledge[chosen_tier])
		heretic_research_tree[knowledge_tier2][HKT_NEXT] += selected_knowledge
		heretic_research_tree[selected_knowledge][HKT_NEXT] = list()
		heretic_research_tree[selected_knowledge][HKT_ROUTE] = heretic_path
		heretic_research_tree[selected_knowledge][HKT_DEPTH] = 6
		heretic_research_tree[selected_knowledge][HKT_UI_BGR] = current_path.ui_bgr
		heretic_research_tree[selected_knowledge][HKT_COST] = 0
		draft_blacklist += selected_knowledge
		selected_knowledge = null
	for(var/blacklist as anything in draft_blacklist)
		heretic_research_tree[blacklist][HKT_BAN] += (draft_blacklist - blacklist)

	draft_blacklist = list()
	for(var/cycle in 1 to 3)
		while(isnull(selected_knowledge))
			if(guaranteed_draft_t3 && cycle == 1)
				selected_knowledge = guaranteed_draft_t3
			else
				var/chosen_tier = pick_weight(list("1" = 80, "2" = 5, "3" = 5, "4" = 5, "5" = 5))
				selected_knowledge = pick_n_take(elligible_knowledge[chosen_tier])
		heretic_research_tree[knowledge_tier3][HKT_NEXT] += selected_knowledge
		heretic_research_tree[selected_knowledge][HKT_NEXT] = list()
		heretic_research_tree[selected_knowledge][HKT_ROUTE] = heretic_path
		heretic_research_tree[selected_knowledge][HKT_DEPTH] = 9
		heretic_research_tree[selected_knowledge][HKT_UI_BGR] = current_path.ui_bgr
		heretic_research_tree[selected_knowledge][HKT_COST] = 0
		draft_blacklist += selected_knowledge
		selected_knowledge = null
	for(var/blacklist as anything in draft_blacklist)
		heretic_research_tree[blacklist][HKT_BAN] += (draft_blacklist - blacklist)

	draft_blacklist = list()
	for(var/cycle in 1 to 3)
		while(isnull(selected_knowledge))
			var/chosen_tier = pick_weight(list("1" = 10, "2" = 10, "3" = 10, "4" = 10, "5" = 60))
			selected_knowledge = pick_n_take(elligible_knowledge[chosen_tier])
		heretic_research_tree[knowledge_tier4][HKT_NEXT] += selected_knowledge
		heretic_research_tree[selected_knowledge][HKT_NEXT] = list()
		heretic_research_tree[selected_knowledge][HKT_ROUTE] = heretic_path
		heretic_research_tree[selected_knowledge][HKT_DEPTH] = 12
		heretic_research_tree[selected_knowledge][HKT_UI_BGR] = current_path.ui_bgr
		heretic_research_tree[selected_knowledge][HKT_COST] = 0
		draft_blacklist += selected_knowledge
		selected_knowledge = null
	for(var/blacklist as anything in draft_blacklist)
		heretic_research_tree[blacklist][HKT_BAN] += (draft_blacklist - blacklist)

	// Snowflake handling
	heretic_research_tree[/datum/heretic_knowledge/rifle][HKT_NEXT] += /datum/heretic_knowledge/rifle_ammo
	heretic_research_tree[/datum/heretic_knowledge/rifle_ammo][HKT_ROUTE] = heretic_path
	heretic_research_tree[/datum/heretic_knowledge/rifle_ammo][HKT_DEPTH] = heretic_research_tree[/datum/heretic_knowledge/rifle][HKT_DEPTH]
	heretic_research_tree[/datum/heretic_knowledge/rifle_ammo][HKT_UI_BGR] = current_path.ui_bgr

	qdel(current_path)
