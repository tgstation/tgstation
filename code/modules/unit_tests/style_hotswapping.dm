/// Ensures that hotswapping only occurs when hitting inventory items and allows item interactions to go through
/datum/unit_test/style_hotswapping

/datum/unit_test/style_hotswapping/Run()
	var/mob/living/carbon/human/john_ultrakill = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/storage/backpack/bag = allocate(__IMPLIED_TYPE__, john_ultrakill.loc)
	john_ultrakill.equip_to_slot(bag, ITEM_SLOT_BACK)
	TEST_ASSERT_EQUAL(john_ultrakill.get_item_by_slot(ITEM_SLOT_BACK), bag, "Human wasn't able to equip a backpack!")
	var/datum/component/style/style = john_ultrakill.AddComponent(/datum/component/style)
	try_stabilize(john_ultrakill, john_ultrakill.loc, "while it was on the user's turf")
	try_stabilize(john_ultrakill, bag, "while it was in the user's bag")
	var/obj/item/coin/gold/coin_one = allocate(__IMPLIED_TYPE__, john_ultrakill.loc)
	var/obj/item/coin/silver/coin_two = allocate(__IMPLIED_TYPE__, john_ultrakill.loc)
	coin_two.forceMove(bag)
	john_ultrakill.put_in_active_hand(coin_one, TRUE)
	TEST_ASSERT_EQUAL(john_ultrakill.get_active_held_item(), coin_one, "Human wasn't able to pick up a gold coin!")
	john_ultrakill.ClickOn(coin_two)
	TEST_ASSERT_EQUAL(john_ultrakill.get_active_held_item(), coin_one, "Human hotswapped from their storage despite not having enough points!")
	john_ultrakill.next_click = 0
	john_ultrakill.next_move = 0
	john_ultrakill.temporarilyRemoveItemFromInventory(coin_one, TRUE)
	QDEL_NULL(coin_one)
	style.style_points = INFINITY
	style.update_screen(style.point_to_rank())
	try_stabilize(john_ultrakill, john_ultrakill.loc, "while it was on the user's turf with hotswapping active")
	try_stabilize(john_ultrakill, bag, "while it was in the user's bag with hotswapping active")
	coin_one = allocate(__IMPLIED_TYPE__, john_ultrakill.loc)
	john_ultrakill.put_in_active_hand(coin_one, TRUE)
	TEST_ASSERT_EQUAL(john_ultrakill.get_active_held_item(), coin_one, "Human wasn't able to pick up a gold coin!")
	john_ultrakill.ClickOn(coin_two)
	TEST_ASSERT_EQUAL(john_ultrakill.get_active_held_item(), coin_two, "Human wasn't able to hotswap with their storage!")

/datum/unit_test/style_hotswapping/proc/try_stabilize(mob/living/carbon/human/john_ultrakill, core_loc, desc = null)
	var/obj/item/organ/monster_core/regenerative_core/legion/core = allocate(__IMPLIED_TYPE__, john_ultrakill.loc)
	core.forceMove(core_loc)
	TEST_ASSERT(core.decay_timer, "Legion core spawned without a decay timer!")
	var/obj/item/mining_stabilizer/serum = allocate(__IMPLIED_TYPE__, john_ultrakill.loc)
	john_ultrakill.put_in_active_hand(serum, TRUE)
	TEST_ASSERT_EQUAL(john_ultrakill.get_active_held_item(), serum, "Human wasn't able to pick up a stabilizer serum!")
	john_ultrakill.ClickOn(core)
	TEST_ASSERT(!core.decay_timer, "Clicking on a legion core with a serum did not stabilize it [desc]!")
	john_ultrakill.next_click = 0
	john_ultrakill.next_move = 0
