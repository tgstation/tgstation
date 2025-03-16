/datum/unit_test/pills/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	var/obj/item/reagent_containers/applicator/pill/iron/pill_one = allocate(/obj/item/reagent_containers/applicator/pill/iron)
	var/obj/item/reagent_containers/applicator/pill/iron/pill_two = allocate(/obj/item/reagent_containers/applicator/pill/tox)

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/iron), FALSE, "Human somehow has iron before taking the any pills")
	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/toxin), FALSE, "Human somehow has iron before taking the any pills")

	pill_one.layers_remaining = 0
	pill_one.interact_with_atom(human, human)
	human.Life(SSMOBS_DT)

	TEST_ASSERT(human.has_reagent(/datum/reagent/iron), "Human doesn't have iron after taking the first pill")

	pill_two.layers_remaining = 4
	pill_two.interact_with_atom(human, human)
	human.Life(SSMOBS_DT)
	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/toxin), FALSE, "Human has toxin despite consuming a pill with four layers after a single tick")
