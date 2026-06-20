/**
 * This unit test crates a boulder, spawns it, and then moves it through boulder processing to confirm that boulders can be processed without issue.
 */

/datum/unit_test/boulder_processing

/datum/unit_test/boulder_processing/Run()

    // Spawn a random ore_vent and generate a boulder from it.
    var/obj/structure/ore_vent/vent = allocate(/obj/structure/ore_vent/starter_resources)
    var/obj/item/boulder/boulder = vent.produce_boulder(FALSE)

	// for(var/crate in subtypesof(/datum/supply_pack))
	// 	var/datum/supply_pack/new_crate = allocate(crate)
	// 	if(new_crate.test_ignored)
	// 		continue // We can safely ignore custom supply packs like the stock market or mining supply crates, or packs that have innate randomness.
	// 	if(!new_crate?.crate_type)
	// 		continue
	// 	var/obj/crate_type = allocate(new_crate.crate_type)
	// 	var/turf/open/floor/testing_floor = get_turf(crate_type)
	// 	var/datum/export_report/minimum_cost = export_item_and_contents(crate_type, delete_unsold = TRUE, dry_run = TRUE)
	// 	var/crate_value = counterlist_sum(minimum_cost.total_value)

	// 	var/obj/results = new_crate.generate(testing_floor)
	// 	if(!results)
	// 		TEST_FAIL("Cargo crate [new_crate.type] failed to generate an object to export.")
	// 	var/datum/export_report/export_log = export_item_and_contents(results, apply_elastic = TRUE, delete_unsold = TRUE, export_markets = list(EXPORT_MARKET_STATION))

	// 	// The value of the crate and all of it's contents.
	// 	var/value = counterlist_sum(export_log.total_value)

	// 	// We're selling the crate and it's contents for more value than it's supply_pack costs.
	// 	if(value > new_crate.get_cost())
	// 		TEST_FAIL("Cargo crate [new_crate.type] had a sale value of [value], Selling for more than [new_crate.get_cost()], the cost to buy")

	// 	// We're selling the crate & it's contents for less than the value of it's own crate, meaning you can buy and infinite number
	// 	if(crate_value > new_crate.get_cost())
	// 		TEST_FAIL("Cargo crate [new_crate.type] container sells for [crate_value], Selling for more than [new_crate.get_cost()], the cost to buy")
	// 	for(var/atom/stuff as anything in results.contents)
	// 		qdel(stuff)
	// 		stuff = null

	// 	qdel(results)
	// 	results =  null
	// 	new_crate = null
	// 	minimum_cost = null
	// 	export_log = null
