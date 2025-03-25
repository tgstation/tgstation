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

// Tests that equip equip works
/datum/unit_test/quick_equip

/datum/unit_test/quick_equip/Run()
	var/mob/living/carbon/human/consistent/dummy = allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)
	var/obj/item/clothing/under/pants/jeans = allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)

	dummy.equip_to_appropriate_slot(jeans)

	var/obj/item/assembly/flash/handheld/flash_one = allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)

	dummy.put_in_active_hand(flash_one)
	dummy.execute_quick_equip()

	TEST_ASSERT_EQUAL(dummy.l_store, flash_one, "Quick equip failed to equip the first flash to the left pocket")

	var/obj/item/assembly/flash/handheld/flash_two = allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)

	dummy.put_in_active_hand(flash_two)
	dummy.execute_quick_equip()

	TEST_ASSERT_EQUAL(dummy.r_store, flash_two, "Quick equip failed to equip the second flash to the right pocket")

	var/obj/item/assembly/flash/handheld/flash_three = allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)

	dummy.put_in_active_hand(flash_three)
	dummy.execute_quick_equip()

	TEST_ASSERT_EQUAL(dummy.get_active_held_item(), flash_three, "Quick equip should have left the third flash in the active hand")

/// Tests that quick equip respects storage blacklists
/datum/unit_test/quick_equip_respects_storage

/datum/unit_test/quick_equip_respects_storage/Run()
	var/obj/item/storage/backpack/storage_item =  allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/consistent/dummy = allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)

	dummy.equip_to_appropriate_slot(storage_item)

	var/obj/item/assembly/flash/handheld/flash_one = allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)

	dummy.put_in_active_hand(flash_one)
	dummy.execute_quick_equip()

	TEST_ASSERT_EQUAL(flash_one.loc, storage_item, "Quick equip failed to equip the first flash to the storage item")

	var/obj/item/assembly/flash/handheld/flash_two = allocate(__IMPLIED_TYPE__, run_loc_floor_bottom_left)

	storage_item.atom_storage.cant_hold = typecacheof(list(/obj/item/assembly/flash/handheld))
	dummy.put_in_active_hand(flash_two)
	dummy.execute_quick_equip()

	TEST_ASSERT_EQUAL(dummy.get_active_held_item(), flash_two, "Quick equip should have left the second flash in the active hand")
