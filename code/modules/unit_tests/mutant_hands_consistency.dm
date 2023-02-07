/datum/unit_test/mutant_hands

/datum/unit_test/mutant_hands/Run()
	var/mob/living/carbon/human/incredible_hulk = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/item_to_hold = allocate(/obj/item/storage/toolbox)
	incredible_hulk.put_in_hands(item_to_hold)
	incredible_hulk.AddComponent(/datum/component/mutant_hands)

	// Required reading: Held items is a list of length = number of hands, it contains either nulls or /obj/item references.
	// However it's length is always equals to the number of hands.

	for(var/obj/item/hand as anything in incredible_hulk.held_items)
		if(!istype(hand, /obj/item/mutant_hand))
			TEST_FAIL("Dummy didn't have a mutant hand on gaining mutant hands comp! Instead they had [hand || "nothing"].")

	var/obj/item/bodypart/left_arm = incredible_hulk.get_bodypart(BODY_ZONE_L_ARM)
	left_arm.drop_limb()

	for(var/obj/item/hand as anything in incredible_hulk.held_items)
		if(!istype(hand, /obj/item/mutant_hand))
			TEST_FAIL("Dummy didn't have a mutant hand after losing a limb! Instead they had [hand || "nothing"].")

	TEST_ASSERT(left_arm.try_attach_limb(incredible_hulk), "Mutant hands failed to re-attach the limb after losing it.")

	for(var/obj/item/hand as anything in incredible_hulk.held_items)
		if(!istype(hand, /obj/item/mutant_hand))
			TEST_FAIL("Dummy didn't have a mutant hand after re-gaining a limb! Instead they had [hand || "nothing"].")

/datum/unit_test/mutant_hands_with_nodrop
	var/mob/living/carbon/human/incredible_hulk = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/item_to_hold = allocate(/obj/item/storage/toolbox)
	ADD_TRAIT(item_to_hold, TRAIT_NODROP, TRAIT_SOURCE_UNIT_TESTS)
	incredible_hulk.put_in_l_hand(item_to_hold)
	incredible_hulk.AddComponent(/datum/component/mutant_hands)

	if(!istype(incredible_hulk.held_items[1], /obj/item/storage/toolbox))
		TEST_FAIL("Dummy's left hand was not a toolbox, though it was supposed to be. Instead, it was [hand || "nothing"].")

	if(!istype(incredible_hulk.held_items[2], /obj/item/mutant_hand))
		TEST_FAIL("Dummy didn't have a mutant hand on gaining the mutant hands comp! Instead they had [hand || "nothing"].")

	QDEL_NULL(item_to_hold)

	if(!istype(incredible_hulk.held_items[1], /obj/item/mutant_hand))
		TEST_FAIL("Dummy's left hand was not a mutant hand after losing the nodrop item. Instead, it was [hand || "nothing"].")
