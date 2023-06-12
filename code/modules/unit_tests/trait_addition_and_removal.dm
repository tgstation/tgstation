/// Simple Unit Test to ensure multiple methods of adding/removing a trait work as intended.
/datum/unit_test/trait_addition_and_removal

#define TRAIT_UNIT_TEST_MAIN "trait_main"
#define TRAIT_UNIT_TEST_ALT "trait_alternate"
#define TRAIT_UNIT_TEST_A "trait_a"
#define TRAIT_UNIT_TEST_B "trait_b"
#define TRAIT_UNIT_TEST_C "trait_c"
#define UNIT_TEST_SOURCE_MAIN "source_main"
#define UNIT_TEST_SOURCE_ALT "source_alt"
#define UNIT_TEST_SOURCE_A "source_a"
#define UNIT_TEST_SOURCE_B "source_b"

/datum/unit_test/trait_addition_and_removal/Run()
	var/datum/trait_target = allocate(/datum) // traits work on the datum-level, so use a datum to ensure that it'll work on all children

	// We want to ensure that what we add is also removed when we're done with our "block" of tests, if it starts to get messy we might just have to reset the datum between tests to ensure cleanliness

	// The basics, if these fail burn down the codebase
	ADD_TRAIT(trait_target, TRAIT_UNIT_TEST_A, UNIT_TEST_SOURCE_A)
	TEST_ASSERT(HAS_TRAIT(trait_target, TRAIT_UNIT_TEST_A), "Basic trait addition failed for [TRAIT_UNIT_TEST_A], source being [UNIT_TEST_SOURCE_A]!")

	ADD_TRAIT(trait_target, TRAIT_UNIT_TEST_B, UNIT_TEST_SOURCE_B)
	TEST_ASSERT(HAS_TRAIT(trait_target, TRAIT_UNIT_TEST_B), "Basic trait addition failed for [TRAIT_UNIT_TEST_B], source being [UNIT_TEST_SOURCE_B]!")
	TEST_ASSERT(HAS_TRAIT_FROM(trait_target, TRAIT_UNIT_TEST_B, UNIT_TEST_SOURCE_B), "Failed to verify source for [TRAIT_UNIT_TEST_B], expected source being [UNIT_TEST_SOURCE_B]!")
	TEST_ASSERT(HAS_TRAIT_NOT_FROM(trait_target, TRAIT_UNIT_TEST_B, UNIT_TEST_SOURCE_A), "Failed to verify source for [TRAIT_UNIT_TEST_B], expected source being [UNIT_TEST_SOURCE_B] but was actually [UNIT_TEST_SOURCE_A]!")

	REMOVE_TRAIT(trait_target, TRAIT_UNIT_TEST_B, UNIT_TEST_SOURCE_B)
	TEST_ASSERT(!HAS_TRAIT(trait_target, TRAIT_UNIT_TEST_B), "Basic trait removal failed for [TRAIT_UNIT_TEST_B], source being [UNIT_TEST_SOURCE_B]!")
	TEST_ASSERT(HAS_TRAIT(trait_target, TRAIT_UNIT_TEST_A), "Trait [TRAIT_UNIT_TEST_A] was removed when it shouldn't have been!")
	REMOVE_TRAIT(trait_target, TRAIT_UNIT_TEST_A, UNIT_TEST_SOURCE_A)

	// Test adding the trait multiple times from different sources
	ADD_TRAIT(trait_target, TRAIT_UNIT_TEST_MAIN, UNIT_TEST_SOURCE_A)
	ADD_TRAIT(trait_target, TRAIT_UNIT_TEST_MAIN, UNIT_TEST_SOURCE_B)
	TEST_ASSERT(!HAS_TRAIT_FROM_ONLY(trait_target, TRAIT_UNIT_TEST_MAIN, UNIT_TEST_SOURCE_A), "Failed to recognize that [TRAIT_UNIT_TEST_MAIN] was added by both [UNIT_TEST_SOURCE_A] and [UNIT_TEST_SOURCE_B]!")

	// as well as its removal
	REMOVE_TRAIT_NOT_FROM(trait_target, TRAIT_UNIT_TEST_MAIN, UNIT_TEST_SOURCE_A)
	TEST_ASSERT(!HAS_TRAIT_FROM(trait_target, TRAIT_UNIT_TEST_MAIN, UNIT_TEST_SOURCE_B), "Failed to remove [TRAIT_UNIT_TEST_MAIN] with [UNIT_TEST_SOURCE_B] when removal was expected!")
	TEST_ASSERT(HAS_TRAIT(trait_target, TRAIT_UNIT_TEST_MAIN), "[TRAIT_UNIT_TEST_MAIN] was completely removed when it should not have been!")
	REMOVE_TRAIT(trait_target, TRAIT_UNIT_TEST_MAIN, UNIT_TEST_SOURCE_A)
	TEST_ASSERT(!HAS_TRAIT(trait_target, TRAIT_UNIT_TEST_MAIN), "[TRAIT_UNIT_TEST_MAIN] was not removed when it should have been!")

	// Test adding multiple traits from the same source
	ADD_TRAIT(trait_target, TRAIT_UNIT_TEST_A, UNIT_TEST_SOURCE_MAIN)
	ADD_TRAIT(trait_target, TRAIT_UNIT_TEST_B, UNIT_TEST_SOURCE_MAIN)
	TEST_ASSERT(HAS_TRAIT(trait_target, TRAIT_UNIT_TEST_B), "Failed to add [TRAIT_UNIT_TEST_B] with common source [UNIT_TEST_SOURCE_MAIN]!")

	ADD_TRAIT(trait_target, TRAIT_UNIT_TEST_C, UNIT_TEST_SOURCE_ALT)
	REMOVE_TRAITS_NOT_IN(trait_target, UNIT_TEST_SOURCE_MAIN)
	TEST_ASSERT(!HAS_TRAIT(trait_target, TRAIT_UNIT_TEST_C), "Failed to remove [TRAIT_UNIT_TEST_C] when expected to be removed with remove_traits_NOT_IN(), was added with source [UNIT_TEST_SOURCE_ALT]!")

	// as well as its removal
	REMOVE_TRAITS_IN(trait_target, UNIT_TEST_SOURCE_MAIN)
	TEST_ASSERT(!HAS_TRAIT(trait_target, TRAIT_UNIT_TEST_A), "Failed to remove [TRAIT_UNIT_TEST_A] with common source [UNIT_TEST_SOURCE_MAIN]!")
	TEST_ASSERT(!HAS_TRAIT(trait_target, TRAIT_UNIT_TEST_B), "Failed to remove [TRAIT_UNIT_TEST_B] with common source [UNIT_TEST_SOURCE_MAIN]!")

	// Lastly, let's ensure that adding/removing traits using lists still works.
	var/static/list/standardized_traits_list = list(TRAIT_UNIT_TEST_A, TRAIT_UNIT_TEST_B, TRAIT_UNIT_TEST_C)
	trait_target.add_traits(standardized_traits_list, UNIT_TEST_SOURCE_MAIN)
	for(var/trait in standardized_traits_list)
		TEST_ASSERT(HAS_TRAIT(trait_target, trait), "Failed to add [trait] when using add_traits() using [UNIT_TEST_SOURCE_MAIN]!")
	trait_target.remove_traits(standardized_traits_list, UNIT_TEST_SOURCE_MAIN)
	for(var/trait in standardized_traits_list)
		TEST_ASSERT(!HAS_TRAIT(trait_target, trait), "Failed to remove [trait] when using remove_traits() using [UNIT_TEST_SOURCE_MAIN]!")

	// As well as ensure mixing-and-matching types of trait addition/removal works.
	ADD_TRAIT(trait_target, TRAIT_UNIT_TEST_A, UNIT_TEST_SOURCE_MAIN)
	ADD_TRAIT(trait_target, TRAIT_UNIT_TEST_B, UNIT_TEST_SOURCE_MAIN)
	trait_target.remove_traits(standardized_traits_list, UNIT_TEST_SOURCE_MAIN)
	TEST_ASSERT(!HAS_TRAIT(trait_target, TRAIT_UNIT_TEST_A), "Failed to remove [TRAIT_UNIT_TEST_A] when using remove_traits() using [UNIT_TEST_SOURCE_MAIN] (was added using ADD_TRAIT())!")
	TEST_ASSERT(!HAS_TRAIT(trait_target, TRAIT_UNIT_TEST_B), "Failed to remove [TRAIT_UNIT_TEST_B] when using remove_traits() using [UNIT_TEST_SOURCE_MAIN] (was added using ADD_TRAIT())!")
	TEST_ASSERT(!HAS_TRAIT(trait_target, TRAIT_UNIT_TEST_C), "[TRAIT_UNIT_TEST_C] somehow came into existence when using remove_traits() using [UNIT_TEST_SOURCE_MAIN] (what the actual fuck)!")

	trait_target.add_traits(standardized_traits_list, UNIT_TEST_SOURCE_MAIN)
	REMOVE_TRAIT(trait_target, TRAIT_UNIT_TEST_A, UNIT_TEST_SOURCE_MAIN)
	REMOVE_TRAIT(trait_target, TRAIT_UNIT_TEST_B, UNIT_TEST_SOURCE_MAIN)
	TEST_ASSERT(!HAS_TRAIT(trait_target, TRAIT_UNIT_TEST_A), "Failed to remove [TRAIT_UNIT_TEST_A] when using REMOVE_TRAIT() using [UNIT_TEST_SOURCE_MAIN] (was added using add_traits())!")
	TEST_ASSERT(!HAS_TRAIT(trait_target, TRAIT_UNIT_TEST_B), "Failed to remove [TRAIT_UNIT_TEST_B] when using REMOVE_TRAIT() using [UNIT_TEST_SOURCE_MAIN] (was added using add_traits())!")
	TEST_ASSERT(HAS_TRAIT(trait_target, TRAIT_UNIT_TEST_C), "[TRAIT_UNIT_TEST_C] was unexpectedly removed when using REMOVE_TRAIT() using [UNIT_TEST_SOURCE_MAIN] (was added using add_traits())!")
	REMOVE_TRAIT(trait_target, TRAIT_UNIT_TEST_C, UNIT_TEST_SOURCE_MAIN) //just for cleanliness+completeness

	TEST_ASSERT(!length(trait_target._status_traits), "Failed to clean up all status traits at the end of the unit test!")

#undef TRAIT_UNIT_TEST_MAIN
#undef TRAIT_UNIT_TEST_ALT
#undef TRAIT_UNIT_TEST_A
#undef TRAIT_UNIT_TEST_B
#undef TRAIT_UNIT_TEST_C
#undef UNIT_TEST_SOURCE_MAIN
#undef UNIT_TEST_SOURCE_ALT
#undef UNIT_TEST_SOURCE_A
#undef UNIT_TEST_SOURCE_B
