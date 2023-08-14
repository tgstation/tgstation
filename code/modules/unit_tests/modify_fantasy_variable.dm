// Unit test to make sure that there are no duplicate keys when modify_fantasy_variable is called when applying fantasy bonuses.
// Also to make sure the fantasy_modifications list is null when fantasy bonuses are removed.
/datum/unit_test/modify_fantasy_variable/Run()

	for(var/obj/item/path as anything in subtypesof(/obj/item))
		var/obj/item/object = allocate(path)
		// Try positive
		object.apply_fantasy_bonuses(bonus = 5)
		object.remove_fantasy_bonuses(bonus = 5)
		TEST_ASSERT_NULL(object.fantasy_modifications, "Fantasy modifications list is not null when fantasy bonuses are removed (with positive values).")
		// Then negative
		object.apply_fantasy_bonuses(bonus = -5)
		object.remove_fantasy_bonuses(bonus = -5)
		TEST_ASSERT_NULL(object.fantasy_modifications, "Fantasy modifications list is not null when fantasy bonuses are removed (with negative values).")
		// Now try the extremes of each
		object.apply_fantasy_bonuses(bonus = 500)
		object.remove_fantasy_bonuses(bonus = 500)
		TEST_ASSERT_NULL(object.fantasy_modifications, "Fantasy modifications list is not null when fantasy bonuses are removed (with positive extreme values).")
		object.apply_fantasy_bonuses(bonus = -500)
		object.remove_fantasy_bonuses(bonus = -500)
		TEST_ASSERT_NULL(object.fantasy_modifications, "Fantasy modifications list is not null when fantasy bonuses are removed (with negative extreme values).")
