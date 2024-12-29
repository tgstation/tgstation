/// Test storage datums
/datum/unit_test/storage

/datum/unit_test/storage/Run()
	var/obj/item/big_thing = allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)
	big_thing.w_class = WEIGHT_CLASS_BULKY
	var/obj/item/small_thing =  allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)
	small_thing.w_class = WEIGHT_CLASS_SMALL

	var/obj/item/storage/backpack/storage_item =  allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)

	storage_item.atom_storage.attempt_insert(big_thing)
	TEST_ASSERT_NOTEQUAL(big_thing.loc, storage_item, "A bulky item should have failed to insert into a backpack")

	storage_item.atom_storage.attempt_insert(small_thing)
	TEST_ASSERT_EQUAL(small_thing.loc, storage_item, "A small item should have successfully inserted into a backpack")

	small_thing.update_weight_class(WEIGHT_CLASS_NORMAL)
	TEST_ASSERT_EQUAL(small_thing.loc, storage_item, "A small item changed into normal size should not have ejected from the backpack")

	small_thing.update_weight_class(WEIGHT_CLASS_BULKY)
	TEST_ASSERT_NOTEQUAL(small_thing.loc, storage_item, "A small item changed back into bulky size should have ejected from the backpack")

/datum/unit_test/common_item_inserting

/datum/unit_test/common_item_inserting/Run()
	var/obj/item/storage/backpack/bag = allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/consistent/dummy = allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)
	bag.atom_storage.max_slots = INFINITY
	bag.atom_storage.max_total_storage = INFINITY

	var/list/common_noncombat_insertion_items = list(
		/obj/item/reagent_containers/cup/rag,
		/obj/item/soap,
		/obj/item/card/emag,
		/obj/item/detective_scanner,
	)

	dummy.set_combat_mode(TRUE)
	for(var/item_type in common_noncombat_insertion_items)
		var/obj/item/item = allocate(item_type, run_loc_floor_bottom_left)
		item.melee_attack_chain(dummy, bag)
		TEST_ASSERT_EQUAL(item.loc, bag, "[item_type] was unable to be inserted into a backpack on click while off combat mode")

/// Test to ensure that all storage containers have enough space to hold any items they spawn in with.
/// A backpack with only 14 slots should not be able to hold 16 items, as an example. (this also checks for weight)
/datum/unit_test/storage_sanity
	///list of debug exempted storage items (these shouldn't spawn naturally anyawys)
	var/static/list/debug_list = typecacheof(list(
		/obj/item/storage/box/miner_modkits,
		/obj/item/storage/box/skillchips,
		/obj/item/storage/box/stockparts/basic,
		/obj/item/storage/box/stockparts/deluxe,
		/obj/item/storage/box/fish_debug,
	))

/datum/unit_test/storage_sanity/Run()
	for(var/storage in subtypesof(/obj/item/storage))
		var/obj/item/storage/storage_item = allocate(storage)
		var/datum/storage/storage_type = storage_item.atom_storage

		if(is_type_in_typecache(storage, debug_list))
			continue

		var/list/storage_contents = storage_item.contents
		var/total_weight_in_storage //We shouldn't have to deal with items being heavier than weight limit due to the other unit test
		var/contents_counter

		for(var/obj/item/items as anything in storage_contents)
			total_weight_in_storage += items.w_class
			contents_counter++

		if(storage_type == null)
			TEST_FAIL("[storage_item] ([storage_item.type]) has no storage /datum/")
			continue

		if(storage_type.max_slots < contents_counter)
			TEST_FAIL("[storage_item] ([storage_item.type]) has loaded slots of [contents_counter], but only holds a max slot of [storage_type.max_slots].")

		if(storage_type.max_total_storage < total_weight_in_storage)
			TEST_FAIL("[storage_item] ([storage_item.type]) has a total weight of [total_weight_in_storage], but only holds a max weight of [storage_type.max_total_storage].")
