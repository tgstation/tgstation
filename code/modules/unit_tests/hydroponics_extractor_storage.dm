/// Unit test to ensure seeds can properly be added to the plant seed extractor through multiple methods.
/// This only tests transferring seeds to the storage, it does NOT test creating seeds.
/datum/unit_test/hydroponics_extractor_storage

/datum/unit_test/hydroponics_extractor_storage/Run()
	var/obj/machinery/seed_extractor/extractor = allocate(/obj/machinery/seed_extractor)
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)

	var/obj/item/storage/bag/plants/storage = allocate(/obj/item/storage/bag/plants)

	// Set up all the seeds we're gonna test storing
	var/list/seeds_to_put_in_the_bag = list(/obj/item/seeds/orange, /obj/item/seeds/lemon)
	var/num_seeds_to_make_of_each = 5
	// Put some seeds in the bag, based on the above variables
	for(var/i in 1 to num_seeds_to_make_of_each)
		for(var/seed_type in seeds_to_put_in_the_bag)
			var/obj/item/seeds/new_seed = new seed_type(dummy.loc)
			storage.atom_storage.attempt_insert(new_seed, dummy)

	// Store the number of seeds we start with in the bag for later.
	var/num_seeds_starting_with = length(storage.contents)
	TEST_ASSERT_EQUAL(num_seeds_starting_with, num_seeds_to_make_of_each * length(seeds_to_put_in_the_bag), "The plant bag failed to populate itself with [num_seeds_to_make_of_each] of each seed.")

	// Put 1 seed into the dummy's hand
	// If they fail to pick up the seed, we have an issue
	var/obj/item/seeds/apple/apple_seed = new(dummy.loc)
	if(!dummy.put_in_active_hand(apple_seed))
		return TEST_FAIL("The dummy failed to pick up the apple seed.")

	// Okay, all our seeds are setup, let's try to insert them
	apple_seed.melee_attack_chain(dummy, extractor)
	// The apple seed should not be in our hands anymore
	TEST_ASSERT_NOTEQUAL(dummy.get_active_held_item(), apple_seed, "The dummy failed to insert a singular seed into the plant seed extractor.")

	// The apple seed should be in the seed extractor now
	var/obj/item/seeds/apple/apple_now_stored = locate() in extractor
	TEST_ASSERT_NOTNULL(apple_now_stored, "The apple seed was removed from the dummy's hands, but is not in the plant seed extractor's contents.")

	// The apple seed's key should be in the extractor's "piles" list
	var/apple_seed_key = extractor.generate_seed_hash(apple_now_stored)
	TEST_ASSERT(apple_seed_key in extractor.piles, "The apple seed was added to the plant seed extractor's contents correctly, but did not register in the piles list, and is unaccessible.")

	// And it should be tracked in the piles list as a weakref
	TEST_ASSERT_EQUAL(length(extractor.piles[apple_seed_key]["refs"]), 1, "While 1 apple seed was added to the plant seed extractor, its weakref was not added to the piles list correctly.")

	// Let's test the plant bag now.
	// If they fail to pick up the bag, we have an issue.
	if(!dummy.put_in_active_hand(storage))
		return TEST_FAIL("The dummy failed to pick up the plant bag.")

	storage.melee_attack_chain(dummy, extractor)
	// We should have 0 seeds remaining in the bag itself.
	var/num_seeds_remaining = length(storage.contents)
	// If the number of seeds in the bag unchanged, no seeds moved, we have an issue as they all failed to move
	TEST_ASSERT(num_seeds_remaining < num_seeds_starting_with, "The plant bag transferred no seeds to the plant seed extractor. (Started with [num_seeds_starting_with], ended with [num_seeds_remaining])")
	// If the number of seeds in the bag went down, but is not 0, we have an issue as some failed to move
	TEST_ASSERT(num_seeds_remaining <= 0, "The plant bag still had [num_seeds_remaining] seeds remaining of the [num_seeds_starting_with] it started with after transferring its seeds to the plant seed extractor.")

	for(var/obj/item/seeds/seed_type as anything in seeds_to_put_in_the_bag)

		// All seeds should be in the extractor now
		var/obj/item/seeds/seed_now_stored = locate(seed_type) in extractor
		TEST_ASSERT_NOTNULL(seed_now_stored, "The plant bag transferred its [initial(seed_type.name)] somewhere, but they were not found in the plant seed extractor.")

		// All keys shold be independently in the piles list
		var/stored_seed_key = extractor.generate_seed_hash(seed_now_stored)
		TEST_ASSERT(stored_seed_key in extractor.piles, "The [initial(seed_type.name)] was added to the plant seed extractor's contents correctly, but did not register in the piles list, and is unaccessible.")

		// And all seeds should be tracked as weakrefs
		TEST_ASSERT_EQUAL(length(extractor.piles[stored_seed_key]["refs"]), num_seeds_to_make_of_each, "While [num_seeds_to_make_of_each] [initial(seed_type.name)]s were added to the plant seed extractor, not all weakrefs were added to the piles list correctly.")
