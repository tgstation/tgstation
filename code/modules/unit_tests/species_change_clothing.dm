///Gives a Human lizard-incompatible shoes, then changes their species over to see if they drop the now incompatible shoes, testing if Digitigrade feet works.
///Gives a Monkey a collar, then changes their species to Human to see if item's restrictions works on species change.
/datum/unit_test/species_change_clothing

/datum/unit_test/species_change_clothing/Run()
	// Test lizards as their own thing so we can get more coverage on their features
	var/mob/living/carbon/human/morphing_human = allocate(/mob/living/carbon/human/dummy/consistent)

	morphing_human.equipOutfit(/datum/outfit/job/assistant/consistent)
	morphing_human.dna.features[FEATURE_LEGS] = DIGITIGRADE_LEGS //you WILL have digitigrade legs

	var/obj/item/human_shoes = morphing_human.get_item_by_slot(ITEM_SLOT_FEET)
	human_shoes.supports_variations_flags = NONE //do not fit lizards at all costs.
	morphing_human.set_species(/datum/species/lizard)
	var/obj/item/lizard_shoes = morphing_human.get_item_by_slot(ITEM_SLOT_FEET)

	TEST_ASSERT_NOTEQUAL(human_shoes, lizard_shoes, "Lizard still has shoes after changing species.")

	// Testing whether item-species restrictions properly blocks changing into a blacklisted species.
	morphing_human.set_species(/datum/species/monkey)

	var/obj/item/clothing/neck/petcollar/collar = new
	morphing_human.equip_to_slot_or_del(collar, ITEM_SLOT_NECK)

	var/obj/item/equipped_collar = morphing_human.get_item_by_slot(ITEM_SLOT_NECK)
	morphing_human.set_species(/datum/species/human)
	var/obj/item/human_collar = morphing_human.get_item_by_slot(ITEM_SLOT_NECK)

	TEST_ASSERT_NOTEQUAL(equipped_collar, human_collar, "Human still has a Monkey collar after changing species.")

///Gives a Human items in both hands, then swaps them to be another species. Held items should remain.
/datum/unit_test/species_change_held_items

/datum/unit_test/species_change_held_items/Run()
	var/mob/living/carbon/human/morphing_human = allocate(/mob/living/carbon/human/dummy/consistent)
	var/obj/item/item_a = allocate(/obj/item/storage/toolbox)
	var/obj/item/item_b = allocate(/obj/item/melee/baton/security/loaded)
	morphing_human.put_in_hands(item_a)
	morphing_human.put_in_hands(item_b)

	var/pre_change_num = length(morphing_human.get_empty_held_indexes())
	TEST_ASSERT_EQUAL(pre_change_num, 0, "Human had empty hands before the species change happened.")

	morphing_human.set_species(/datum/species/lizard)

	var/post_change_num = length(morphing_human.get_empty_held_indexes())
	TEST_ASSERT_EQUAL(post_change_num, 0, "Human had empty hands after the species change happened, but they should've kept their items.")
