// Unit test to make sure that there are no duplicate keys when modify_fantasy_variable is called when applying fantasy bonuses.
// Also to make sure the fantasy_modifications list is null when fantasy bonuses are removed.
/datum/unit_test/modify_fantasy_variable

/datum/unit_test/modify_fantasy_variable/Run()
	var/list/applicable_types = subtypesof(/obj/item) - uncreatables

	for(var/obj/item/path as anything in applicable_types)
		var/obj/item/object = allocate(path)
		// objects will have fantasy bonuses inherent to their type (like butterdogs and the slippery component), so we need to take this into account
		var/number_of_extant_bonuses = LAZYLEN(object.fantasy_modifications)

		// Try positive
		object.apply_fantasy_bonuses(bonus = 5)
		object.remove_fantasy_bonuses(bonus = 5)
		TEST_ASSERT_EQUAL(LAZYLEN(object.fantasy_modifications), number_of_extant_bonuses, "Duplicate fantasy bonuses were added to [object.type] when fantasy bonuses were applied and removed (with positive values).")

		// Then negative
		object.apply_fantasy_bonuses(bonus = -5)
		object.remove_fantasy_bonuses(bonus = -5)
		TEST_ASSERT_EQUAL(LAZYLEN(object.fantasy_modifications), number_of_extant_bonuses, "Duplicate fantasy bonuses were added to [object.type] when fantasy bonuses were applied and removed (with negative values).")

		// Now try the extremes of each
		object.apply_fantasy_bonuses(bonus = 500)
		object.remove_fantasy_bonuses(bonus = 500)
		TEST_ASSERT_EQUAL(LAZYLEN(object.fantasy_modifications), number_of_extant_bonuses, "Duplicate fantasy bonuses were added to [object.type] when fantasy bonuses were applied and removed (with positive extreme values).")

		object.apply_fantasy_bonuses(bonus = -500)
		object.remove_fantasy_bonuses(bonus = -500)
		TEST_ASSERT_EQUAL(LAZYLEN(object.fantasy_modifications), number_of_extant_bonuses, "Duplicate fantasy bonuses were added to [object.type] when fantasy bonuses were applied and removed (with negative extreme values).")
