/**
 * For this test, we check a few baseline requirements for cargo to work properly:
 * Do default crates sell for the value of a crate? (CARGO_CRATE_VALUE)
 * Do subtypes sell for their initial cost?
 * And, are there any export datums where their included types explicitly include an excluded type? This will result in a valid thing, not having any export value at all.
 */
/datum/unit_test/cargo_crates_and_exclusions

/datum/unit_test/cargo_crates_and_exclusions/Run()
	var/obj/stock_crate = allocate(/obj/structure/closet/crate)
	var/datum/export_report/crate_report = export_item_and_contents(stock_crate, delete_unsold = TRUE, dry_run = TRUE)
	var/crate_value = counterlist_sum(crate_report.total_value)
	TEST_ASSERT_EQUAL(crate_value, CARGO_CRATE_VALUE, "A stock cargo crate was not worth CARGO_CRATE_VALUE of [CARGO_CRATE_VALUE]!")

	var/obj/subtype_crate = allocate(/obj/structure/closet/crate/coffin)
	var/datum/export_report/subtype_report = export_item_and_contents(subtype_crate, delete_unsold = TRUE, dry_run = TRUE)
	var/subtype_value = counterlist_sum(subtype_report.total_value)
	TEST_ASSERT_EQUAL(subtype_value, /datum/export/crate/coffin::cost, "A crate subtype(coffin) was not worth its export value!")

	for(var/datum/export/this_export as anything in GLOB.exports_list)
		for(var/atom/included_thing as anything in this_export.original_export_types)
			for(var/atom/excluded_thing as anything in this_export.exclude_types)
				if(included_thing.type == excluded_thing.type) //excluded_types exists to weed out subtypes so it's a moot point.
					TEST_FAIL("Export datum [this_export] includes a type [included_thing] that it explicitly excludes [excluded_thing].")
