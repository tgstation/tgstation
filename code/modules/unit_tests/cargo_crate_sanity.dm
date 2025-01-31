/**
 * This unit test loops through all cargo crates that are available to purchase, and confirms that they're below the expected sanity minimum when sold.
 * This prevents us from merging a crate that sells for more that it costs to buy.
 */

/datum/unit_test/cargo_crate_sanity

/datum/unit_test/cargo_crate_sanity/Run()
	for(var/crate in subtypesof(/datum/supply_pack))
		var/datum/supply_pack/new_crate = new crate
		if(!new_crate?.crate_type)
			continue

		var/minimum_cost = export_item_and_contents(target, dry_run = TRUE)

		var/obj/results = allocate(new_crate.generate(src))
		var/datum/export_report/export_log = export_item_and_contents(results, apply_elastic = TRUE)
		var/value = counterlist_sum(export_log.total_value)
		if(value > CARGO_MINIMUM_COST)
			TEST_FAIL("Cargo crate [new_crate.name] had a sale value of [value], lower than [CARGO_MINIMUM_COST]")
		if(value < new_crate.get_cost())
			TEST_FAIL("Cargo crate [new_crate.name] had a sale value of [value], greater than [new_crate.get_cost()]")
