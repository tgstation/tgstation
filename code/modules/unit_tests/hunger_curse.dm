/// Tests that the curse of hunger, from [/datum/component/curse_of_hunger],
/// is properly added when equipped to the correct slot and removed when dropped / deleted
/datum/unit_test/hunger_curse

/datum/unit_test/hunger_curse/Run()
	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/storage/backpack/duffelbag/cursed/cursed_bag = allocate(/obj/item/storage/backpack/duffelbag/cursed)

	dummy.equip_to_appropriate_slot(cursed_bag)

	TEST_ASSERT(HAS_TRAIT(cursed_bag, TRAIT_NODROP), "The cursed bag wasn't NODROP after being cursed!")
	TEST_ASSERT(HAS_TRAIT(dummy, TRAIT_CLUMSY), "Dummy wasn't clumsy after being cursed!")
	TEST_ASSERT(HAS_TRAIT(dummy, TRAIT_PACIFISM), "Dummy wasn't a pacifist after being cursed!")

	QDEL_NULL(cursed_bag)

	TEST_ASSERT(!HAS_TRAIT(dummy, TRAIT_CLUMSY), "Dummy was still clumsy after being cured of its curse!")
	TEST_ASSERT(!HAS_TRAIT(dummy, TRAIT_PACIFISM), "Dummy was still a pacifist after being cured of its curse!")
