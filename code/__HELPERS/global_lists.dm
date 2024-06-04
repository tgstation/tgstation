//////////////////////////
/////Initial Building/////
//////////////////////////

/// Inits GLOB.surgeries
/proc/init_surgeries()
	var/surgeries = list()
	for(var/path in subtypesof(/datum/surgery))
		surgeries += new path()
	sort_list(surgeries, GLOBAL_PROC_REF(cmp_typepaths_asc))
	return surgeries

/// Legacy procs that really should be replaced with proper _INIT macros
/proc/make_datum_reference_lists()
	// I tried to eliminate this proc but I couldn't untangle their init-order interdependencies -Dominion/Cyberboss
	init_keybindings()
	GLOB.emote_list = init_emote_list() // WHY DOES THIS NEED TO GO HERE? IT JUST INITS DATUMS
	init_crafting_recipes()
	init_crafting_recipes_atoms()

/// Inits crafting recipe lists
/proc/init_crafting_recipes(list/crafting_recipes)
	for(var/path in subtypesof(/datum/crafting_recipe))
		if(ispath(path, /datum/crafting_recipe/stack))
			continue
		var/datum/crafting_recipe/recipe = new path()
		var/is_cooking = (recipe.category in GLOB.crafting_category_food)
		recipe.reqs = sort_list(recipe.reqs, GLOBAL_PROC_REF(cmp_crafting_req_priority))
		if(recipe.name != "" && recipe.result)
			if(is_cooking)
				GLOB.cooking_recipes += recipe
			else
				GLOB.crafting_recipes += recipe

	var/list/global_stack_recipes = list(
		/obj/item/stack/sheet/glass = GLOB.glass_recipes,
		/obj/item/stack/sheet/plasmaglass = GLOB.pglass_recipes,
		/obj/item/stack/sheet/rglass = GLOB.reinforced_glass_recipes,
		/obj/item/stack/sheet/plasmarglass = GLOB.prglass_recipes,
		/obj/item/stack/sheet/animalhide/gondola = GLOB.gondola_recipes,
		/obj/item/stack/sheet/animalhide/corgi = GLOB.corgi_recipes,
		/obj/item/stack/sheet/animalhide/monkey = GLOB.monkey_recipes,
		/obj/item/stack/sheet/animalhide/xeno = GLOB.xeno_recipes,
		/obj/item/stack/sheet/leather = GLOB.leather_recipes,
		/obj/item/stack/sheet/sinew = GLOB.sinew_recipes,
		/obj/item/stack/sheet/animalhide/carp = GLOB.carp_recipes,
		/obj/item/stack/sheet/mineral/sandstone = GLOB.sandstone_recipes,
		/obj/item/stack/sheet/mineral/sandbags = GLOB.sandbag_recipes,
		/obj/item/stack/sheet/mineral/diamond = GLOB.diamond_recipes,
		/obj/item/stack/sheet/mineral/uranium = GLOB.uranium_recipes,
		/obj/item/stack/sheet/mineral/plasma = GLOB.plasma_recipes,
		/obj/item/stack/sheet/mineral/gold = GLOB.gold_recipes,
		/obj/item/stack/sheet/mineral/silver = GLOB.silver_recipes,
		/obj/item/stack/sheet/mineral/bananium = GLOB.bananium_recipes,
		/obj/item/stack/sheet/mineral/titanium = GLOB.titanium_recipes,
		/obj/item/stack/sheet/mineral/plastitanium = GLOB.plastitanium_recipes,
		/obj/item/stack/sheet/mineral/snow = GLOB.snow_recipes,
		/obj/item/stack/sheet/mineral/adamantine = GLOB.adamantine_recipes,
		/obj/item/stack/sheet/mineral/abductor = GLOB.abductor_recipes,
		/obj/item/stack/sheet/iron = GLOB.metal_recipes,
		/obj/item/stack/sheet/plasteel = GLOB.plasteel_recipes,
		/obj/item/stack/sheet/mineral/wood = GLOB.wood_recipes,
		/obj/item/stack/sheet/mineral/bamboo = GLOB.bamboo_recipes,
		/obj/item/stack/sheet/cloth = GLOB.cloth_recipes,
		/obj/item/stack/sheet/durathread = GLOB.durathread_recipes,
		/obj/item/stack/sheet/cardboard = GLOB.cardboard_recipes,
		/obj/item/stack/sheet/bronze = GLOB.bronze_recipes,
		/obj/item/stack/sheet/plastic = GLOB.plastic_recipes,
		/obj/item/stack/ore/glass = GLOB.sand_recipes,
		/obj/item/stack/rods = GLOB.rod_recipes,
		/obj/item/stack/sheet/runed_metal = GLOB.runed_metal_recipes,
	)

	for(var/stack in global_stack_recipes)
		for(var/stack_recipe in global_stack_recipes[stack])
			if(istype(stack_recipe, /datum/stack_recipe_list))
				var/datum/stack_recipe_list/stack_recipe_list = stack_recipe
				for(var/nested_recipe in stack_recipe_list.recipes)
					if(!nested_recipe)
						continue
					var/datum/crafting_recipe/stack/recipe = new/datum/crafting_recipe/stack(stack, nested_recipe)
					if(recipe.name != "" && recipe.result)
						GLOB.crafting_recipes += recipe
			else
				if(!stack_recipe)
					continue
				var/datum/crafting_recipe/stack/recipe = new/datum/crafting_recipe/stack(stack, stack_recipe)
				if(recipe.name != "" && recipe.result)
					GLOB.crafting_recipes += recipe

	var/list/material_stack_recipes = list(
		SSmaterials.base_stack_recipes,
		SSmaterials.rigid_stack_recipes,
	)

	for(var/list/recipe_list in material_stack_recipes)
		for(var/stack_recipe in recipe_list)
			var/datum/crafting_recipe/stack/recipe = new/datum/crafting_recipe/stack(/obj/item/stack/sheet/iron, stack_recipe)
			recipe.steps = list("Use different materials in hand to make an item of that material")
			GLOB.crafting_recipes += recipe

