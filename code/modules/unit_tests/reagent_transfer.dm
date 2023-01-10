/// Tests transferring reagents between two reagents datums.
/datum/unit_test/reagent_transfer

/datum/unit_test/reagent_transfer/Run()
	var/datum/reagents/source_reagents = allocate(/datum/reagents, 100)
	var/datum/reagents/target_reagents = allocate(/datum/reagents, 100)

	// Quick test to make sure reagents add properly.
	source_reagents.add_reagent(/datum/reagent/water, 10)
	TEST_ASSERT_EQUAL(length(source_reagents.reagent_list), 1, "Source reagents has [length(source_reagents.reagent_list)] unique reagents (expected 1).")
	TEST_ASSERT_EQUAL(source_reagents.total_volume, 10, "Source reagents has incorrect total_volume [source_reagents.total_volume] (expected 10).")

	// Test to make sure the water reagent was added correctly.
	var/datum/reagent/water/water_reagent = source_reagents.reagent_list[1]
	TEST_ASSERT(istype(water_reagent), "Incorrect reagent type detected source reagents: [water_reagent.type] (expected /datum/reagent/water).")
	TEST_ASSERT_EQUAL(water_reagent.volume, 10, "Source reagents has [water_reagent.volume] reagent volume (expected 10).")

	// Test to make sure reagents transfer properly.
	source_reagents.trans_to(target_reagents, 10)
	TEST_ASSERT_EQUAL(length(source_reagents.reagent_list), 0, "Source reagents has [length(source_reagents.reagent_list)] unique reagents after transfer (expected 0, possible duplication?)")
	TEST_ASSERT_EQUAL(length(target_reagents.reagent_list), 1, "Target reagents has [length(target_reagents.reagent_list)] unique reagents after transfer (expected 1).")
	TEST_ASSERT_EQUAL(target_reagents.total_volume, 10, "Target reagents has incorrect total_volume [source_reagents.total_volume] (expected 10).")

	water_reagent = target_reagents.reagent_list[1]
	TEST_ASSERT(istype(water_reagent), "Incorrect reagent type detected in target reagents after transfer: [water_reagent.type] (should be /datum/reagent/water).")
	TEST_ASSERT_EQUAL(water_reagent.volume, 10, "Target reagents has [water_reagent.volume] reagent volume (expected 10)")
