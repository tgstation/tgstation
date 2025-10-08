//Pills & Patches
/// List of containers the Chem Master machine can print
GLOBAL_LIST_INIT(reagent_containers, list(
	CAT_CONDIMENTS = list(
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/condiment/flour,
		/obj/item/reagent_containers/condiment/sugar,
		/obj/item/reagent_containers/condiment/rice,
		/obj/item/reagent_containers/condiment/cornmeal,
		/obj/item/reagent_containers/condiment/milk,
		/obj/item/reagent_containers/condiment/soymilk,
		/obj/item/reagent_containers/condiment/yoghurt,
		/obj/item/reagent_containers/condiment/saltshaker,
		/obj/item/reagent_containers/condiment/peppermill,
		/obj/item/reagent_containers/condiment/soysauce,
		/obj/item/reagent_containers/condiment/bbqsauce,
		/obj/item/reagent_containers/condiment/enzyme,
		/obj/item/reagent_containers/condiment/hotsauce,
		/obj/item/reagent_containers/condiment/coldsauce,
		/obj/item/reagent_containers/condiment/mayonnaise,
		/obj/item/reagent_containers/condiment/ketchup,
		/obj/item/reagent_containers/condiment/olive_oil,
		/obj/item/reagent_containers/condiment/vegetable_oil,
		/obj/item/reagent_containers/condiment/peanut_butter,
		/obj/item/reagent_containers/condiment/cherryjelly,
		/obj/item/reagent_containers/condiment/honey,
		/obj/item/reagent_containers/condiment/pack,
	),
	CAT_TUBES = list(
		/obj/item/reagent_containers/cup/tube
	),
	CAT_PILLS = typecacheof(list(
		/obj/item/reagent_containers/applicator/pill/style
	)),
	CAT_PATCHES = typecacheof(list(
		/obj/item/reagent_containers/applicator/patch/style
	)),
))

/// list of all /datum/chemical_reaction datums indexed by their typepath. Use this for general lookup stuff
GLOBAL_LIST(chemical_reactions_list)
/// list of all /datum/chemical_reaction datums. Used during chemical reactions. Indexed by REACTANT types
GLOBAL_LIST(chemical_reactions_list_reactant_index)
/// list of all /datum/chemical_reaction datums. Used for the reaction lookup UI. Indexed by PRODUCT type
GLOBAL_LIST(chemical_reactions_list_product_index)
/// list of all /datum/reagent datums indexed by reagent id. Used by chemistry stuff
GLOBAL_LIST_INIT(chemical_reagents_list, init_chemical_reagent_list())
/// list of all reactions with their associated product and result ids. Used for reaction lookups
GLOBAL_LIST(chemical_reactions_results_lookup_list)
/// list of all reagents that are parent types used to define a bunch of children - but aren't used themselves as anything.
GLOBAL_LIST(fake_reagent_blacklist)
/// Turfs metalgen can't touch
GLOBAL_LIST_INIT(blacklisted_metalgen_types, typecacheof(list(
	/turf/closed/indestructible, //indestructible turfs should be indestructible, metalgen transmutation to plasma allows them to be destroyed
	/turf/open/indestructible
)))
/// Map of reagent names to its datum path
GLOBAL_LIST_INIT(name2reagent, build_name2reagentlist())
/// list of all plan traits
GLOBAL_LIST_INIT(plant_traits, init_plant_traits())

/// Initialises all /datum/reagent into a list indexed by reagent id
/proc/init_chemical_reagent_list()
	var/list/reagent_list = list()

	for(var/datum/reagent/path as anything in subtypesof(/datum/reagent))
		if(path in GLOB.fake_reagent_blacklist)
			continue
		var/datum/reagent/target_object = new path()
		target_object.mass = rand(10, 800)
		reagent_list[path] = target_object

	return reagent_list

/**
 * Chemical Reactions - Initialises all /datum/chemical_reaction into a list
 * It is filtered into multiple lists within a list.
 * For example:
 * chemical_reactions_list_reactant_index[/datum/reagent/toxin/plasma] is a list of all reactions relating to plasma
 * For chemical reaction list product index - indexes reactions based off the product reagent type - see get_recipe_from_reagent_product() in helpers
 * For chemical reactions list lookup list - creates a bit list of info passed to the UI. This is saved to reduce lag from new windows opening, since it's a lot of data.
 */
