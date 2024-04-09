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
