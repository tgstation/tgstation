/*! How material datums work
Materials are now instanced datums, with an associative list of them being kept in SSmaterials. We only instance the materials once and then re-use these instances for everything.

These materials call on_applied() on whatever item they are applied to, common effects are adding components, changing color and changing description. This allows us to differentiate items based on the material they are made out of.area

*/
SUBSYSTEM_DEF(materials)
	name = "Materials"
	flags = SS_NO_FIRE | SS_NO_INIT
	///Dictionary of material.id || material ref
	var/list/materials
	///Dictionary of type || list of material refs
	var/list/materials_by_type
	///Dictionary of type || list of material ids
	var/list/materialids_by_type
	///Dictionary of category || list of material refs
	var/list/materials_by_category
	///Dictionary of category || list of material ids, mostly used by rnd machines like autolathes.
	var/list/materialids_by_category
	///A cache of all material combinations that have been used
	var/list/list/material_combos
	///List of stackcrafting recipes for materials using base recipes
	var/list/base_stack_recipes = list(
		new /datum/stack_recipe("Chair", /obj/structure/chair/greyscale, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND | CRAFT_APPLIES_MATS, category = CAT_FURNITURE),
		new /datum/stack_recipe("Toilet", /obj/structure/toilet/greyscale, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND | CRAFT_APPLIES_MATS, category = CAT_FURNITURE),
		new /datum/stack_recipe("Sink Frame", /obj/structure/sinkframe, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND | CRAFT_APPLIES_MATS, category = CAT_FURNITURE),
		new /datum/stack_recipe("Material floor tile", /obj/item/stack/tile/material, 1, 4, 20, crafting_flags = CRAFT_APPLIES_MATS, category = CAT_TILES),
		new /datum/stack_recipe("Material airlock assembly", /obj/structure/door_assembly/door_assembly_material, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND | CRAFT_APPLIES_MATS, category = CAT_DOORS),
		new /datum/stack_recipe("Material platform", /obj/structure/platform/material, 2, time = 3 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND | CRAFT_APPLIES_MATS, trait_booster = TRAIT_QUICK_BUILD, trait_modifier = 0.75, category = CAT_STRUCTURE), \
	)
	///List of stackcrafting recipes for materials using rigid recipes
	var/list/rigid_stack_recipes = list(
		new /datum/stack_recipe("Carving block", /obj/structure/carving_block, 5, time = 3 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND | CRAFT_APPLIES_MATS, category = CAT_STRUCTURE),
	)

	///A list of dimensional themes used by the dimensional anomaly and other things, most of which require materials to function.
	var/list/datum/dimension_theme/dimensional_themes

///Ran on initialize, populated the materials and materials_by_category dictionaries with their appropriate vars (See these variables for more info)
/datum/controller/subsystem/materials/proc/InitializeMaterials()
	materials = list()
	materials_by_type = list()
	materialids_by_type = list()
	materials_by_category = list()
	materialids_by_category = list()
	material_combos = list()
	for(var/type in subtypesof(/datum/material))
		var/datum/material/mat_type = type
		if(!(initial(mat_type.init_flags) & MATERIAL_INIT_MAPLOAD))
			continue // Do not initialize at mapload
		InitializeMaterial(list(mat_type))

	dimensional_themes = init_subtypes_w_path_keys(/datum/dimension_theme)

/** Creates and caches a material datum.
 *
 * Arguments:
 * - [arguments][/list]: The arguments to use to create the material datum
 *   - The first element is the type of material to initialize.
 */
/datum/controller/subsystem/materials/proc/InitializeMaterial(list/arguments)
	var/datum/material/mat_type = arguments[1]
	if(initial(mat_type.init_flags) & MATERIAL_INIT_BESPOKE)
		arguments[1] = GetIdFromArguments(arguments)

	var/datum/material/mat_ref = new mat_type
	if(!mat_ref.Initialize(arglist(arguments)))
		return null

	var/mat_id = mat_ref.id
	materials[mat_id] = mat_ref
	materials_by_type[mat_type] += list(mat_ref)
	materialids_by_type[mat_type] += list(mat_id)
	for(var/category in mat_ref.categories)
		materials_by_category[category] += list(mat_ref)
		materialids_by_category[category] += list(mat_id)

	SEND_SIGNAL(src, COMSIG_MATERIALS_INIT_MAT, mat_ref)
	return mat_ref

