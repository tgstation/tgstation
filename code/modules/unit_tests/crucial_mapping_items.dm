/datum/unit_test/crucial_mapping_items
	var/list/expected_types = list()

/datum/unit_test/crucial_mapping_items/proc/setup_expected_types()
	expected_types += subtypesof(/obj/item/stamp/head)
	expected_types += subtypesof(/obj/machinery/computer/department_orders)
	expected_types += /obj/machinery/computer/communications

/datum/unit_test/crucial_mapping_items/Run()
	setup_expected_types()

	for(var/got_type in expected_types)
		var/datum/map_necessary_item/item = GLOB.crucial_map_items[got_type]
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
