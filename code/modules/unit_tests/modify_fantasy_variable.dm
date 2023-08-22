// Unit test to make sure that there are no duplicate keys when modify_fantasy_variable is called when applying fantasy bonuses.
// Also to make sure the fantasy_modifications list is null when fantasy bonuses are removed.
/datum/unit_test/modify_fantasy_variable
	priority = TEST_LONGER

/datum/unit_test/modify_fantasy_variable/Run()
	var/list/applicable_types = subtypesof(/obj/item) - uncreatables

	for(var/obj/item/path as anything in applicable_types)
		var/obj/item/object = allocate(path)
		// objects will have fantasy bonuses inherent to their type (like butterdogs and the slippery component), so we need to take this into account
		var/number_of_extant_bonuses = LAZYLEN(object.fantasy_modifications)

#define TEST_SUCCESS LAZYLEN(object.fantasy_modifications) == number_of_extant_bonuses

		// Try positive
		object.apply_fantasy_bonuses(bonus = 5)
		object.remove_fantasy_bonuses(bonus = 5)
		TEST_ASSERT(TEST_SUCCESS, generate_failure_message(object))

		// Then negative
		object.apply_fantasy_bonuses(bonus = -5)
		object.remove_fantasy_bonuses(bonus = -5)
		TEST_ASSERT(TEST_SUCCESS, generate_failure_message(object))

		// Now try the extremes of each
		object.apply_fantasy_bonuses(bonus = 500)
		object.remove_fantasy_bonuses(bonus = 500)
		TEST_ASSERT(TEST_SUCCESS, generate_failure_message(object))

		object.apply_fantasy_bonuses(bonus = -500)
		object.remove_fantasy_bonuses(bonus = -500)
		TEST_ASSERT(TEST_SUCCESS, generate_failure_message(object))

/// Returns a string that we use to describe the failure of the test.
/datum/unit_test/modify_fantasy_variable/proc/generate_failure_message(obj/item/failed_object)
	var/list/cached_modifications = failed_object.fantasy_modifications
	var/length_of_modifications = LAZYLEN(cached_modifications)
	var/list/failure_messages = list("Error found when adding+removing fantasy bonuses for [failed_object.type].")
	failure_messages += "The length of the fantasy_modifications list was [length_of_modifications]."
	if(length_of_modifications)
		failure_messages += "The fantasy_modifications list was [cached_modifications.Join(", ")]."

	return failure_messages.Join(" ")

#undef TEST_SUCCESS