/// Inits atoms used in crafting recipes
/proc/init_crafting_recipes_atoms()
	var/list/recipe_lists = list(
		GLOB.crafting_recipes,
		GLOB.cooking_recipes,
	)
	var/list/atom_lists = list(
		GLOB.crafting_recipes_atoms,
		GLOB.cooking_recipes_atoms,
	)

	for(var/list_index in 1 to length(recipe_lists))
		var/list/recipe_list = recipe_lists[list_index]
		var/list/atom_list = atom_lists[list_index]
		for(var/datum/crafting_recipe/recipe as anything in recipe_list)
			// Result
			atom_list |= recipe.result
			// Ingredients
			for(var/atom/req_atom as anything in recipe.reqs)
				atom_list |= req_atom
			// Catalysts
			for(var/atom/req_atom as anything in recipe.chem_catalysts)
				atom_list |= req_atom
			// Reaction data - required container
			if(recipe.reaction)
				var/required_container = initial(recipe.reaction.required_container)
				if(required_container)
					atom_list |= required_container
			// Tools
			for(var/atom/req_atom as anything in recipe.tool_paths)
				atom_list |= req_atom
			// Machinery
			for(var/atom/req_atom as anything in recipe.machinery)
				atom_list |= req_atom
			// Structures
			for(var/atom/req_atom as anything in recipe.structures)
				atom_list |= req_atom

//creates every subtype of prototype (excluding prototype) and adds it to list L.
//if no list/L is provided, one is created.
/proc/init_subtypes(prototype, list/L)
	if(!istype(L))
		L = list()
	for(var/path in subtypesof(prototype))
		L += new path()
	return L

//returns a list of paths to every subtype of prototype (excluding prototype)
//if no list/L is provided, one is created.
/proc/init_paths(prototype, list/L)
	if(!istype(L))
		L = list()
		for(var/path in subtypesof(prototype))
			L+= path
		return L

/// Functions like init_subtypes, but uses the subtype's path as a key for easy access
/proc/init_subtypes_w_path_keys(prototype, list/L)
	if(!istype(L))
		L = list()
	for(var/path as anything in subtypesof(prototype))
		L[path] = new path()
	return L

/**
 * Checks if that loc and dir has an item on the wall
**/
// Wall mounted machinery which are visually on the wall.
GLOBAL_LIST_INIT(WALLITEMS_INTERIOR, typecacheof(list(
	/obj/item/radio/intercom,
	/obj/structure/secure_safe,
	/obj/machinery/airalarm,
	/obj/machinery/bluespace_vendor,
	/obj/machinery/button,
	/obj/machinery/computer/security/telescreen,
	/obj/machinery/computer/security/telescreen/entertainment,
	/obj/machinery/defibrillator_mount,
	/obj/machinery/firealarm,
	/obj/machinery/flasher,
	/obj/machinery/keycard_auth,
	/obj/machinery/light_switch,
	/obj/machinery/newscaster,
	/obj/machinery/power/apc,
	/obj/machinery/requests_console,
	/obj/machinery/status_display,
	/obj/machinery/ticket_machine,
	/obj/machinery/turretid,
	/obj/machinery/barsign,
	/obj/structure/extinguisher_cabinet,
	/obj/structure/fireaxecabinet,
	/obj/structure/mirror,
	/obj/structure/noticeboard,
	/obj/structure/reagent_dispensers/wall,
	/obj/structure/sign,
	/obj/structure/sign/picture_frame,
	/obj/structure/sign/poster/contraband/random,
	/obj/structure/sign/poster/official/random,
	/obj/structure/sign/poster/random,
	/obj/structure/urinal,
)))

// Wall mounted machinery which are visually coming out of the wall.
// These do not conflict with machinery which are visually placed on the wall.
GLOBAL_LIST_INIT(WALLITEMS_EXTERIOR, typecacheof(list(
	/obj/machinery/camera,
	/obj/machinery/light,
	/obj/structure/light_construct,
)))

/// A static typecache of all the money-based items that can be actively used as currency.
GLOBAL_LIST_INIT(allowed_money, typecacheof(list(
	/obj/item/coin,
	/obj/item/holochip,
	/obj/item/stack/spacecash,
)))
