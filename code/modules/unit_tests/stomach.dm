/datum/unit_test/stomach/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	var/obj/item/reagent_containers/food/snacks/hotdog/fooditem = allocate(/obj/item/reagent_containers/food/snacks/hotdog)
	var/obj/item/organ/stomach/belly = human.getorganslot(ORGAN_SLOT_STOMACH)

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/consumable/ketchup), FALSE, "Human somehow has ketchup before eating")

	fooditem.attack(human, human)

	TEST_ASSERT(human.has_reagent(/datum/reagent/consumable/ketchup), "Human doesn't have ketchup after eating")
	TEST_ASSERT(belly.reagents.has_reagent(/datum/reagent/consumable/ketchup), "Stomach doesn't have ketchup after eating")

	qdel(belly)

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/consumable/ketchup), FALSE, "Human still has ketchup after removal of stomach")

	fooditem.attack(human, human)

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/consumable/ketchup), FALSE, "Human has ketchup without a stomach")
