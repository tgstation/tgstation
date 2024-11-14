/// Makes sure exports work and things can be sold
/datum/unit_test/cargo_selling

/obj/item/cargo_unit_test_container

/obj/item/cargo_unit_test_container/Initialize(mapload)
	. = ..()
	new /obj/item/cargo_unit_test_content(src)

/obj/item/cargo_unit_test_content

/datum/export/cargo_unit_test_container
	cost = PAYCHECK_LOWER
	export_types = list(/obj/item/cargo_unit_test_container)

/datum/export/cargo_unit_test_content
	cost = PAYCHECK_COMMAND
	export_types = list(/obj/item/cargo_unit_test_content)

/datum/unit_test/cargo_selling/Run()
	var/obj/item/cargo_unit_test_container/box = allocate(/obj/item/cargo_unit_test_container)
	var/obj/item/cargo_unit_test_container/box_skip_content = allocate(/obj/item/cargo_unit_test_container)

	var/datum/export_report/report_one = export_item_and_contents(box, apply_elastic = FALSE)
	if(isnull(report_one))
		TEST_FAIL("called 'export_item_and_contents', but no export report was returned.")
	var/value = counterlist_sum(report_one.total_value)
	TEST_ASSERT_EQUAL(value, PAYCHECK_LOWER + PAYCHECK_COMMAND, "'export_item_and_contents' value didn't match expected value")

	var/datum/export_report/report_two = export_single_item(box_skip_content, apply_elastic = FALSE)
	if(isnull(report_two))
		TEST_FAIL("called 'export_single_item', but no export report was returned.")
	value = counterlist_sum(report_two.total_value)
	TEST_ASSERT_EQUAL(value, PAYCHECK_LOWER, "'export_single_item' value didn't match expected value")