/proc/build_chemical_reactions_lists()
	if(GLOB.chemical_reactions_list_reactant_index)
		return

	//Prevent these reactions from appearing in lookup tables (UI code)
	var/list/blacklist = typecacheof(/datum/chemical_reaction/randomized)

	//Randomized need to go last since they need to check against conflicts with normal recipes
	var/paths = subtypesof(/datum/chemical_reaction) - typesof(/datum/chemical_reaction/randomized) + subtypesof(/datum/chemical_reaction/randomized)
	GLOB.chemical_reactions_list = list() //typepath to reaction list
	GLOB.chemical_reactions_list_reactant_index = list() //reagents to reaction list
	GLOB.chemical_reactions_results_lookup_list = list() //UI glob
	GLOB.chemical_reactions_list_product_index = list() //product to reaction list

	var/list/datum/chemical_reaction/reactions = list()
	for(var/path in paths)
		var/datum/chemical_reaction/reaction = new path()
		reactions += reaction

	// Ok so we're gonna do a thingTM here
	// I want to distribute all our reactions such that each reagent id links to as few as possible
	// I get the feeling there's a canonical way of doing this, but I don't know it
	// So instead, we're gonna wing it
	var/list/reagent_to_react_count = list()
	for(var/datum/chemical_reaction/reaction as anything in reactions)
		for(var/reagent_id in reaction.required_reagents)
			reagent_to_react_count[reagent_id] += 1

	var/list/reaction_lookup = GLOB.chemical_reactions_list_reactant_index
	// Create filters based on a random reagent id in the required reagents list - this is used to speed up handle_reactions()
	// Basically, we only really need to care about ONE reagent, at least when initially filtering, since any others are ignorable
	// Doing this separately because it relies on the loop above, and this is easier to parse
	for(var/datum/chemical_reaction/reaction as anything in reactions)
		var/preferred_id = null
		for(var/reagent_id in reaction.required_reagents)
			if(isnull(preferred_id))
				preferred_id = reagent_id
				continue
			// If we would have less then they would, take it
			if(length(reaction_lookup[reagent_id]) < length(reaction_lookup[preferred_id]))
				preferred_id = reagent_id
				continue
			// If they potentially have more then us, we take it
			if(reagent_to_react_count[reagent_id] < reagent_to_react_count[preferred_id])
				preferred_id = reagent_id
				continue
		if (!isnull(preferred_id))
			if(!reaction_lookup[preferred_id])
				reaction_lookup[preferred_id] = list()
			reaction_lookup[preferred_id] += reaction

	for(var/datum/chemical_reaction/reaction as anything in reactions)
		var/list/product_ids = list()
		var/list/reagents = list()
		var/list/product_names = list()
		var/bitflags = reaction.reaction_tags

		if(!length(reaction.required_reagents)) //Skip impossible reactions
			continue

		GLOB.chemical_reactions_list[reaction.type] = reaction

		for(var/reagent_path in reaction.required_reagents)
			var/datum/reagent/reagent = find_reagent_object_from_type(reagent_path)
			if(!istype(reagent))
				stack_trace("Invalid reagent found in [reaction] required_reagents: [reagent_path]")
				continue
			reagents += list(list("name" = reagent.name, "id" = reagent.type))

		for(var/product in reaction.results)
			var/datum/reagent/reagent = find_reagent_object_from_type(product)
			if(!istype(reagent))
				stack_trace("Invalid reagent found in [reaction] results: [product]")
				continue
			product_names += reagent.name
			product_ids += product

		var/product_name
		if(!length(product_names))
			var/list/names = splittext("[reaction.type]", "/")
			product_name = names[names.len]
		else
			product_name = product_names[1]

		if(!is_type_in_typecache(reaction.type, blacklist))
			//Master list of ALL reactions that is used in the UI lookup table. This is expensive to make, and we don't want to lag the server by creating it on UI request, so it's cached to send to UIs instantly.
			GLOB.chemical_reactions_results_lookup_list += list(list("name" = product_name, "id" = reaction.type, "bitflags" = bitflags, "reactants" = reagents))

			// Create filters based on each reagent id in the required reagents list - this is specifically for finding reactions from product(reagent) ids/typepaths.
			for(var/id in product_ids)
				if(!GLOB.chemical_reactions_list_product_index[id])
					GLOB.chemical_reactions_list_product_index[id] = list()
				GLOB.chemical_reactions_list_product_index[id] += reaction

/// Builds map of reagent name to its datum path
/proc/build_name2reagentlist()
	. = list()

	//build map with keys stored separately
	var/list/name_to_reagent = list()
	var/list/only_names = list()
	for (var/datum/reagent/reagent as anything in GLOB.chemical_reagents_list)
		var/name = initial(reagent.name)
		if (length(name))
			name_to_reagent[name] = reagent
			only_names += name

	//sort keys
	only_names = sort_list(only_names)

	//build map with sorted keys
	for(var/name in only_names)
		.[name] = name_to_reagent[name]
