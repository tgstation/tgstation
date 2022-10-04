///Gives a Human lizard-incompatible shoes, then changes their species over to see if they drop the now incompatible shoes, testing if Digitigrade feet works.
///Gives a Monkey a collar, then changes their species to Human to see if item's restrictions works on species change.
/datum/unit_test/species_change_clothing

/datum/unit_test/species_change_clothing/Run()
	// Test lizards as their own thing so we can get more coverage on their features
	var/mob/living/carbon/human/morphing_human = allocate(/mob/living/carbon/human/dummy/consistent)

	morphing_human.equipOutfit(/datum/outfit/job/assistant/consistent)
	morphing_human.dna.features["legs"] = DIGITIGRADE_LEGS //you WILL have digitigrade legs

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
