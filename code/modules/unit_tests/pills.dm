/datum/unit_test/pills/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human)
	var/obj/item/reagent_containers/pill/iron/pill = allocate(/obj/item/reagent_containers/pill/iron)

	TEST_ASSERT_EQUAL(human.has_reagent(/datum/reagent/iron), FALSE, "Human somehow has iron before taking pill")

	pill.attack(human, human)
	human.Life()

	TEST_ASSERT(human.has_reagent(/datum/reagent/iron), "Human doesn't have iron after taking pill")
