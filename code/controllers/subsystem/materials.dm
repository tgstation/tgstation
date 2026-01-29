/*! How material datums work
Materials are now instanced datums, with an associative list of them being kept in SSmaterials. We only instance the materials once and then re-use these instances for everything.

These materials call on_applied() on whatever item they are applied to, common effects are adding components, changing color and changing description. This allows us to differentiate items based on the material they are made out of.area

*/
SUBSYSTEM_DEF(materials)
	name = "Materials"
	flags = SS_NO_FIRE | SS_NO_INIT
	/// Dictionary of material.id || material ref
	var/list/materials
	/// Flat list of materials
	var/list/flat_materials
	/// Dictionary of type || list of material refs
	var/list/materials_by_type
	/// A cache of all material combinations that have been used
	var/list/list/material_combos
	/// List of stackcrafting recipes for materials using base recipes
	var/list/base_stack_recipes = list(
		new /datum/stack_recipe("Chair", /obj/structure/chair/greyscale, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND | CRAFT_SKIP_MATERIALS_PARITY, category = CAT_FURNITURE),
		new /datum/stack_recipe("Toilet", /obj/structure/toilet/greyscale, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND | CRAFT_SKIP_MATERIALS_PARITY, category = CAT_FURNITURE),
		new /datum/stack_recipe("Sink Frame", /obj/item/wallframe/sinkframe, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND | CRAFT_SKIP_MATERIALS_PARITY, category = CAT_FURNITURE),
		new /datum/stack_recipe("Material floor tile", /obj/item/stack/tile/material, 1, 4, 20, crafting_flags = CRAFT_SKIP_MATERIALS_PARITY, category = CAT_TILES),
		new /datum/stack_recipe("Material airlock assembly", /obj/structure/door_assembly/door_assembly_material, 4, time = 5 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND | CRAFT_SKIP_MATERIALS_PARITY, category = CAT_DOORS),
		new /datum/stack_recipe("Material platform", /obj/structure/platform/material, 2, time = 3 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND | CRAFT_SKIP_MATERIALS_PARITY, trait_booster = TRAIT_QUICK_BUILD, trait_modifier = 0.75, category = CAT_STRUCTURE), \
	)
	/// List of stackcrafting recipes for materials using rigid recipes
	var/list/rigid_stack_recipes = list(
		new /datum/stack_recipe("Carving block", /obj/structure/carving_block, 5, time = 3 SECONDS, crafting_flags = CRAFT_CHECK_DENSITY | CRAFT_ONE_PER_TURF | CRAFT_ON_SOLID_GROUND | CRAFT_SKIP_MATERIALS_PARITY, category = CAT_STRUCTURE),
	)

	/// A list of dimensional themes used by the dimensional anomaly and other things, most of which require materials to function.
	var/list/datum/dimension_theme/dimensional_themes
	/// An ID -> instance list of material properties
	var/list/datum/material_property/properties

///Ran on initialize, populated the materials and material dictionaries with their appropriate vars (See these variables for more info)
/datum/controller/subsystem/materials/proc/initialize_materials()
	materials = list()
	flat_materials = list()
	materials_by_type = list()
	material_combos = list()

	properties = list()
	for(var/datum/material_property/property_type as anything in valid_subtypesof(/datum/material_property))
		properties[property_type::id] = new property_type()

	for(var/datum/material/mat_type as anything in valid_subtypesof(/datum/material))
		if(initial(mat_type.init_flags) & MATERIAL_INIT_MAPLOAD)
			initialize_material(mat_type)

	dimensional_themes = init_subtypes_w_path_keys(/datum/dimension_theme)

/** Creates and caches a material datum.
 *	The first argument is the type of material to initialize, the rest are passed to the material's init
 */
/datum/controller/subsystem/materials/proc/initialize_material(datum/material/mat_type, ...)
	var/mat_id = mat_type
	if(initial(mat_type.init_flags) & MATERIAL_INIT_BESPOKE)
		mat_id = get_id_from_args(arglist(list(mat_type) + args.Copy(2)))

	var/datum/material/mat_ref = new mat_type
	if(!mat_ref.Initialize(arglist(list(mat_id) + args.Copy(2))))
		return null

	mat_id = mat_ref.id
	materials[mat_id] = mat_ref
	flat_materials += mat_ref
	materials_by_type[mat_type] += list(mat_ref)
	SEND_SIGNAL(src, COMSIG_MATERIALS_INIT_MAT, mat_ref)
	return mat_ref

