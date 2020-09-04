/datum/unit_test/reagent_mob_procs/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	var/obj/item/organ/stomach/belly = human.getorganslot(ORGAN_SLOT_STOMACH)
	var/obj/item/reagent_containers/food/snacks/hotdog/food = allocate(/obj/item/reagent_containers/food/snacks/hotdog)

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/consumable/ketchup), FALSE, "Human somehow has ketchup before eating")
	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/medicine/epinephrine), FALSE, "Human somehow has epinephrine before injecting")

	food.attack(human, human)
	human.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 5)

	TEST_ASSERT(human.has_reagent(/datum/reagent/consumable/ketchup), "Human doesn't have ketchup after eating")
	TEST_ASSERT(human.has_reagent(/datum/reagent/medicine/epinephrine), "Human doesn't have epinephrine after injecting")

	TEST_ASSERT_EQUAL(human.get_reagent_amount(/datum/reagent/medicine/epinephrine), 5, "Human does not have the proper amount of epinephrine")

	var/ketchup_amount = human.get_reagent_amount(/datum/reagent/consumable/ketchup)
	human.remove_reagent(/datum/reagent/consumable/ketchup, ketchup_amount)

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/consumable/ketchup), FALSE, "Human still has ketchup after removal")
	TEST_ASSERT(human.has_reagent(/datum/reagent/medicine/epinephrine), "Human doesn't have epinephrine after removal of ketchup")

	belly.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 5)

	TEST_ASSERT_EQUAL(human.get_reagent_amount(/datum/reagent/medicine/epinephrine), 10, "Human does not have the proper amount of epinephrine after added to belly")

	human.remove_reagent(/datum/reagent/medicine/epinephrine, 7)

	TEST_ASSERT_EQUAL(human.get_reagent_amount(/datum/reagent/medicine/epinephrine), 3, "Human does not have the proper amount of epinephrine after removal of 7u")
