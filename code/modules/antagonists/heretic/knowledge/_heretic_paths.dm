//Global typecache of all heretic knowledges -> instantiate the tree columns -> make them link themselves -> replace the old heretic stuff

//heretic research tree is a directional graph so we can use some basic graph stuff to make internally handling it easier
GLOBAL_LIST(heretic_research_tree)

//HKT = Heretic Knowledge Tree (Heretic Research Tree :3) these objects really only exist for a short period of time at startup and then get deleted
/datum/heretic_knowledge_tree_column
	///Route that symbolizes what path this is
	var/route
	var/icon_state = "dark_blade"
	/*
	 * Complexity grades:
	 * Easy = COLOR_GREEN
	 * Medium = COLOR_YELLOW
	 * Hard = COLOR_RED
	*/
	var/complexity = "Insane"
	var/complexity_color = "#FFFFFF"
	var/list/icon = list(
		"icon" = 'icons/obj/weapons/khopesh.dmi',
		"state" = "dark_blade",
		"frame" = 1,
		"dir" = SOUTH,
		"moving" = FALSE,
	)
	var/list/description = list("A heretic knowledge tree column, used to define a path of knowledge.")
	var/list/pros = list("Is bad", "Is very bad", "Is extremely bad")
	var/list/cons = list("Smells bad", "Looks bad", "Tastes bad")
	var/list/tips = list("Don't use it", "Don't touch it", "Don't look at it")
	///Used to determine if this is a side path or a main path
	var/abstract_parent_type = /datum/heretic_knowledge_tree_column
	///UI background
	var/ui_bgr = BGR_SIDE

	//-- Knowledge in order of unlocking
	///Starting knowledge - first thing you pick. Gives you access to blades, grasp, mark and passive
	var/datum/heretic_knowledge/limited_amount/starting/start
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


/datum/heretic_knowledge_tree_column/proc/get_ui_data(datum/antagonist/heretic/our_heretic, list/power_info)
	var/list/data = list(
		"route" = route,
		"icon" = icon.Copy(),
		"complexity" = complexity,
		"complexity_color" = complexity_color,
		"description" = description.Copy(),
		"pros" = pros.Copy(),
		"cons" = cons.Copy(),
		"tips" = tips.Copy(),
		"starting_knowledge" = our_heretic.get_knowledge_data(start, power_info),
	)

	data["preview_abilities"] = list(
		our_heretic.get_knowledge_data(knowledge_tier1, power_info),
		our_heretic.get_knowledge_data(knowledge_tier2, power_info),
		our_heretic.get_knowledge_data(knowledge_tier3, power_info),
		our_heretic.get_knowledge_data(knowledge_tier4, power_info),
	)

	var/datum/status_effect/heretic_passive/passive = new start.eldritch_passive()
	data["passive"] = list(
		"name" = initial(passive.name),
		"description" = passive.passive_descriptions.Copy(),
	)
	qdel(passive)

	return data

/proc/generate_heretic_research_tree(datum/antagonist/heretic/our_heretic)
	var/list/heretic_research_tree = list()
	//Initialize the data structure
	var/list/tree_paths = list()
	for(var/datum/heretic_knowledge/knowledge as anything in subtypesof(/datum/heretic_knowledge))
		if(!knowledge::is_starting_knowledge)
			continue
		tree_paths += knowledge

	for(var/datum/heretic_knowledge_tree_column/column_path as anything in subtypesof(/datum/heretic_knowledge_tree_column))
		if(initial(column_path.abstract_parent_type) == column_path)
			continue
		tree_paths += list(
			column_path::knowledge_tier1,
			column_path::knowledge_tier2,
			column_path::knowledge_tier3,
			column_path::knowledge_tier4,
			column_path::start,
			column_path::robes,
			column_path::blade,
			column_path::ascension,
		)

	for(var/datum/heretic_knowledge/type as anything in tree_paths)
		heretic_research_tree[type] = list(
			HKT_NEXT = list(),
			HKT_BAN = list(),
			HKT_DEPTH = 1,
			HKT_UI_BGR = BGR_SIDE,
			HKT_COST = type::cost,
			HKT_ROUTE = null
		)


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
		our_heretic.heretic_shops[HERETIC_KNOWLEDGE_START] += main_column.start
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
	// heretic_research_tree[/datum/heretic_knowledge/reroll_targets][HKT_ROUTE] = PATH_SIDE
	// heretic_research_tree[/datum/heretic_knowledge/reroll_targets][HKT_DEPTH] = 8

	// heretic_research_tree[/datum/heretic_knowledge/rifle][HKT_NEXT] += /datum/heretic_knowledge/rifle_ammo
	// heretic_research_tree[/datum/heretic_knowledge/rifle_ammo][HKT_ROUTE] = PATH_SIDE
	// heretic_research_tree[/datum/heretic_knowledge/rifle_ammo][HKT_DEPTH] = heretic_research_tree[/datum/heretic_knowledge/rifle][HKT_DEPTH]

	//and we're done
	QDEL_LIST_ASSOC_VAL(paths)
	return heretic_research_tree

