/**
 * This unit test loops through all cargo crates that are available to purchase, and confirms that they're below the expected sanity minimum when sold.
 * This prevents us from merging a crate that sells for more that it costs to buy.
 */

/datum/unit_test/cargo_crate_sanity

/datum/unit_test/cargo_crate_sanity/Run()
	for(var/datum/supply_pack/new_crate in subtypesof(/datum/supply_pack))
		var/obj/results = new_crate.generate(src)
		var/datum/export_report/export_log = export_item_and_contents(results, apply_elastic = TRUE)
		var/value = counterlist_sum(export_log.total_value)
		TEST_ASSERT(value > CARGO_MINIMUM_COST, "Cargo crate [new_crate.name] had a sale value of [value], lower than [CARGO_MINIMUM_COST]")
