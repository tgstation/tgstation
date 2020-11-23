/// Test that quick swap correctly swaps items and invalidates suit storage
/datum/unit_test/quick_swap_suit_storage/Run()
	// Create a human with a medical winter coat and a health analyzer in suit storage
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)

	var/obj/item/coat = allocate(/obj/item/clothing/suit/hooded/wintercoat/medical)
	TEST_ASSERT(human.equip_to_slot_if_possible(coat, ITEM_SLOT_OCLOTHING), "Couldn't equip winter coat")

	var/obj/item/analyzer = allocate(/obj/item/healthanalyzer)
	TEST_ASSERT(human.equip_to_slot_if_possible(analyzer, ITEM_SLOT_SUITSTORE), "Couldn't equip health analyzer")

	// Then, have them quick swap between the coat and a space suit
	var/obj/item/hardsuit = allocate(/obj/item/clothing/suit/space/hardsuit)
	TEST_ASSERT(human.equip_to_appropriate_slot(hardsuit, swap = TRUE), "Couldn't quick swap to hardsuit")

	// Check if the human has the hardsuit on
	TEST_ASSERT_EQUAL(human.wear_suit, hardsuit, "Human didn't equip the hardsuit")

	// Make sure the health analyzer was dropped as part of the swap
	// Since health analyzers are an invalid suit storage item
	TEST_ASSERT_EQUAL(human.s_store, null, "Human didn't drop the health analyzer")

	// Give the human an emergency oxygen tank
	// This is valid suit storage for both the winter coat AND the hardsuit
	var/obj/item/tank = allocate(/obj/item/tank/internals/emergency_oxygen)
	TEST_ASSERT(human.equip_to_slot_if_possible(tank, ITEM_SLOT_SUITSTORE), "Couldn't equip emergency oxygen tank")

	// Now, quick swap back to the coat
	// Since the tank is a valid suit storage item, it should not be dropped
	TEST_ASSERT(human.equip_to_appropriate_slot(coat, swap = TRUE), "Couldn't quick swap to coat")
	TEST_ASSERT_EQUAL(human.s_store, tank, "Human dropped the oxygen tank, when it was a valid item to keep in suit storage")

/// Tests that doUnEquip code is ran by checking vision correcting glasses
/datum/unit_test/quick_swap_glasses/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)

	ADD_TRAIT(human, TRAIT_NEARSIGHT, TRAIT_GENERIC)

	var/obj/item/clothing/glasses/regular/glasses = allocate(/obj/item/clothing/glasses/regular)
	TEST_ASSERT(human.equip_to_slot_if_possible(glasses, ITEM_SLOT_EYES), "Couldn't equip glasses")
	TEST_ASSERT_EQUAL(human.screens["nearsighted"], null, "Human equipped glasses, but still has overlay")

	var/obj/item/clothing/glasses/monocle/monocle = allocate(/obj/item/clothing/glasses/monocle)

	TEST_ASSERT(human.equip_to_slot_if_possible(monocle, ITEM_SLOT_EYES, swap = TRUE), "Couldn't quick swap to monocle")
	TEST_ASSERT_NOTEQUAL(human.screens["nearsighted"], null, "Human quick swapped to monocle, but has no nearsighted overlay")

	TEST_ASSERT(human.equip_to_slot_if_possible(glasses, ITEM_SLOT_EYES, swap = TRUE), "Couldn't quick swap to glasses")
	TEST_ASSERT_EQUAL(human.screens["nearsighted"], null, "Human quick swapped to glasses, but still has nearsighted overlay")
