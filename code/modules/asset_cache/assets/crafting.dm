///Representative icons for the contents of each crafting recipe
/datum/asset/spritesheet_batched/crafting
	name = "crafting"

/datum/asset/spritesheet_batched/crafting/create_spritesheets()
	var/id = 1
	for(var/datum in GLOB.crafting_recipes_datums)
		add_atom_icon(datum, id++)
	add_tool_icons()

/datum/asset/spritesheet_batched/crafting/cooking
	name = "cooking"

/datum/asset/spritesheet_batched/crafting/cooking/create_spritesheets()
	var/id = 1
	for(var/datum in GLOB.cooking_recipes_datums)
		add_atom_icon(datum, id++)

/**
 * Adds the ingredient icon to the spritesheet with given ID
 *
 * ingredient_typepath can be an obj typepath OR a reagent typepath
 *
 * If it a reagent, it will use the default container's icon state,
 * OR if it has a glass style associated, it will use that
 */
/datum/asset/spritesheet_batched/crafting/proc/add_atom_icon(ingredient_typepath, id)
	var/icon_file
	var/icon_state
	var/obj/preview_item = ingredient_typepath
	if(ispath(ingredient_typepath, /datum/reagent))
		var/datum/reagent/reagent = ingredient_typepath
		preview_item = initial(reagent.default_container)
		var/datum/glass_style/style = GLOB.glass_style_singletons[preview_item]?[reagent]
		if(istype(style))
			icon_file = style.icon
			icon_state = style.icon_state
	// Hardcoded for now, I suppose. Revisit later with bespoke "generic" icons for abstract types i.e. if(ingredient_typepath == ingredient_typepath::abstract_type) ?
	else if(ingredient_typepath == /obj/item/food || ingredient_typepath == /obj/item/food/grown || ingredient_typepath == /obj/item/grown)
		icon_file = 'icons/effects/random_spawners.dmi'
		icon_state = "questionmark"

	icon_file ||= preview_item::icon_preview || preview_item::icon
	icon_state ||= preview_item::icon_state_preview || preview_item::icon_state

	if(PERFORM_ALL_TESTS(focus_only/bad_cooking_crafting_icons))
		if(!icon_exists_or_scream(icon_file, icon_state))
			return

	insert_icon("a[id]", uni_icon(icon_file, icon_state, SOUTH))

///Adds tool icons to the spritesheet
/datum/asset/spritesheet_batched/crafting/proc/add_tool_icons()
	var/list/tool_icons = list(
		TOOL_CROWBAR = uni_icon('icons/obj/tools.dmi', "crowbar"),
		TOOL_MULTITOOL = uni_icon('icons/obj/devices/tool.dmi', "multitool"),
		TOOL_SCREWDRIVER = uni_icon('icons/map_icons/items/_item.dmi', "/obj/item/screwdriver"),
		TOOL_WIRECUTTER = uni_icon('icons/obj/tools.dmi', "cutters_map"),
		TOOL_WRENCH = uni_icon('icons/obj/tools.dmi', "wrench"),
		TOOL_WELDER = uni_icon('icons/obj/tools.dmi', "welder"),
		TOOL_ANALYZER = uni_icon('icons/obj/devices/scanner.dmi', "analyzer"),
		TOOL_MINING = uni_icon('icons/obj/mining.dmi', "minipick"),
		TOOL_SHOVEL = uni_icon('icons/obj/mining.dmi', "spade"),
		TOOL_RETRACTOR = uni_icon('icons/obj/medical/surgery_tools.dmi', "retractor"),
		TOOL_HEMOSTAT = uni_icon('icons/obj/medical/surgery_tools.dmi', "hemostat"),
		TOOL_CAUTERY = uni_icon('icons/obj/medical/surgery_tools.dmi', "cautery"),
		TOOL_DRILL = uni_icon('icons/obj/medical/surgery_tools.dmi', "drill"),
		TOOL_SCALPEL = uni_icon('icons/obj/medical/surgery_tools.dmi', "scalpel"),
		TOOL_SAW = uni_icon('icons/obj/medical/surgery_tools.dmi', "saw"),
		TOOL_BONESET = uni_icon('icons/obj/medical/surgery_tools.dmi', "bonesetter"),
		TOOL_KNIFE = uni_icon('icons/obj/service/kitchen.dmi', "knife"),
		TOOL_BLOODFILTER = uni_icon('icons/obj/medical/surgery_tools.dmi', "bloodfilter"),
		TOOL_ROLLINGPIN = uni_icon('icons/obj/service/kitchen.dmi', "rolling_pin"),
		TOOL_RUSTSCRAPER = uni_icon('icons/obj/tools.dmi', "wirebrush"),
	)

	for(var/tool in tool_icons)
		insert_icon(replacetext(tool, " ", ""), tool_icons[tool])

/datum/asset/json/crafting_recipes
	name = "crafting_list"

/datum/asset/json/crafting_recipes/generate()
	var/list/data = list()
	var/list/components = get_component_list()
	var/list/recipes = get_recipe_list()
	var/datum/asset/spritesheet_batched/crafting/sheet = get_corresponding_icon_sheet()

	data["categories"] = list()
	data["recipes"] = list()
	data["icon_data"] = list()
	data["atom_data"] = list()

	for(var/datum/crafting_recipe/recipe as anything in recipes)
		if(recipe.category)
			data["categories"] |= recipe.category
		data["recipes"] += list(build_crafting_data(recipe, components))

	for(var/datum/atom as anything in components)
		var/atom_name = ""
		if(ispath(atom, /atom))
			// future todo: some atoms have intentionally misleading names,
			// and while their crafting recipe reveals their true nature,
			// the displayed name here does not
			var/atom/atom_path = atom
			atom_name = atom_path::name

		else if(ispath(atom, /datum/reagent))
			var/datum/reagent/reagent_path = atom
			atom_name = reagent_path::name

		data["atom_data"] += list(list(
			"name" = atom_name,
			"is_reagent" = ispath(atom, /datum/reagent),
		))

		var/craft_id = CRAFTING_COMPONENT_ID(components, atom)
		var/icon_size = sheet.icon_size_id("a[craft_id]")
		if(!endswith(icon_size, "32x32"))
			data["icon_data"][craft_id] = "[icon_size] a[craft_id]"

	return data

