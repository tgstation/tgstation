/atom
	///The custom materials this atom is made of, used by a lot of things like furniture, walls, and floors (if I finish the functionality, that is.)
	///The list referenced by this var can be shared by multiple objects and should not be directly modified. Instead, use [set_custom_materials][/atom/proc/set_custom_materials].
	var/list/datum/material/custom_materials
	///Bitfield for how the atom handles materials.
	var/material_flags = NONE
	///Modifier that raises/lowers the effect of the amount of a material, prevents small and easy to get items from being death machines.
	var/material_modifier = 1

/// Sets the custom materials for an item.
/atom/proc/set_custom_materials(list/materials, multiplier = 1)
	if(custom_materials && material_flags & MATERIAL_EFFECTS) //Only runs if custom materials existed at first and affected src.
		for(var/current_material in custom_materials)
			var/datum/material/custom_material = GET_MATERIAL_REF(current_material)
			custom_material.on_removed(src, OPTIMAL_COST(custom_materials[current_material] * material_modifier), material_flags) //Remove the current materials

	if(!length(materials))
		custom_materials = null
		return

	if(material_flags & MATERIAL_EFFECTS)
		for(var/current_material in materials)
			var/datum/material/custom_material = GET_MATERIAL_REF(current_material)
			custom_material.on_applied(src, OPTIMAL_COST(materials[current_material] * multiplier * material_modifier), material_flags)

	custom_materials = SSmaterials.FindOrCreateMaterialCombo(materials, multiplier)

/**
 * Returns the material composition of the atom.
 *
 * Used when recycling items, specifically to turn alloys back into their component mats.
 *
 * Exists because I'd need to add a way to un-alloy alloys or otherwise deal
 * with people converting the entire stations material supply into alloys.
 *
 * Arguments:
 * - flags: A set of flags determining how exactly the materials are broken down.
 */
/atom/proc/get_material_composition()
	. = list()

	var/list/cached_materials = custom_materials
	for(var/mat in cached_materials)
		var/datum/material/material = GET_MATERIAL_REF(mat)
		var/list/material_comp = material.return_composition(cached_materials[mat])
		for(var/comp_mat in material_comp)
			.[comp_mat] += material_comp[comp_mat]

/**
 * Fetches a list of all of the materials this object has of the desired type. Returns null if there is no valid materials of the type
 *
 * Arguments:
 * - [required_material][/datum/material]: The type of material we are checking for
 * - mat_amount: The minimum required amount of material
 */
/atom/proc/has_material_type(datum/material/required_material, mat_amount = 0)
	var/list/cached_materials = custom_materials
	if(!length(cached_materials))
		return null

	var/materials_of_type
	for(var/current_material in cached_materials)
		if(cached_materials[current_material] < mat_amount)
			continue
		var/datum/material/material = GET_MATERIAL_REF(current_material)
		if(!istype(material, required_material))
			continue
		LAZYSET(materials_of_type, material, cached_materials[current_material])

	return materials_of_type

/**
 * Fetches a list of all of the materials this object has with the desired material category.
 *
 * Arguments:
 * - category: The category to check for
 * - any_flags: Any bitflags that must be present for the category
 * - all_flags: All bitflags that must be present for the category
 * - no_flags: Any bitflags that must not be present for the category
 * - mat_amount: The minimum amount of materials that must be present
 */
/atom/proc/has_material_category(category, any_flags=0, all_flags=0, no_flags=0, mat_amount=0)
	var/list/cached_materials = custom_materials
	if(!length(cached_materials))
		return null

	var/materials_of_category
	for(var/current_material in cached_materials)
		if(cached_materials[current_material] < mat_amount)
			continue
		var/datum/material/material = GET_MATERIAL_REF(current_material)
		var/category_flags = material?.categories[category]
		if(isnull(category_flags))
			continue
		if(any_flags && !(category_flags & any_flags))
			continue
		if(all_flags && (all_flags != (category_flags & all_flags)))
			continue
		if(no_flags && (category_flags & no_flags))
			continue
		LAZYSET(materials_of_category, material, cached_materials[current_material])
	return materials_of_category

/**
 * Gets the most common material in the object.
 */
/atom/proc/get_master_material()
	var/list/cached_materials = custom_materials
	if(!length(cached_materials))
		return null

	var/most_common_material = null
	var/max_amount = 0
	for(var/material in cached_materials)
		if(cached_materials[material] > max_amount)
			most_common_material = material
			max_amount = cached_materials[material]

	if(most_common_material)
		return GET_MATERIAL_REF(most_common_material)

/**
 * Gets the total amount of materials in this atom.
 */
/atom/proc/get_custom_material_amount()
	return isnull(custom_materials) ? 0 : counterlist_sum(custom_materials)
