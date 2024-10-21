/// Makes sure only integer values are used when consuming, removing & checking for mats
#define OPTIMAL_COST(cost)(max(1, round(cost)))

/// Wrapper for fetching material references. Exists exclusively so that people don't need to wrap everything in a list every time.
#define GET_MATERIAL_REF(arguments...) SSmaterials._GetMaterialRef(list(##arguments))

// Wrapper to convert material name into its source name
#define MATERIAL_SOURCE(mat) "[mat.name]_material"


/**
 * Produces a new RCD result from the given one if it can be calculated that
 * the RCD should speed up with the remembered form.
 *
 */
/proc/rcd_result_with_memory(list/defaults, turf/place, expected_memory)
	if (place?.rcd_memory == expected_memory)
		return defaults + list(
			"cost" = defaults["cost"] / RCD_MEMORY_COST_BUFF,
			"delay" = defaults["delay"] / RCD_MEMORY_SPEED_BUFF,
			RCD_RESULT_BYPASS_FREQUENT_USE_COOLDOWN = TRUE,
		)
	else
		return defaults

/**
 * Turns material amount into the number of sheets, returning FALSE if the number is less than SHEET_MATERIAL_AMOUNT
 *
 * Arguments:
 * - amt: amount to convert
 */
/proc/amount2sheet(amt)
	if(amt >= SHEET_MATERIAL_AMOUNT)
		return round(amt / SHEET_MATERIAL_AMOUNT)
	return 0

/**
 * Turns number of sheets into material amount, returning FALSE if the number is <= 0
 *
 * Arguments:
 * - amt: amount to convert
 */
/proc/sheet2amount(sheet_amt)
	if(sheet_amt > 0)
		return sheet_amt * SHEET_MATERIAL_AMOUNT
	return 0

/**
 * Splits a stack. we don't use /obj/item/stack/proc/fast_split_stack because Byond complains that should only be called asynchronously.
 * This proc is also more faster because it doesn't deal with mobs, copying evidences or refreshing atom storages
 * Has special internal uses for e.g. by the material container
 *
 * Arguments:
 * - [target][obj/item/stack]: the stack to split
 * - [amount]: amount to split by
 */
/proc/fast_split_stack(obj/item/stack/target, amount)
	if(!target.use(amount, TRUE, FALSE))
		return null

	. = new target.type(target.drop_location(), amount, FALSE, target.mats_per_unit)

/**
 * divides a list of materials uniformly among all contents of the target_object recursively
 * Used to set materials of printed items with their design cost by taking into consideration their already existing materials
 * e.g. if 12 iron is to be divided uniformly among 2 objects A, B who's current iron contents are 3 & 7
 * Then first we normalize those values i.e. find their weights to decide who gets an higher share of iron
 * total_sum = 3 + 7 = 10, A = 3/10 = 0.3, B = 7/10 = 0.7
 * Then we finally multiply those weights with the user value of 12 we get
 * A = 0.3 * 12 = 3.6, B = 0.7 * 12 = 8.4 i.e. 3.6 + 8.4 = 12!!
 * Off course we round the values so we don't have to deal with floating point materials so the actual value
 * ends being less but that's not an issue
 * Arguments
 *
 * * [custom_materials][list] - the list of materials to set for the object
 * * multiplier - multiplier passed to set_custom_materials
 * * [target_object][atom] - the target object who's custom materials we are trying to modify
 */
/proc/split_materials_uniformly(list/custom_materials, multiplier, atom/target_object)
	if(!length(target_object.contents)) //most common case where the object is just 1 thing
		target_object.set_custom_materials(custom_materials, multiplier)
		return

	//Step 1: Get recursive contents of all objects, only filter obj cause that what's material container accepts
	var/list/reccursive_contents = target_object.get_all_contents_type(/obj/item)

	//Step 2: find the sum of each material type per object and record their amounts into an 2D list
	var/list/material_map_sum = list()
	var/list/material_map_amounts = list()
	for(var/atom/object as anything in reccursive_contents)
		var/list/item_materials = object.custom_materials
		for(var/mat as anything in custom_materials)
			var/mat_amount = 1 //no materials mean we assign this default amount
			if(length(item_materials))
				mat_amount = item_materials[mat] || 1 //if this object doesn't have our material type then assign a default value of 1

			//record the sum of mats for normalizing
			material_map_sum[mat] += mat_amount
			//record the material amount for each item into an 2D list
			var/list/mat_list_per_item = material_map_amounts[mat]
			if(isnull(mat_list_per_item))
				material_map_amounts[mat] = list(mat_amount)
			else
				mat_list_per_item += mat_amount

	//Step 3: normalize & scale material_map_amounts with material_map_sum
	for(var/mat as anything in material_map_amounts)
		var/mat_sum = material_map_sum[mat]
		var/list/mat_per_item = material_map_amounts[mat]
		for(var/i in 1 to mat_per_item.len)
			mat_per_item[i] = (mat_per_item[i] / mat_sum) * custom_materials[mat]

	//Step 4 flatten the 2D list and assign the final values to each atom
	var/index = 1
	for(var/atom/object as anything in reccursive_contents)
		var/list/final_material_list = list()
		for(var/mat as anything in material_map_amounts)
			var/list/mat_per_item = material_map_amounts[mat]
			final_material_list[mat] = mat_per_item[index]
		object.set_custom_materials(final_material_list, multiplier)
		index += 1