/** Fetches a cached material singleton when passed sufficient arguments.
 *
 * Arguments:
 * - [arguments][/list]: The list of arguments used to fetch the material ref.
 *   - The first element is a material datum, text string, or material type.
 *     - [Material datums][/datum/material] are assumed to be references to the cached datum and are returned
 *     - Text is assumed to be the text ID of a material and the corresponding material is fetched from the cache
 *     - A material type is checked for bespokeness:
 *       - If the material type is not bespoke the type is assumed to be the id for a material and the corresponding material is loaded from the cache.
 *       - If the material type is bespoke a text ID is generated from the arguments list and used to load a material datum from the cache.
 *   - The following elements are used to generate bespoke IDs
 */
/datum/controller/subsystem/materials/proc/_GetMaterialRef(list/arguments)
	if(!materials)
		InitializeMaterials()

	var/datum/material/key = arguments[1]
	if(istype(key))
		return key // We are assuming here that the only thing allowed to create material datums is [/datum/controller/subsystem/materials/proc/InitializeMaterial]

	if(istext(key)) // Handle text id
		. = materials[key]
		if(!.)
			WARNING("Attempted to fetch material ref with invalid text id '[key]'")
		return

	if(!ispath(key, /datum/material))
		CRASH("Attempted to fetch material ref with invalid key [key]")

	if(!(initial(key.init_flags) & MATERIAL_INIT_BESPOKE))
		. = materials[key]
		if(!.)
			WARNING("Attempted to fetch reference to an abstract material with key [key]")
		return

	key = GetIdFromArguments(arguments)
	return materials[key] || InitializeMaterial(arguments)

/** I'm not going to lie, this was swiped from [SSdcs][/datum/controller/subsystem/processing/dcs].
 * Credit does to ninjanomnom
 *
 * Generates an id for bespoke ~~elements~~ materials when given the argument list
 * Generating the id here is a bit complex because we need to support named arguments
 * Named arguments can appear in any order and we need them to appear after ordered arguments
 * We assume that no one will pass in a named argument with a value of null
 **/
/datum/controller/subsystem/materials/proc/GetIdFromArguments(list/arguments)
	var/datum/material/mattype = arguments[1]
	var/list/fullid = list("[initial(mattype.id) || mattype]")
	var/list/named_arguments = list()
	for(var/i in 2 to length(arguments))
		var/key = arguments[i]
		var/value
		if(istext(key))
			value = arguments[key]
		if(!(istext(key) || isnum(key)))
			key = REF(key)
		key = "[key]" // Key is stringified so numbers don't break things
		if(!isnull(value))
			if(!(istext(value) || isnum(value)))
				value = REF(value)
			named_arguments["[key]"] = value
		else
			fullid += "[key]"

	if(length(named_arguments))
		named_arguments = sort_list(named_arguments)
		fullid += named_arguments
	return list2params(fullid)


/// Returns a list to be used as an object's custom_materials. Lists will be cached and re-used based on the parameters.
/datum/controller/subsystem/materials/proc/FindOrCreateMaterialCombo(list/materials_declaration, multiplier = 1)
	if(!LAZYLEN(materials_declaration))
		return null // If we get a null we pass it right back, we don't want to generate stack traces just because something is clearing out its materials list.

	if(!material_combos)
		InitializeMaterials()
	var/list/combo_params = list()
	for(var/x in materials_declaration)
		var/datum/material/mat = x
		combo_params += "[istype(mat) ? mat.id : mat]=[OPTIMAL_COST(materials_declaration[mat] * multiplier)]"
	sortTim(combo_params, GLOBAL_PROC_REF(cmp_text_asc)) // We have to sort now in case the declaration was not in order
	var/combo_index = combo_params.Join("-")
	var/list/combo = material_combos[combo_index]
	if(!combo)
		combo = list()
		for(var/mat in materials_declaration)
			combo[GET_MATERIAL_REF(mat)] = OPTIMAL_COST(materials_declaration[mat] * multiplier)
		material_combos[combo_index] = combo
	return combo
