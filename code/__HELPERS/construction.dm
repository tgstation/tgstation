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
