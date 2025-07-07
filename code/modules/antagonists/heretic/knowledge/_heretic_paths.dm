//Global typecache of all heretic knowledges -> instantiate the tree columns -> make them link themselves -> replace the old heretic stuff

//heretic research tree is a directional graph so we can use some basic graph stuff to make internally handling it easier
GLOBAL_LIST(heretic_research_tree)

//HKT = Heretic Knowledge Tree (Heretic Research Tree :3) these objects really only exist for a short period of time at startup and then get deleted
/datum/heretic_knowledge_tree_column
	///Route that symbolizes what path this is
	var/route = PATH_START
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


/datum/heretic_knowledge_tree_column/proc/get_ui_data(datum/antagonist/heretic/our_heretic, category)
	var/list/power_info = our_heretic.heretic_shops[category]
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
		our_heretic.get_knowledge_data(knowledge_tier1, power_info, category = category),
		our_heretic.get_knowledge_data(knowledge_tier2, power_info, category = category),
		our_heretic.get_knowledge_data(knowledge_tier3, power_info, category = category),
		our_heretic.get_knowledge_data(knowledge_tier4, power_info, category = category),
	)

	var/datum/status_effect/heretic_passive/passive = new start.eldritch_passive()
	data["passive"] = list(
		"name" = initial(passive.name),
		"description" = passive.passive_descriptions.Copy(),
	)
	qdel(passive)

	return data

/datum/antagonist/heretic/proc/make_knowledge_entry(datum/heretic_knowledge/knowledge, datum/heretic_knowledge_tree_column/path, depth = 1)
	return list(
		HKT_NEXT = list(),
		HKT_BAN = list(),
		HKT_DEPTH = depth,
		HKT_UI_BGR = path ? path::ui_bgr : BGR_SIDE,
		HKT_COST = knowledge::cost,
		HKT_ROUTE = path ? path::route : null,
	)

/datum/antagonist/heretic/proc/generate_starting_knowledge()
	var/list/starting_knowledge = heretic_shops[HERETIC_KNOWLEDGE_START]
	for(var/knowledge in GLOB.heretic_start_knowledge)
		starting_knowledge[knowledge] = make_knowledge_entry(knowledge, null)

	for(var/datum/heretic_knowledge_tree_column/column_path as anything in subtypesof(/datum/heretic_knowledge_tree_column))
		if(initial(column_path.abstract_parent_type) == column_path)
			continue
		var/start_knowledge = column_path::start
		// why aren't the tiered knowledges in a list?!?!? (initial() probably)
		var/t1_knowledge = column_path::knowledge_tier1
		var/t2_knowledge = column_path::knowledge_tier2
		var/t3_knowledge = column_path::knowledge_tier3
		var/t4_knowledge = column_path::knowledge_tier4
		starting_knowledge[start_knowledge] = make_knowledge_entry(start_knowledge, column_path, 2)
		starting_knowledge[t1_knowledge] = make_knowledge_entry(t1_knowledge, column_path, 3)
		starting_knowledge[t2_knowledge] = make_knowledge_entry(t2_knowledge, column_path, 5)
		starting_knowledge[t3_knowledge] = make_knowledge_entry(t3_knowledge, column_path, 8)
		starting_knowledge[t4_knowledge] = make_knowledge_entry(t4_knowledge, column_path, 11)
		// start the HKT_NEXT chain here
		starting_knowledge[/datum/heretic_knowledge/spell/basic][HKT_NEXT] += list(start_knowledge)
		starting_knowledge[start_knowledge][HKT_NEXT] += column_path.knowledge_tier1

