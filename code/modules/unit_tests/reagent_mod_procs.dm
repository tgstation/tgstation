/datum/unit_test/reagent_mob_procs/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/medicine/epinephrine), FALSE, "Human somehow has epinephrine before injecting")

	human.reagents.add_reagent(/datum/reagent/medicine/epinephrine, 5)
	TEST_ASSERT(human.has_reagent(/datum/reagent/medicine/epinephrine), "Human doesn't have epinephrine after injecting")