/**
 * Fetches a cached material singleton when passed sufficient arguments.
 * Arguments:
 * - The first argument is a material datum, text string, or material type.
 * - [Material datums][/datum/material] are assumed to be references to the cached datum and are returned
 * - Text is assumed to be the text ID of a material and the corresponding material is fetched from the cache
 * - A material type is checked for bespokeness:
 *   - If the material type is not bespoke the type is assumed to be the id for a material and the corresponding material is loaded from the cache.
 *   - If the material type is bespoke a text ID is generated from the arguments list and used to load a material datum from the cache.
 * - The following elements are used to generate bespoke IDs
 */
/datum/controller/subsystem/materials/proc/get_material(datum/material/material_type, ...)
	RETURN_TYPE(/datum/material)

	if(!materials)
		initialize_materials()

	if(istype(material_type))
		return material_type // We are assuming here that the only thing allowed to create material datums is [/datum/controller/subsystem/materials/proc/initialize_material]

	if(istext(material_type)) // Handle text id
		. = materials[material_type]
		if(!.)
			WARNING("Attempted to fetch material ref with invalid text id '[material_type]'")
		return

	if(!ispath(material_type, /datum/material))
		CRASH("Attempted to fetch material ref with invalid key [material_type]")

	if(!(initial(material_type.init_flags) & MATERIAL_INIT_BESPOKE))
		. = materials[material_type]
		if(!.)
			WARNING("Attempted to fetch reference to an abstract material with key [material_type]")
		return

	var/material_id = get_id_from_args(arglist(list(material_type) + args.Copy(2)))
	return materials[material_id] || initialize_material(arglist(list(material_type) + args.Copy(2)))

/// Fetches all materials that match a flag, or that don't have a flag if the passed flag is negative
/datum/controller/subsystem/materials/proc/get_materials_by_flag(mat_flag)
	if (isnull(mat_flag) || mat_flag == MATERIAL_CLASS_ANY) // Wildcard for "any" material
		return flat_materials

	var/static/list/materials_by_flag
	if (!materials_by_flag)
		materials_by_flag = list()

	var/list/result = materials_by_flag["[mat_flag]"]
	if (result)
		return result

	result = list()
	for (var/datum/material/material as anything in flat_materials)
		if (mat_flag > 0)
			if (material.mat_flags & mat_flag)
				result += material
		else if (!(material.mat_flags & mat_flag))
			result += material

	materials_by_flag["[mat_flag]"] = result
	return result

/**
 * I'm not going to lie, this was swiped from [SSdcs][/datum/controller/subsystem/processing/dcs].
 * Credit does to ninjanomnom
 *
 * Generates an id for bespoke ~~elements~~ materials when given the argument list
 * Generating the id here is a bit complex because we need to support named arguments
 * Named arguments can appear in any order and we need them to appear after ordered arguments
 * We assume that no one will pass in a named argument with a value of null
 **/
/datum/controller/subsystem/materials/proc/get_id_from_args(datum/material/mat_type, ...)
	var/list/fullid = list("[initial(mat_type.id) || mat_type]")
	var/list/named_arguments = list()
	for(var/i in 2 to length(args))
		var/key = args[i]
		var/value
		if(istext(key))
			value = args[key]
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
/datum/controller/subsystem/materials/proc/get_material_set_cache(list/materials_declaration, multiplier = 1)
	if(!LAZYLEN(materials_declaration))
		return null // If we get a null we pass it right back, we don't want to generate stack traces just because something is clearing out its materials list.

	if(!material_combos)
		initialize_materials()
	var/list/combo_params = list()
	for(var/datum/material/mat as anything in materials_declaration)
		combo_params += "[istype(mat) ? mat.id : mat]=[OPTIMAL_COST(materials_declaration[mat] * multiplier)]"
	sortTim(combo_params, GLOBAL_PROC_REF(cmp_text_asc)) // We have to sort now in case the declaration was not in order
	var/combo_index = combo_params.Join("-")
	var/list/combo = material_combos[combo_index]
	if(!combo)
		combo = list()
		for(var/mat in materials_declaration)
			combo[SSmaterials.get_material(mat)] = OPTIMAL_COST(materials_declaration[mat] * multiplier)
		material_combos[combo_index] = combo
	return combo