/**
 * Each heretic has a few drafted knowledges within their heretic knowledge tree.
 * This is not during the knowledge tree creation because we want to know what path our heretic picks so we filter out dupe knowledges.
 */
/proc/determine_drafted_knowledge(mob/user, datum/antagonist/heretic/our_heretic, heretic_path)
	var/list/heretic_research_tree = our_heretic.heretic_shops[HERETIC_KNOWLEDGE_TREE]
	var/list/shop = our_heretic.heretic_shops[HERETIC_KNOWLEDGE_SHOP]
	var/list/final_draft = our_heretic.heretic_shops[HERETIC_KNOWLEDGE_DRAFT]

	/// costs by index mapped to depth
	var/list/shop_costs = list(1, 2, 2, 2, 3)

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


	var/list/path_knowledges = list(
		knowledge_tier1,
		knowledge_tier2,
		knowledge_tier3,
		knowledge_tier4
	)

	// Every path can have a guaranteed option that will show up in the first 3 drafts (Otherwise we just run as normal)
	var/datum/heretic_knowledge/guaranteed_draft_t1 = current_path.guaranteed_side_tier1
	var/datum/heretic_knowledge/guaranteed_draft_t2 = current_path.guaranteed_side_tier2
	var/datum/heretic_knowledge/guaranteed_draft_t3 = current_path.guaranteed_side_tier3

	var/list/guaranteed_drafts = list(
		guaranteed_draft_t1,
		guaranteed_draft_t2,
		guaranteed_draft_t3
	)

	var/list/draft_ineligible = path_knowledges.Copy()
	draft_ineligible += guaranteed_drafts

	var/list/elligible_knowledge = list()
	for(var/tier in 1 to HERETIC_DRAFT_TIER_MAX)
		elligible_knowledge += list(list())

	for(var/datum/heretic_knowledge/potential_type as anything in subtypesof(/datum/heretic_knowledge))
		if(potential_type::drafting_tier == 0)
			continue
		// Don't add the knowledge if it's obtainable later in the path
		if(is_path_in_list(potential_type, draft_ineligible))
			continue
		elligible_knowledge[potential_type::drafting_tier] += potential_type

	for(var/drafting_tier in 1 to length(elligible_knowledge))
		var/list/eligible_tier = elligible_knowledge[drafting_tier]
		for(var/knowledge_type in eligible_tier)
			shop[knowledge_type] = list(
				HKT_NEXT = list(),
				HKT_BAN = list(),
				HKT_ROUTE = heretic_path,
				HKT_DEPTH = drafting_tier,
				HKT_UI_BGR = BGR_SIDE,
				HKT_COST = shop_costs[drafting_tier],
				// HKT_CATEGORY = HERETIC_KNOWLEDGE_DRAFT
			)
			var/unlocked_by
			if(drafting_tier > 1)
				unlocked_by = path_knowledges[drafting_tier]
			else
				unlocked_by = current_path.start
			heretic_research_tree[unlocked_by][HKT_NEXT] += knowledge_type

	// for(var/knowledge_path in guaranteed_drafts)
	// 	shop[knowledge_path] = list(
	// 		HKT_NEXT = list(),
	// 		HKT_BAN = list(),
	// 		HKT_ROUTE = heretic_path,
	// 		HKT_DEPTH = 0,
	// 		HKT_UI_BGR = BGR_SIDE,
	// 		HKT_COST = 0,
	// 		// HKT_CATEGORY = HERETIC_KNOWLEDGE_DRAFT
	// 	)
	// 	var/unlocked_by
	// 	if(drafting_tier > 1)
	// 		unlocked_by = path_knowledges[drafting_tier - 1]
	// 	else
	// 		unlocked_by = current_path.start
	// 	heretic_research_tree[unlocked_by][HKT_NEXT] += knowledge_path


	// Snowflake handling
	var/datum/heretic_knowledge/gun_path = /datum/heretic_knowledge/rifle
	var/datum/heretic_knowledge/ammo_path = /datum/heretic_knowledge/rifle_ammo
	//TODO proc for generating knowledge data
	shop[gun_path] = list(
		HKT_NEXT = list(ammo_path),
		HKT_BAN = list(),
		HKT_COST = initial(gun_path.cost),
		HKT_ROUTE = PATH_SIDE,
		HKT_UI_BGR = BGR_SIDE,
		HKT_DEPTH = 8,
	)
	// shop[gun_path][HKT_CATEGORY] = HERETIC_KNOWLEDGE_DRAFT
	shop[ammo_path] = list(
		HKT_NEXT = list(),
		HKT_BAN = list(),
		HKT_COST = initial(ammo_path.cost),
		HKT_ROUTE = PATH_SIDE,
		HKT_UI_BGR = BGR_SIDE,
		HKT_DEPTH = 8,
	)
	// shop[ammo_path][HKT_CATEGORY] = HERETIC_KNOWLEDGE_DRAFT

	var/list/drafts = list(
		list(
			"parent_knowledge" = knowledge_tier1,
			"guaranteed_knowledge" = guaranteed_draft_t1,
			"probabilities" = list("1" = 80, "2" = 5, "3" = 5, "4" = 5, "5" = 5),
			"depth" = 4
		),
		list(
			"parent_knowledge" = knowledge_tier2,
			"guaranteed_knowledge" = guaranteed_draft_t2,
			"probabilities" = list("1" = 80, "2" = 5, "3" = 5, "4" = 5, "5" = 5),
			"depth" = 6
		),
		list(
			"parent_knowledge" = knowledge_tier3,
			"guaranteed_knowledge" = guaranteed_draft_t3,
			"probabilities" = list("1" = 80, "2" = 5, "3" = 5, "4" = 5, "5" = 5),
			"depth" = 9
		),
		list(
			"parent_knowledge" = knowledge_tier4,
			"probabilities" = list("1" = 10, "2" = 10, "3" = 10, "4" = 10, "5" = 60),
			"depth" = 12
		)
	)
	var/index = 0
	for(var/draft in drafts)
		index++
		var/parent_knowledge_path = draft["parent_knowledge"]
		var/guaranteed_draft = draft["guaranteed_knowledge"]
		var/list/probabilities = draft["probabilities"]
		var/depth = draft["depth"]
		var/list/draft_blacklist = list()

		for(var/cycle in 1 to 3)
			var/selected_knowledge
			if(guaranteed_draft && cycle == 1)
				selected_knowledge = guaranteed_draft
			else
				// rng kinda not correct but like, whatever
				var/chosen_tier = min(text2num(pick_weight(probabilities)), length(elligible_knowledge))
				var/list/picked_tier = elligible_knowledge[chosen_tier]
				selected_knowledge = pick_n_take(picked_tier)

				if(!length(picked_tier))
					elligible_knowledge.Cut(chosen_tier, chosen_tier + 1)

			if(isnull(selected_knowledge))
				stack_trace("Failed to select a knowledge for heretic path [heretic_path] at depth [depth]. This should never happen.")
				continue

			heretic_research_tree[parent_knowledge_path][HKT_NEXT] += selected_knowledge

			final_draft[selected_knowledge] = list(
				HKT_NEXT = list(path_knowledges[index]),
				HKT_ROUTE = heretic_path,
				HKT_DEPTH = depth,
				HKT_UI_BGR = current_path.ui_bgr,
				HKT_COST = 0
			)
			// draft[selected_knowledge][HKT_CATEGORY] = HERETIC_KNOWLEDGE_DRAFT

			draft_blacklist += selected_knowledge

			for(var/blacklist as anything in draft_blacklist)
				final_draft[blacklist][HKT_BAN] += (draft_blacklist - blacklist)
	// Snowflake handling
	// var/gun_path = /datum/heretic_knowledge/rifle
	// var/ammo_path = /datum/heretic_knowledge/rifle_ammo
	// heretic_research_tree[gun_path][HKT_NEXT] += ammo_path
	// heretic_research_tree[ammo_path][HKT_ROUTE] = heretic_path
	// heretic_research_tree[ammo_path][HKT_DEPTH] = heretic_research_tree[gun_path][HKT_DEPTH]
	// heretic_research_tree[ammo_path][HKT_UI_BGR] = current_path.ui_bgr
	// heretic_research_tree[gun_path][HKT_CATEGORY] = HERETIC_KNOWLEDGE_DRAFT
	// heretic_research_tree[ammo_path][HKT_CATEGORY] = HERETIC_KNOWLEDGE_DRAFT

	qdel(current_path)
