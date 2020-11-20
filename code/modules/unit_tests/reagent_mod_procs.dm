/datum/unit_test/reagent_mob_procs/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	var/obj/item/reagent_containers/food/snacks/hotdog/food = allocate(/obj/item/reagent_containers/food/snacks/hotdog)

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/consumable/ketchup), FALSE, "Human somehow has ketchup before eating")
	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/medicine/epinephrine), FALSE, "Human somehow has epinephrine before injecting")

	food.attack(human, human)
	human.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 5)

	TEST_ASSERT(human.has_reagent(/datum/reagent/consumable/ketchup), "Human doesn't have ketchup after eating")
	TEST_ASSERT(human.has_reagent(/datum/reagent/medicine/epinephrine), "Human doesn't have epinephrine after injecting")
