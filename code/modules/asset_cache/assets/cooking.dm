// Representative icons for the contents of each cooking recipe
/datum/asset/spritesheet/cooking
	name = "cooking"
	var/list/id_list = list()

/datum/asset/spritesheet/cooking/create_spritesheets()
	for(var/R in GLOB.crafting_recipes)
		var/datum/crafting_recipe/food/recipe = R
		if (!ispath(recipe.type, /datum/crafting_recipe/food/) || !recipe.result)
			continue

		// Result
		add_atom_icon(recipe.result)

		// Ingredients
		for(var/atom/req_atom as anything in recipe.reqs)
			add_atom_icon(req_atom)

		if(recipe.reaction)
			var/datum/chemical_reaction/reaction = GLOB.chemical_reactions_list[recipe.reaction]
			// Reagents
			for(var/atom/req_atom as anything in reaction.required_reagents)
				add_atom_icon(req_atom)
			// Catalysts
			for(var/atom/req_atom as anything in reaction.required_catalysts)
				add_atom_icon(req_atom)

		// Tools
		for(var/atom/req_atom as anything in recipe.tool_paths)
			add_atom_icon(req_atom)

		// Machinery
		for(var/atom/req_atom as anything in recipe.machinery)
			add_atom_icon(req_atom)

/datum/asset/spritesheet/cooking/proc/add_atom_icon(path)
	var/atom/item = initial(path)
	if(ispath(path, /datum/reagent))
		var/datum/reagent/reagent = path
		item = initial(reagent.default_container)

	var/icon_file = initial(item.icon)
	var/icon_state = initial(item.icon_state)
	#ifdef UNIT_TESTS
	if(!(icon_state in icon_states(icon_file)))
		stack_trace("Atom [path] with icon '[icon_file]' missing state '[icon_state]'")
		return
	#endif
	var/icon/I = icon(icon_file, icon_state, SOUTH)
	var/id = sanitize_css_class_name("[path]")
	if(id in id_list) //no dupes
		return
	id_list += id
	Insert(id, I)
