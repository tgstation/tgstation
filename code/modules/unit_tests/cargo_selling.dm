/// Makes sure exports work and things can be sold
/datum/unit_test/cargo_selling

/obj/item/storage/box/cargo_unit_test

/obj/item/storage/box/cargo_unit_test/PopulateContents()
	. = ..()
	new /obj/item/food/donkpocket/cargo_unit_test(src)

/obj/item/food/donkpocket/cargo_unit_test

/datum/export/unit_test_box
	unit_name = "unit test box"
	cost = PAYCHECK_LOWER
	export_types = list(/obj/item/storage/box/cargo_unit_test)

/datum/export/unit_test_donk
	unit_name = "unit test donkpocket"
	cost = PAYCHECK_COMMAND
	export_types = list(/obj/item/food/donkpocket/cargo_unit_test)

/datum/unit_test/cargo_selling/Run()
	var/obj/item/storage/box/cargo_unit_test/box = allocate(/obj/item/storage/box/cargo_unit_test)
	var/obj/item/storage/box/cargo_unit_test/box_no_donk =  allocate(/obj/item/storage/box/cargo_unit_test)

	var/datum/export_report/report_one = export_item_and_contents(box, apply_elastic = FALSE)
	if(isnull(report_one))
		TEST_FAIL("called 'export_item_and_contents', but no export report was returned.")
	var/value = counterlist_sum(report_one.total_value)
	TEST_ASSERT_EQUAL(value, PAYCHECK_LOWER + PAYCHECK_COMMAND, "'export_item_and_contents' value didn't match expected value")

	var/datum/export_report/report_two = export_single_item(box_no_donk, apply_elastic = FALSE)
	if(isnull(report_two))
		TEST_FAIL("called 'export_single_item', but no export report was returned.")
	value = counterlist_sum(report_two.total_value)
	TEST_ASSERT_EQUAL(value, PAYCHECK_LOWER, "'export_single_item' value didn't match expected value")
