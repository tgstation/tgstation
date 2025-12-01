/**
 * Check that standard food items fit on the serving tray
 */
/datum/unit_test/servingtray/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	var/obj/structure/table/the_table = allocate(/obj/structure/table)
	var/obj/item/storage/bag/tray/test_tray = allocate(/obj/item/storage/bag/tray)
	var/obj/item/food/banana = allocate(/obj/item/food/rationpack)
	var/obj/item/food/the_bread = allocate(/obj/item/food/breadslice)
	var/obj/item/food/sugarcookie = allocate(/obj/item/food/cookie/sugar)
	var/obj/item/clothing/under/jumpsuit = allocate(/obj/item/clothing/under/color/black)

	TEST_ASSERT_EQUAL((the_bread in test_tray.contents), FALSE, "The bread is on the serving tray at test start")

	// set the tray to single item mode the dirty way
	var/datum/storage/tray_storage = test_tray.atom_storage
	tray_storage.collection_mode = COLLECT_ONE

	test_tray.melee_attack_chain(human, the_bread)

	TEST_ASSERT_EQUAL((the_bread in test_tray.contents), TRUE, "The bread did not get picked up by the serving tray")

	test_tray.melee_attack_chain(human, banana)

	TEST_ASSERT_EQUAL((banana in test_tray.contents), TRUE, "The banana did not get picked up by the serving tray")

	test_tray.melee_attack_chain(human, the_table)

	TEST_ASSERT_EQUAL(test_tray.contents.len, 0, "The serving tray did not drop all items on hitting the table")

	test_tray.melee_attack_chain(human, sugarcookie)

	TEST_ASSERT_EQUAL((sugarcookie in test_tray.contents), TRUE, "The sugarcookie did not get picked up by the serving tray")

	human.equip_to_slot(jumpsuit, ITEM_SLOT_ICLOTHING)
	TEST_ASSERT(human.get_item_by_slot(ITEM_SLOT_ICLOTHING), "Human does not have jumpsuit on")

	human.equip_to_slot(test_tray, ITEM_SLOT_LPOCKET)
	TEST_ASSERT(human.get_item_by_slot(ITEM_SLOT_LPOCKET), "Serving tray failed to fit in the Left Pocket")

	human.equip_to_slot(test_tray, ITEM_SLOT_RPOCKET)
	TEST_ASSERT(human.get_item_by_slot(ITEM_SLOT_RPOCKET), "Serving tray failed to fit in the Right Pocket")

	test_tray.melee_attack_chain(human, human)

	TEST_ASSERT_EQUAL(test_tray.contents.len, 0, "The serving tray did not drop all items on hitting a human")
