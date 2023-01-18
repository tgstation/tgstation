/**
 * Required map item element
 *
 * Do not apply through AddElement, use REGISTER_REQUIRED_MAP_ITEM
 *
 * Globally tracks atoms which are required to be mapped in per map
 * For unit testing maps to ensure they actually have these
 */
/datum/element/required_map_item

/datum/element/required_map_item/Attach(datum/target, min_amount = 1, max_amount = 1)
	. = ..()

	var/datum/required_item/existing_value = GLOB.required_map_items[target.type]
	if(isnull(existing_value))
		var/datum/required_item/new_value = new(target.type, min_amount, max_amount)
		GLOB.required_map_items[target.type] = new_value
	else
		existing_value.total_amount += 1

	// Of note, we don't decrement the total amount on destroy / detach
	// Some things may be mapped in roundstart but self-delete for whatever reason

/// Datum for tracking
/datum/required_item
	/// Type (exact) being tracked
	var/type
	/// How many exist in the world
	var/total_amount = 0
	/// Min. amount of this type that should exist roundstart (inclusive)
	var/minimum_amount = 1
	/// Max. amount of this type that should exist roundstart (inclusive)
	var/maximum_amount = 1

/datum/required_item/New(type, minimum_amount = 1, maximum_amount = 1)
	src.type = type
	src.minimum_amount = minimum_amount
	src.maximum_amount = maximum_amount
	total_amount += 1

/// Used to check if this item is fulfilled by the unit test.
/datum/required_item/proc/is_fulfilled()
	return total_amount >= minimum_amount && total_amount <= maximum_amount
