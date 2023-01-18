/// Global assoc list of required items
/// Set up [item typepath] to [required item datum].
/// See [/datum/element/required_map_item]
GLOBAL_LIST_EMPTY(required_map_items)

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
		var/datum/map_necessary_item/item = GLOB.required_map_items[got_type]
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