/datum/asset/json/crafting_recipes/proc/get_recipe_list()
	return GLOB.crafting_recipes

/datum/asset/json/crafting_recipes/proc/get_component_list()
	return GLOB.crafting_recipes_datums

/datum/asset/json/crafting_recipes/proc/get_corresponding_icon_sheet()
	return get_asset_datum(/datum/asset/spritesheet_batched/crafting)

/datum/asset/json/crafting_recipes/proc/build_crafting_data(datum/crafting_recipe/recipe, list/datums)
	var/list/data = list()

	data["ref"] = REF(recipe)
	var/atom/atom = recipe.result

	data["id"] = CRAFTING_COMPONENT_ID(datums, atom)

	var/recipe_data = recipe.crafting_ui_data()
	for(var/new_data in recipe_data)
		data[new_data] = recipe_data[new_data]

	// Category
	data["category"] = recipe.category

	// Name, Description
	data["name"] = recipe.name

	if(ispath(recipe.result, /datum/reagent))
		var/datum/reagent/reagent = recipe.result
		if(recipe.result_amount > 1)
			data["name"] = "[data["name"]] [recipe.result_amount]u"
		data["desc"] = recipe.desc || initial(reagent.description)

	else if(ispath(recipe.result, /obj/item/pipe))
		var/obj/item/pipe/pipe_obj = recipe.result
		var/obj/pipe_real = initial(pipe_obj.pipe_type)
		data["desc"] = recipe.desc || initial(pipe_real.desc)

	else
		if(ispath(recipe.result, /obj/item/stack) && recipe.result_amount > 1)
			data["name"] = "[data["name"]] [recipe.result_amount]x"
		data["desc"] = recipe.desc || initial(atom.desc)

	if(ispath(recipe.result, /obj/item/food))
		var/obj/item/food/food = recipe.result
		data["has_food_effect"] = !!food.crafted_food_buff

	// Crafting
	if(recipe.non_craftable)
		data["non_craftable"] = recipe.non_craftable
	data["mass_craftable"] = recipe.mass_craftable
	if(recipe.steps)
		data["steps"] = recipe.steps

	// Tools
	if(recipe.tool_behaviors)
		data["tool_behaviors"] = recipe.tool_behaviors
	if(recipe.tool_paths)
		data["tool_paths"] = list()
		for(var/req_atom in recipe.tool_paths)
			data["tool_paths"] += CRAFTING_COMPONENT_ID(datums, req_atom)

	// Machinery
	if(recipe.machinery)
		data["machinery"] = list()
		for(var/req_atom in recipe.machinery)
			data["machinery"] += CRAFTING_COMPONENT_ID(datums, req_atom)

	// Structures
	if(recipe.structures)
		data["structures"] = list()
		for(var/req_atom in recipe.structures)
			data["structures"] += CRAFTING_COMPONENT_ID(datums, req_atom)

	// Ingredients / Materials
	data["reqs"] = list()
	if(recipe.reqs.len)
		for(var/req_atom in recipe.reqs)
			data["reqs"][CRAFTING_COMPONENT_ID(datums, req_atom)] = recipe.reqs[req_atom]

	// Catalysts
	if(LAZYLEN(recipe.chem_catalysts))
		data["chem_catalysts"] = list()
		for(var/req_atom, chem_amount in recipe.chem_catalysts)
			data["chem_catalysts"][CRAFTING_COMPONENT_ID(datums, req_atom)] = chem_amount

	// Reaction data
	if(ispath(recipe.reaction))
		data["is_reaction"] = TRUE
		// May be called before chemical reactions list is setup
		var/datum/chemical_reaction/reaction = GLOB.chemical_reactions_list[recipe.reaction] || new recipe.reaction()
		if(istype(reaction))
			if(!data["steps"])
				data["steps"] = list()
			if(reaction.required_container)
				data["reqs"][CRAFTING_COMPONENT_ID(datums, reaction.required_container)] = 1
				data["steps"] += "Add all ingredients into \a [initial(reaction.required_container.name)]"
			else if(length(recipe.reqs) > 1 || length(reaction.required_catalysts))
				data["steps"] += "Mix all ingredients together"
			if(reaction.required_temp > T20C)
				data["steps"] += "Heat up to [reaction.required_temp]K"
		else
			stack_trace("Invalid reaction found in recipe code! ([recipe.reaction])")
	else if(!isnull(recipe.reaction))
		stack_trace("Invalid reaction found in recipe code! ([recipe.reaction])")

	return data

/datum/asset/json/crafting_recipes/cooking
	name = "cooking_list"

/datum/asset/json/crafting_recipes/cooking/get_recipe_list()
	return GLOB.cooking_recipes

/datum/asset/json/crafting_recipes/cooking/get_component_list()
	return GLOB.cooking_recipes_datums

/datum/asset/json/crafting_recipes/cooking/get_corresponding_icon_sheet()
	return get_asset_datum(/datum/asset/spritesheet_batched/crafting)
