/// Tests several different ways of changing clothes through species changes to ensure nothing breaks:
/// Tests if Monkeys (who can wear collars) keeps collars when changing into a species that can't.
/// Tests if Humans wearing shoes will keep said shoes when turning into a Digitigrade
/// Lastly, Tests if pockets and hand items drop when you change species, as there's snowflake code around that.
/datum/unit_test/species_change_clothing

/datum/unit_test/species_change_clothing/Run()
	// Test lizards as their own thing so we can get more coverage on their features
	var/mob/living/carbon/human/morphing_human = allocate(/mob/living/carbon/human/dummy/consistent)

	// Testing whether item-species restrictions properly blocks changing into a blacklisted species.
	morphing_human.set_species(/datum/species/monkey)

	var/obj/item/clothing/neck/petcollar/collar = new
	morphing_human.equip_to_slot_or_del(collar, ITEM_SLOT_NECK)
	morphing_human.set_species(/datum/species/human)

	TEST_ASSERT(isnull(morphing_human.get_item_by_slot(ITEM_SLOT_NECK)), "Human still has a Monkey collar after changing species.")

	//Allocate the necessary stuff
	var/obj/item/clothing/shoes/clown_shoes/swag_shoes = allocate(/obj/item/clothing/shoes/clown_shoes)
	var/obj/item/clothing/accessory/pocketprotector/pocket_item = allocate(/obj/item/clothing/accessory/pocketprotector)
	var/obj/item/melee/energy/axe/hand_item = allocate(/obj/item/melee/energy/axe)

	//Equip it all
	morphing_human.equip_to_slot_or_del(swag_shoes, ITEM_SLOT_FEET)
	morphing_human.equip_to_slot_or_del(pocket_item, ITEM_SLOT_LPOCKET)
	morphing_human.put_in_l_hand(hand_item)

	//Keep track of the shoes and make sure they will not fit.
	var/obj/item/human_shoes = morphing_human.get_item_by_slot(ITEM_SLOT_FEET)
	swag_shoes.supports_variations_flags = NONE //do not fit lizards at all costs.
	morphing_human.dna.features["legs"] = DIGITIGRADE_LEGS

	morphing_human.set_species(/datum/species/lizard)

	var/obj/item/lizard_shoes = morphing_human.get_item_by_slot(ITEM_SLOT_FEET)
	TEST_ASSERT_NOTEQUAL(human_shoes, lizard_shoes, "Lizard still has shoes after changing species.")
	TEST_ASSERT(isnull(morphing_human.get_item_by_slot(ITEM_SLOT_LPOCKET)), "Lizard somehow lost their pocket items when changing species.")
	TEST_ASSERT(!isnull(morphing_human.get_item_for_held_index(LEFT_HANDS)), "Lizard somehow lost their hand items when changing species.")
