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
/// This list will just be full of typepaths that we expect.
/// More detailed information about each item (mainly, how much of each should exist) is set on a per item basis
/datum/unit_test/required_map_items/proc/setup_expected_types()
	expected_types += subtypesof(/obj/item/stamp/head)
	expected_types += subtypesof(/obj/machinery/computer/department_orders)
	expected_types += /obj/machinery/computer/communications
	expected_types += /mob/living/carbon/human/species/monkey/punpun
	expected_types += /mob/living/basic/pet/dog/corgi/ian
	expected_types += /mob/living/simple_animal/parrot/poly

/datum/unit_test/required_map_items/Run()
	setup_expected_types()

	var/list/required_map_items = GLOB.required_map_items.Copy()
	for(var/got_type in expected_types)
		var/datum/required_item/item = required_map_items[got_type]
		var/items_found = item?.total_amount || 0
		required_map_items -= got_type
		if(items_found <= 0)
			TEST_FAIL("Item [got_type] was not found, but is expected to be mapped in on mapload!")
			continue

		if(items_found < item.minimum_amount)
			TEST_FAIL("Item [got_type] should have at least [item.minimum_amount] mapped in but only had [items_found] on mapload!")
			continue

		if(items_found > item.maximum_amount)
			TEST_FAIL("Item [got_type] should have at most [item.maximum_amount] mapped in but had [items_found] on mapload!")
			continue

	// This primarily serves as a reminder to include the typepath in the expected types list above.
	// However we can easily delete this line in the future if it runs into false positives.
	TEST_ASSERT(length(required_map_items) == 0, "The following paths were found in required map items, but weren't checked: [english_list(required_map_items)]")

/// Datum for tracking required map items
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