//TODO: use this to generate the globallist
/datum/antagonist/heretic/proc/generate_heretic_research_tree()
	var/list/heretic_research_tree = heretic_shops[HERETIC_KNOWLEDGE_TREE]
	//Initialize the data structure
	var/list/tree_paths = list()

	tree_paths += list(
		heretic_path.knowledge_tier1,
		heretic_path.knowledge_tier2,
		heretic_path.knowledge_tier3,
		heretic_path.knowledge_tier4,
		heretic_path.start,
		heretic_path.robes,
		heretic_path.blade,
		heretic_path.ascension,
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

	//horizontal (two way)
	var/list/knowledge_tier1 = heretic_path.knowledge_tier1
	var/list/knowledge_tier2 = heretic_path.knowledge_tier2
	var/list/knowledge_tier3 = heretic_path.knowledge_tier3
	var/list/knowledge_tier4 = heretic_path.knowledge_tier4

	//Tier1, 2 and 3 can technically be lists so we handle them here
	if(!islist(heretic_path.knowledge_tier1))
		knowledge_tier1 = list(heretic_path.knowledge_tier1)

	if(!islist(heretic_path.knowledge_tier2))
		knowledge_tier2 = list(heretic_path.knowledge_tier2)

	if(!islist(heretic_path.knowledge_tier3))
		knowledge_tier3 = list(heretic_path.knowledge_tier3)

	if(!islist(heretic_path.knowledge_tier4))
		knowledge_tier4 = list(heretic_path.knowledge_tier4)

	for(var/t1_knowledge in knowledge_tier1)
		heretic_research_tree[t1_knowledge][HKT_ROUTE] = heretic_path.route
		heretic_research_tree[t1_knowledge][HKT_UI_BGR] = heretic_path.ui_bgr
		heretic_research_tree[t1_knowledge][HKT_DEPTH] = 3

	for(var/t2_knowledge in knowledge_tier2)
		heretic_research_tree[t2_knowledge][HKT_ROUTE] = heretic_path.route
		heretic_research_tree[t2_knowledge][HKT_UI_BGR] = heretic_path.ui_bgr
		heretic_research_tree[t2_knowledge][HKT_DEPTH] = 5

	for(var/t3_knowledge in knowledge_tier3)
		heretic_research_tree[t3_knowledge][HKT_ROUTE] = heretic_path.route
		heretic_research_tree[t3_knowledge][HKT_UI_BGR] = heretic_path.ui_bgr
		heretic_research_tree[t3_knowledge][HKT_DEPTH] = 8

	for(var/t4_knowledge in knowledge_tier4)
		heretic_research_tree[t4_knowledge][HKT_ROUTE] = heretic_path.route
		heretic_research_tree[t4_knowledge][HKT_UI_BGR] = heretic_path.ui_bgr
		heretic_research_tree[t4_knowledge][HKT_DEPTH] = 11

	//vertical (one way)

	//t1 handling
	for(var/t1_knowledge in knowledge_tier1)
		heretic_research_tree[t1_knowledge][HKT_NEXT] += heretic_path.knowledge_tier2
	//t2 handling
	for(var/t2_knowledge in knowledge_tier2)
		heretic_research_tree[t2_knowledge][HKT_NEXT] += heretic_path.robes

	// Robes upgrade gives us access to T3
	heretic_research_tree[heretic_path.robes][HKT_NEXT] += heretic_path.knowledge_tier3

	//t3 handling
	for(var/t3_knowledge in knowledge_tier3)
		heretic_research_tree[t3_knowledge][HKT_NEXT] += heretic_path.blade

	// Blade upgrade gives us access to T4
	heretic_research_tree[heretic_path.blade][HKT_NEXT] += heretic_path.knowledge_tier4

	//t4 handling
	for(var/t4_knowledge in knowledge_tier4)
		heretic_research_tree[t4_knowledge][HKT_NEXT] += heretic_path.ascension

	//route stuff
	heretic_research_tree[heretic_path.robes][HKT_ROUTE] = heretic_path.route
	heretic_research_tree[heretic_path.blade][HKT_ROUTE] = heretic_path.route
	heretic_research_tree[heretic_path.ascension][HKT_ROUTE] = heretic_path.route

	heretic_research_tree[heretic_path.start][HKT_UI_BGR] = heretic_path.ui_bgr
	heretic_research_tree[heretic_path.robes][HKT_UI_BGR] = heretic_path.ui_bgr
	heretic_research_tree[heretic_path.blade][HKT_UI_BGR] = heretic_path.ui_bgr
	heretic_research_tree[heretic_path.ascension][HKT_UI_BGR] = heretic_path.ui_bgr
	//depth stuff
	heretic_research_tree[heretic_path.start][HKT_DEPTH] = 2
	heretic_research_tree[heretic_path.robes][HKT_DEPTH] = 7
	heretic_research_tree[heretic_path.blade][HKT_DEPTH] = 10
	heretic_research_tree[heretic_path.ascension][HKT_DEPTH] = 13

	//Per path bullshit goes here \/\/\/
	for(var/t3_knowledge in knowledge_tier3)
		heretic_research_tree[t3_knowledge][HKT_NEXT] += /datum/heretic_knowledge/reroll_targets

	//and we're done
	return heretic_research_tree

/**
 * Each heretic has a few drafted knowledges within their heretic knowledge tree.
 * This is not during the knowledge tree creation because we want to know what path our heretic picks so we filter out dupe knowledges.
 */
/datum/antagonist/heretic/proc/determine_drafted_knowledge(mob/user)
	var/list/heretic_research_tree = heretic_shops[HERETIC_KNOWLEDGE_TREE]
	var/list/shop = heretic_shops[HERETIC_KNOWLEDGE_SHOP]
	var/list/final_draft = heretic_shops[HERETIC_KNOWLEDGE_DRAFT]

	/// costs by index mapped to depth
	var/list/shop_costs = list(1, 2, 2, 2, 3)

	// Relevant variables that we pull from the path
	var/knowledge_tier1 = heretic_path.knowledge_tier1
	var/knowledge_tier2 = heretic_path.knowledge_tier2
	var/knowledge_tier3 = heretic_path.knowledge_tier3
	var/knowledge_tier4 = heretic_path.knowledge_tier4


	var/list/path_knowledges = list(
		knowledge_tier1,
		knowledge_tier2,
		knowledge_tier3,
		knowledge_tier4
	)

	// Every path can have a guaranteed option that will show up in the first 3 drafts (Otherwise we just run as normal)
	var/datum/heretic_knowledge/guaranteed_draft_t1 = heretic_path.guaranteed_side_tier1
	var/datum/heretic_knowledge/guaranteed_draft_t2 = heretic_path.guaranteed_side_tier2
	var/datum/heretic_knowledge/guaranteed_draft_t3 = heretic_path.guaranteed_side_tier3

	var/list/guaranteed_drafts = list(
		guaranteed_draft_t1,
		guaranteed_draft_t2,
		guaranteed_draft_t3
	)

	// // todo put this somewhere more shared
	// var/list/shop_unlock_order = list(
	// 	knowledge_tier1,
	// 	knowledge_tier2,
	// 	heretic_path.robes,
	// 	knowledge_tier3,
	// 	knowledge_tier4
	// )

	var/list/draft_ineligible = path_knowledges.Copy()
	draft_ineligible += guaranteed_drafts

	var/list/elligible_knowledge = list()
	var/list/shop_knowledge = list()
	for(var/tier in 1 to HERETIC_DRAFT_TIER_MAX)
		elligible_knowledge += list(list())
		shop_knowledge += list(list())

	for(var/datum/heretic_knowledge/potential_type as anything in subtypesof(/datum/heretic_knowledge))
		if(potential_type::drafting_tier == 0)
			continue
		// Don't add the knowledge if it's obtainable later in the path
		if(is_path_in_list(potential_type, draft_ineligible))
			continue
		elligible_knowledge[potential_type::drafting_tier] += potential_type
		shop_knowledge[potential_type::drafting_tier] += potential_type

	var/list/drafts = list(
		list(
			"parent_knowledge" = knowledge_tier1,
			"guaranteed_knowledge" = guaranteed_draft_t1,
			"probabilities" = list("1" = 80, "2" = 5, "3" = 5, "4" = 5, "5" = 5),
			HKT_DEPTH = 4
		),
		list(
			"parent_knowledge" = knowledge_tier2,
			"guaranteed_knowledge" = guaranteed_draft_t2,
			"probabilities" = list("1" = 80, "2" = 5, "3" = 5, "4" = 5, "5" = 5),
			HKT_DEPTH = 6
		),
		list(
			"parent_knowledge" = knowledge_tier3,
			"guaranteed_knowledge" = guaranteed_draft_t3,
			"probabilities" = list("1" = 80, "2" = 5, "3" = 5, "4" = 5, "5" = 5),
			HKT_DEPTH = 9
		),
		list(
			"parent_knowledge" = knowledge_tier4,
			"probabilities" = list("1" = 10, "2" = 10, "3" = 10, "4" = 10, "5" = 60),
			HKT_DEPTH = 12
		)
	)
	// todo GLOB this
	var/list/draft_nums = list(4, 6, 9, 12)
	for(var/draft in drafts)
		var/parent_knowledge_path = draft["parent_knowledge"]
		var/datum/heretic_knowledge/guaranteed_draft = draft["guaranteed_knowledge"]
		var/list/probabilities = draft["probabilities"]
		var/depth = draft[HKT_DEPTH]
		// var/list/draft_blacklist = list()

		for(var/cycle in 1 to 3)
			var/selected_knowledge
			if(guaranteed_draft && cycle == 1)
				selected_knowledge = guaranteed_draft
				var/shop_tier = shop_knowledge[guaranteed_draft::drafting_tier]
				if(shop_tier && !(guaranteed_draft in shop_tier))
					shop_tier += guaranteed_draft
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
				HKT_NEXT = list(),
				HKT_ROUTE = heretic_path.route,
				HKT_DEPTH = depth,
				HKT_UI_BGR = heretic_path.ui_bgr,
				HKT_COST = 0
			)

	for(var/drafting_tier in 1 to length(shop_knowledge))
		var/list/eligible_tier = shop_knowledge[drafting_tier]
		for(var/knowledge_type in eligible_tier)
			shop[knowledge_type] = list(
				HKT_NEXT = list(),
				HKT_BAN = list(),
				HKT_ROUTE = heretic_path.route,
				HKT_DEPTH = drafting_tier,
				HKT_UI_BGR = BGR_SIDE,
				HKT_COST = shop_costs[drafting_tier],
			)

			var/our_depth = shop[knowledge_type][HKT_DEPTH]
			for(var/datum/heretic_knowledge/draft_type as anything in final_draft)
				var/list/knowledge_info = final_draft[draft_type]
				var/target_depth = draft_nums[min(our_depth, length(draft_nums))]
				if(knowledge_info[HKT_DEPTH] != target_depth)
					continue
				final_draft[draft_type][HKT_NEXT] |= knowledge_type

	var/reroll = /datum/heretic_knowledge/reroll_targets
	shop[reroll] = make_knowledge_entry(reroll, heretic_path, 3)

	var/gun_path = /datum/heretic_knowledge/rifle
	var/ammo_path = /datum/heretic_knowledge/rifle_ammo
	shop[gun_path] = make_knowledge_entry(gun_path, heretic_path, 4)
	shop[gun_path][HKT_NEXT] += ammo_path

	var/already_in = final_draft[gun_path]
	if(already_in)
		already_in[HKT_NEXT] += ammo_path

	shop[ammo_path] = make_knowledge_entry(ammo_path, heretic_path, 4)

