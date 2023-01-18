/**
 * Tests that all expected items are mapped in roundstart.
 *
 * How to add an item to this test:
 * - Add the typepath(s) to setup_expected_types
 * - In the type's initialize, REGISTER_REQUIRED_MAP_ITEM() a minimum and maximum
 */
/datum/unit_test/required_map_items
	/// A list of all typepaths that we expect to be in the required items list
	var/list/expected_types = list()

/// Used to fill the expected types list with all the types we look for on the map.
/datum/unit_test/required_map_items/proc/setup_expected_types()
	expected_types += subtypesof(/obj/item/stamp/head)
	expected_types += subtypesof(/obj/machinery/computer/department_orders)
	expected_types += /obj/machinery/computer/communications
	expected_types += /mob/living/carbon/human/species/monkey/punpun

/datum/unit_test/required_map_items/Run()
	setup_expected_types()

	for(var/got_type in expected_types)
		var/datum/required_item/item = GLOB.required_map_items[got_type]
		var/items_found = item?.total_amount || 0
		if(items_found <= 0)
			TEST_FAIL("Item [item] was not found, but is expected to be mapped in on mapload!")
			continue

		if(items_found < item.minimum_amount)
			TEST_FAIL("Item [item] should have at least [item.minimum_amount] mapped in but only had [items_found] on mapload!")
			continue

		if(items_found > item.maximum_amount)
			TEST_FAIL("Item [item] should have at most [item.maximum_amount] mapped in but had [items_found] on mapload!")
			continue

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
	var/tracked_type
	/// How many exist in the world
	var/total_amount = 0
	/// Min. amount of this type that should exist roundstart (inclusive)
	var/minimum_amount = 1
	/// Max. amount of this type that should exist roundstart (inclusive)
	var/maximum_amount = 1

/datum/required_item/New(tracked_type, minimum_amount = 1, maximum_amount = 1)
	src.tracked_type = tracked_type
	src.minimum_amount = minimum_amount
	src.maximum_amount = maximum_amount
	total_amount += 1

/// Used to check if this item is fulfilled by the unit test.
/datum/required_item/proc/is_fulfilled()
	return total_amount >= minimum_amount && total_amount <= maximum_amount
