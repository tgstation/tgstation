/// Tests that removing a piece of clothing drops items that hold said piece of clothing
/datum/unit_test/clothing_drops_items

/datum/unit_test/clothing_drops_items/Run()
	test_human()
	test_android()

/datum/unit_test/clothing_drops_items/proc/test_human()
	var/list/dummy_items = allocate_items()
	var/mob/living/carbon/human/consistent/dummy = allocate(__IMPLIED_TYPE__)

	for(var/slot in dummy_items)
		TEST_ASSERT(dummy.equip_to_slot_if_possible(dummy_items[slot], text2num(slot)), \
			"[/datum/species/human::name] Dummy failed to equip one of the starting items ([dummy_items[slot]]). Test aborted.")

	dummy.dropItemToGround(dummy.w_uniform)

	for(var/slot in dummy_items)
		var/obj/item/item = dummy_items[slot]
		if(item.slot_flags & ITEM_SLOT_ICLOTHING)
			continue
		else if(item.slot_flags & (ITEM_SLOT_BACK|ITEM_SLOT_FEET))
			TEST_ASSERT_EQUAL(item.loc, dummy, "[item] should not have been dropped when unequipping the jumpsuit from \a [/datum/species/human::name].")
		else
			TEST_ASSERT_EQUAL(item.loc, dummy.loc, "[item] should have been dropped when unequipping the jumpsuit from \a [/datum/species/human::name].")

/datum/unit_test/clothing_drops_items/proc/test_android()
	var/list/robo_dummy_items = allocate_items()
	var/mob/living/carbon/human/consistent/robo_dummy = allocate(__IMPLIED_TYPE__)
	robo_dummy.set_species(/datum/species/android)

	for(var/slot in robo_dummy_items)
		TEST_ASSERT(robo_dummy.equip_to_slot_if_possible(robo_dummy_items[slot], text2num(slot)), \
			"[/datum/species/android::name] Dummy failed to equip one of the starting items ([robo_dummy_items[slot]]). Test aborted.")

	robo_dummy.dropItemToGround(robo_dummy.w_uniform)

	for(var/slot in robo_dummy_items)
		var/obj/item/item = robo_dummy_items[slot]
		if(item.slot_flags & ITEM_SLOT_ICLOTHING)
			continue
		TEST_ASSERT_EQUAL(item.loc, robo_dummy, "[item] should not have been dropped when unequipping the jumpsuit from \a [/datum/species/android::name].")

/datum/unit_test/clothing_drops_items/proc/allocate_items()
	return list(
		"[ITEM_SLOT_ICLOTHING]" = allocate(/obj/item/clothing/under/color/rainbow), // do this one first, it holds everything
		"[ITEM_SLOT_FEET]" = allocate(/obj/item/clothing/shoes/jackboots),
		"[ITEM_SLOT_BELT]" = allocate(/obj/item/storage/belt/utility),
		"[ITEM_SLOT_BACK]" = allocate(/obj/item/storage/backpack),
		"[ITEM_SLOT_ID]" = allocate(/obj/item/card/id/advanced/gold/captains_spare),
		"[ITEM_SLOT_RPOCKET]" = allocate(/obj/item/assembly/flash/handheld),
		"[ITEM_SLOT_LPOCKET]" = allocate(/obj/item/toy/plush/lizard_plushie),
	)
