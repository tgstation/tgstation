/**
 * Test: Mutant hands component
 *
 * Adding mutant hand component gives two mutant hands in each hand slot
 * Losing a limb removes the associated hand, and re-gaining the limb re-gives the associated hand
 */
/datum/unit_test/mutant_hands

/datum/unit_test/mutant_hands/Run()
	var/mob/living/carbon/human/incredible_hulk = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/item_to_hold = allocate(/obj/item/storage/toolbox)
	incredible_hulk.put_in_hands(item_to_hold)
	incredible_hulk.AddComponent(/datum/component/mutant_hands)

	for(var/obj/item/hand as anything in incredible_hulk.held_items)
		if(!istype(hand, /obj/item/mutant_hand))
			TEST_FAIL("Dummy didn't have a mutant hand on gaining mutant hands comp! Had: [hand || "nothing"].")

	var/obj/item/bodypart/left_arm = incredible_hulk.get_bodypart(BODY_ZONE_L_ARM)
	left_arm.drop_limb()

	TEST_ASSERT(left_arm.try_attach_limb(incredible_hulk), "Mutant hands test failed to re-attach the limb after losing it.")

	for(var/obj/item/hand as anything in incredible_hulk.held_items)
		if(!istype(hand, /obj/item/mutant_hand))
			TEST_FAIL("Dummy didn't have a mutant hand after re-gaining a limb! Had: [hand || "nothing"].")

/**
 * Test: Mutant hands component with a nodrop item in place
 *
 * Adding mutant hand component does not force no-drop items out of hands
 * If the no-drop item disappears / is deleted, a new hand should re-appear immediately
 */
/datum/unit_test/mutant_hands_with_nodrop

/datum/unit_test/mutant_hands_with_nodrop/Run()
	var/mob/living/carbon/human/incredible_hulk = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/item_to_hold = allocate(/obj/item/storage/toolbox)
	ADD_TRAIT(item_to_hold, TRAIT_NODROP, TRAIT_SOURCE_UNIT_TESTS)
	incredible_hulk.put_in_hand(item_to_hold, 1)
	incredible_hulk.AddComponent(/datum/component/mutant_hands)

	if(!istype(incredible_hulk.held_items[1], /obj/item/storage/toolbox))
		TEST_FAIL("Dummy's left hand was not a toolbox, though it was supposed to be. Was: [incredible_hulk.held_items[1] || "nothing"].")

	if(!istype(incredible_hulk.held_items[2], /obj/item/mutant_hand))
		TEST_FAIL("Dummy 's right hand was not a mutant hand! Was: [incredible_hulk.held_items[2] || "nothing"].")

	QDEL_NULL(item_to_hold)

	if(!istype(incredible_hulk.held_items[1], /obj/item/mutant_hand))
		TEST_FAIL("Dummy's left hand was not a mutant hand after losing the nodrop item. Was: [incredible_hulk.held_items[1] || "nothing"].")

/**
 * Test: Mutant hands fireman carrying
 *
 * Mutant hands currently do not support fireman carrying despite being theoretically allowed,
 * tests that this continues to be the case. Can be updated if this assertion is changed.
 */
/datum/unit_test/mutant_hands_carry

/datum/unit_test/mutant_hands_carry/Run()
	var/mob/living/carbon/human/incredible_hulk = allocate(/mob/living/carbon/human/consistent)
	var/mob/living/carbon/human/carried = allocate(/mob/living/carbon/human/consistent)
	incredible_hulk.AddComponent(/datum/component/mutant_hands)

	carried.set_resting(TRUE, instant = TRUE)

	// Try a fireman carry. It should fail, we have no open hands
	incredible_hulk.buckle_mob(carried, force = TRUE, check_loc = TRUE, buckle_mob_flags = CARRIER_NEEDS_ARM)
	TEST_ASSERT(!length(incredible_hulk.buckled_mobs), "Someone with mutant hands was able to fireman carry, despite having no hands to do so.")
