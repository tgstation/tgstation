
/datum/unit_test/cargo_crates

/datum/unit_test/cargo_crates/Run()
	var/obj/stock_crate = allocate(/obj/structure/closet/crate)
	var/datum/export_report/crate_report = export_item_and_contents(stock_crate, delete_unsold = TRUE, dry_run = TRUE)
	var/crate_value = counterlist_sum(crate_report.total_value)
	if(crate_value != CARGO_CRATE_VALUE)
		TEST_FAIL("A stock cargo crate was not worth CARGO_CRATE_VALUE of [CARGO_CRATE_VALUE]!")

	var/obj/subtype_crate = allocate(/obj/structure/closet/crate/coffin)
	var/datum/export_report/subtype_report = export_item_and_contents(subtype_crate, delete_unsold = TRUE, dry_run = TRUE)
	var/subtype_value = counterlist_sum(subtype_report.total_value)
	if(subtype_value != /datum/export/crate/coffin::cost)
		TEST_FAIL("A crate subtype(coffin) was not worth its export value!")
