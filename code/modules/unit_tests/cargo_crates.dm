
/datum/unit_test/cargo_crates

	var/obj/structure/closet/crate/stock_crate = allocate(stock_crate)
	var/datum/export_report/crate_report = export_item_and_contents(stock_crate, delete_unsold = TRUE, dry_run = TRUE)
	var/crate_value = counterlist_sum(minimum_cost.total_value)

	if(crate_value != CARGO_CRATE_VALUE)
		TEST_FAIL("A stock cargo crate was not worth CARGO_CRATE_VALUE of [CARGO_CRATE_VALUE]!")

	//Subtypes
	var/obj/structure/closet/crate/coffin/subtype = allocate(subtype)
	var/datum/export_report/subtype_report = export_item_and_contents(subtype, delete_unsold = TRUE, dry_run = TRUE)
	var/subtype_value = counterlist_sum(minimum_cost.total_value)

	if(subtype_value != /datum/export/crate/coffin::cost)
		TEST_FAIL("A crate subtype(coffin) was not worth it's export value!")
